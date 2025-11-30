# 🔧 Troubleshooting Guide

Common issues and solutions for the Home Lab Log Analyzer.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Docker Issues](#docker-issues)
- [LM Studio Issues](#lm-studio-issues)
- [API Issues](#api-issues)
- [N8N Issues](#n8n-issues)
- [Email Delivery Issues](#email-delivery-issues)
- [Performance Issues](#performance-issues)
- [Log Analysis Issues](#log-analysis-issues)

---

## Installation Issues

### ❌ `docker: command not found`

**Problem**: Docker is not installed or not in PATH.

**Solution**:
```bash
# Install Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

---

### ❌ `Permission denied while trying to connect to Docker daemon`

**Problem**: User doesn't have permission to access Docker socket.

**Solution**:
```bash
# Quick fix (temporary)
sudo chmod 666 /var/run/docker.sock

# Permanent fix
sudo usermod -aG docker $USER
newgrp docker

# Restart Docker service
sudo systemctl restart docker
```

---

### ❌ `ModuleNotFoundError: No module named 'docker'`

**Problem**: Python dependencies not installed.

**Solution**:
```bash
# Ensure you're in the project directory
cd homelab-log-analyzer

# Install dependencies
pip install -r requirements.txt

# Or if using virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Docker Issues

### ❌ Container won't start: `Error starting userland proxy`

**Problem**: Port 8765 is already in use.

**Solution**:
```bash
# Check what's using port 8765
sudo lsof -i :8765

# Kill the process (replace PID with actual process ID)
kill -9 PID

# Or change the port in docker-compose.yml
ports:
  - "8001:8765"  # Use 8001 instead
```

---

### ❌ `Cannot connect to the Docker daemon`

**Problem**: Docker service is not running.

**Solution**:
```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Check status
sudo systemctl status docker
```

---

### ❌ Container logs show: `Error: failed to connect to Docker`

**Problem**: Docker socket not mounted correctly.

**Solution**:

Check `docker-compose.yml`:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro  # Ensure this line exists
```

If running on macOS or Windows with Docker Desktop:
```yaml
volumes:
  - //var/run/docker.sock:/var/run/docker.sock:ro  # Windows
  - /var/run/docker.sock:/var/run/docker.sock:ro   # macOS
```

---

## LM Studio Issues

### ❌ `Connection refused: http://localhost:1234`

**Problem**: LM Studio server is not running.

**Solution**:

1. Open LM Studio
2. Go to **Local Server** tab
3. Click **Start Server**
4. Verify it's running:
   ```bash
   curl http://localhost:1234/v1/models
   ```

**For Docker deployments**, use `host.docker.internal`:
```bash
# Test from inside container
docker exec -it log-analyzer curl http://host.docker.internal:1234/v1/models
```

---

### ❌ `504 Gateway Timeout` from LM Studio

**Problem**: Model is too slow or request timed out.

**Solutions**:

1. **Switch to a faster model** (Qwen 1.5B):
   ```json
   {
     "model": "qwen2.5-1.5b-instruct"
   }
   ```

2. **Increase timeout** in `log_analyzer.py`:
   ```python
   response = requests.post(lm_studio_url, json=payload, timeout=300)  # 5 minutes
   ```

3. **Enable GPU acceleration** in LM Studio:
   - Go to **Settings** → **GPU**
   - Set **GPU Layers** to maximum

---

### ❌ LM Studio returns gibberish or malformed JSON

**Problem**: Model is hallucinating or temperature is too high.

**Solution**:

1. **Lower temperature** in `log_analyzer.py`:
   ```python
   payload = {
       "temperature": 0.1,  # Reduce from 0.3 to 0.1
   }
   ```

2. **Use a better model**:
   - Switch from Qwen to Phi-3 or Llama 3.2

3. **Add stricter prompt**:
   ```python
   prompt = f"""...[your prompt]...
   
   CRITICAL: You MUST output ONLY valid JSON. No other text before or after."""
   ```

---

### ❌ `Model not found` error

**Problem**: Model name doesn't match what's loaded in LM Studio.

**Solution**:

1. Check loaded model in LM Studio:
   ```bash
   curl http://localhost:1234/v1/models
   ```

2. Copy the exact `id` field and use it:
   ```json
   {
     "model": "exact-model-id-from-lm-studio"
   }
   ```

---

## API Issues

### ❌ `404: No logs found for specified containers`

**Problem**: No containers running or wrong container names.

**Solution**:

1. **Check running containers**:
   ```bash
   curl http://localhost:8765/containers
   ```

2. **Use correct container names**:
   ```bash
   docker ps --format "{{.Names}}"
   ```

3. **Analyze all containers** (don't specify names):
   ```bash
   curl -X POST http://localhost:8765/analyze \
     -H "Content-Type: application/json" \
     -d '{"hours": 24}'
   ```

---

### ❌ API returns `500 Internal Server Error`

**Problem**: Something crashed in the API.

**Solution**:

1. **Check logs**:
   ```bash
   docker logs log-analyzer --tail 50
   ```

2. **Common causes**:
   - LM Studio not running
   - Invalid JSON in request
   - Docker socket permission issue

3. **Restart container**:
   ```bash
   docker-compose restart
   ```

---

### ❌ `422 Unprocessable Entity`

**Problem**: Invalid request format.

**Solution**:

Ensure your request matches this format:
```bash
curl -X POST http://localhost:8765/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "hours": 24,
    "lm_studio_url": "http://localhost:1234/v1/completions",
    "model": "qwen2.5-1.5b-instruct"
  }'
```

Common mistakes:
- Missing `Content-Type` header
- Invalid JSON syntax
- Wrong parameter types (hours must be integer)

---

## N8N Issues

### ❌ Workflow doesn't trigger at scheduled time

**Problem**: Workflow not activated or timezone issue.

**Solution**:

1. **Ensure workflow is active**:
   - Toggle should be GREEN in top-right corner

2. **Check timezone**:
   ```bash
   # In N8N Schedule Trigger node
   # Use cron expression: 0 22 * * *
   # This is 22:00 (10 PM) in your server's timezone
   ```

3. **Test manually**:
   - Click **Execute Workflow** in N8N

---

### ❌ HTTP Request node fails with connection error

**Problem**: Wrong URL or network issue.

**Solution**:

1. **Use correct URL format**:
   - If N8N is in Docker: `http://host.docker.internal:8765/analyze`
   - If N8N is on same host: `http://localhost:8765/analyze`
   - If on different machine: `http://192.168.1.X:8765/analyze`

2. **Test connection from N8N**:
   ```bash
   # From N8N container
   docker exec -it n8n curl http://host.docker.internal:8765/health
   ```

---

### ❌ Email node fails: `Invalid login`

**Problem**: Wrong SMTP credentials.

**Solution**:

**For Gmail**:
1. Enable 2FA
2. Generate App Password: [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
3. Use App Password (not your regular password)
4. Settings:
   ```
   Host: smtp.gmail.com
   Port: 587
   Security: TLS
   User: your-email@gmail.com
   Password: your-app-password
   ```

**For SendGrid**:
```
Host: smtp.sendgrid.net
Port: 587
User: apikey
Password: YOUR_SENDGRID_API_KEY
```

---

## Email Delivery Issues

### ❌ Emails not arriving

**Problem**: Multiple possible causes.

**Solutions**:

1. **Check spam folder** - LLM emails often get flagged

2. **Verify SMTP settings**:
   ```bash
   # Test SMTP manually
   telnet smtp.gmail.com 587
   ```

3. **Check N8N execution logs**:
   - Look for error messages in execution history

4. **Try a test email**:
   - Create simple N8N workflow with just Email node
   - Send test message

---

### ❌ HTML email renders poorly

**Problem**: Email client doesn't support HTML.

**Solution**:

1. **Add plain text fallback** in N8N Code node:
   ```javascript
   return {
     json: {
       subject: subject,
       html: html,
       text: "See HTML version for full report"  // Fallback
     }
   };
   ```

2. **Use simpler HTML** (avoid CSS Grid/Flexbox)

---

## Performance Issues

### ❌ Analysis takes too long (>2 minutes)

**Problem**: Too many logs or slow model.

**Solutions**:

1. **Reduce log volume**:
   ```python
   # In log_analyzer.py
   tail=2000  # Reduce from 5000
   ```

2. **Switch to faster model** (Qwen 1.5B)

3. **Analyze specific containers only**:
   ```bash
   curl -X POST http://localhost:8765/analyze \
     -d '{"containers": ["plex", "nginx"], "hours": 24}'
   ```

4. **Enable GPU** in LM Studio

---

### ❌ High memory usage

**Problem**: LLM model is too large for available RAM.

**Solutions**:

1. **Use smaller model**:
   - Switch to Qwen 1.5B (~2 GB RAM)

2. **Use quantized version**:
   - Q3_K_M or Q4_K_M quantization

3. **Reduce concurrent requests**:
   ```python
   # Don't analyze multiple times simultaneously
   ```

---

### ❌ LM Studio crashes during analysis

**Problem**: Out of memory.

**Solutions**:

1. **Close other applications**
2. **Increase swap space** (Linux):
   ```bash
   sudo fallocate -l 8G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```
3. **Use smaller model** or **lower quantization**

---

## Log Analysis Issues

### ❌ LLM returns empty or useless analysis

**Problem**: Not enough log data or too much noise.

**Solutions**:

1. **Increase time window**:
   ```json
   {"hours": 48}  // Instead of 24
   ```

2. **Adjust noise filtering** in `log_analyzer.py`:
   ```python
   # Comment out some noise patterns to keep more logs
   noise_patterns = [
       r'^\s*$',  # Only filter empty lines
   ]
   ```

3. **Improve prompt** to be more specific:
   ```python
   prompt = f"""Focus specifically on:
   - Container crashes
   - Error messages
   - Resource warnings
   
   Ignore routine operational logs."""
   ```

---

### ❌ Critical issues not detected

**Problem**: LLM missing important patterns.

**Solutions**:

1. **Use better model** (Llama 3.2 3B)

2. **Add examples to prompt**:
   ```python
   prompt = f"""Examples of critical issues:
   - "Out of memory"
   - "Connection refused"
   - "Failed to start"
   
   Analyze these logs: ..."""
   ```

3. **Lower temperature** for more focused analysis:
   ```python
   "temperature": 0.1
   ```

---

### ❌ Too many false positives

**Problem**: LLM being overly cautious.

**Solutions**:

1. **Tune prompt to be less sensitive**:
   ```python
   prompt = f"""Only report issues that require immediate attention.
   Ignore routine warnings and informational messages."""
   ```

2. **Filter common false positives** in code:
   ```python
   # After getting LLM response
   filtered_issues = [
       issue for issue in critical_issues
       if "expected_pattern" not in issue.lower()
   ]
   ```

---

## Getting More Help

If you're still stuck:

1. **Check the logs**:
   ```bash
   # API logs
   docker logs log-analyzer --tail 100
   
   # N8N logs
   docker logs n8n --tail 100
   ```

2. **Enable debug logging** in `log_analyzer.py`:
   ```python
   logging.basicConfig(level=logging.DEBUG)
   ```

3. **Open a GitHub issue**:
   - Include error messages
   - Include relevant logs
   - Describe your setup (OS, Docker version, etc.)

4. **Ask the community**:
   - r/homelab on Reddit
   - Home lab Discord servers
   - Self-Hosted podcast Discord

---

## Diagnostic Script

Run this to collect system info for debugging:

```bash
#!/bin/bash

echo "=== System Info ==="
uname -a
docker --version
docker-compose --version

echo -e "\n=== Running Containers ==="
docker ps

echo -e "\n=== Log Analyzer Status ==="
curl http://localhost:8765/health

echo -e "\n=== LM Studio Status ==="
curl http://localhost:1234/v1/models

echo -e "\n=== Recent Logs ==="
docker logs log-analyzer --tail 20
```

Save as `diagnose.sh`, make executable (`chmod +x diagnose.sh`), and run when reporting issues.
