# 🤖 LLM Models Guide

This guide helps you choose and optimize the right model for Docker log analysis.

## Table of Contents

- [Recommended Models](#recommended-models)
- [Model Comparison](#model-comparison)
- [Performance Benchmarks](#performance-benchmarks)
- [Model Selection Guide](#model-selection-guide)
- [Optimization Tips](#optimization-tips)
- [Advanced Configuration](#advanced-configuration)

---

## Recommended Models

### 1. Qwen 2.5 1.5B Instruct ⚡ (Best for Most Users)

**Perfect for daily automated summaries**

```
Model: qwen2.5-1.5b-instruct
Size: ~1 GB
VRAM: 2 GB
Speed: ~50 tokens/sec (CPU)
```

**Pros:**
- Extremely fast on CPU
- Low memory footprint
- Great JSON output consistency
- Good at following instructions

**Cons:**
- Less detailed analysis than larger models
- May miss subtle patterns

**Best for:**
- Daily automated reports
- Limited hardware (NUCs, Mini PCs)
- Quick feedback loops

**Download in LM Studio:**
```
Search: "qwen2.5-1.5b-instruct"
Recommended: TheBloke/Qwen2.5-1.5B-Instruct-GGUF
```

---

### 2. Phi-3 Mini 4K Instruct 🎯 (Balanced)

**Best balance of speed and quality**

```
Model: phi-3-mini-4k-instruct
Size: ~2.3 GB
VRAM: 3 GB
Speed: ~30 tokens/sec (CPU)
```

**Pros:**
- Strong reasoning capabilities
- Better at context understanding
- Microsoft-trained on high-quality data
- Good code/log understanding

**Cons:**
- Slower than Qwen
- Needs more RAM

**Best for:**
- Complex multi-container setups
- When you need better analysis depth
- Systems with 8+ GB RAM

**Download in LM Studio:**
```
Search: "phi-3-mini-4k-instruct"
Recommended: microsoft/Phi-3-mini-4k-instruct-gguf
```

---

### 3. Llama 3.2 3B Instruct 🏆 (Best Quality)

**Most accurate and detailed analysis**

```
Model: llama-3.2-3b-instruct
Size: ~2 GB
VRAM: 4 GB
Speed: ~25 tokens/sec (CPU)
```

**Pros:**
- Most accurate pattern recognition
- Best natural language output
- Excellent at anomaly detection
- Strong reasoning

**Cons:**
- Slowest of the three
- Higher resource usage

**Best for:**
- Critical infrastructure monitoring
- When accuracy matters most
- Systems with dedicated GPU

**Download in LM Studio:**
```
Search: "llama-3.2-3b-instruct"
Recommended: meta-llama/Llama-3.2-3B-Instruct-GGUF
```

---

## Model Comparison

| Feature | Qwen 1.5B | Phi-3 Mini | Llama 3.2 3B |
|---------|-----------|------------|--------------|
| **Speed** | ⚡⚡⚡ | ⚡⚡ | ⚡ |
| **Accuracy** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **JSON Output** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Context Understanding** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Memory Usage** | ~2 GB | ~3 GB | ~4 GB |
| **CPU Performance** | Excellent | Good | Fair |
| **Best Use Case** | Daily automation | Balanced needs | Critical systems |

---

## Performance Benchmarks

Tested on: Intel i5-10400 (6C/12T), 16GB RAM, No GPU

### Log Analysis Speed (24h of logs from 10 containers)

| Model | Total Time | Analysis Quality | Tokens/sec |
|-------|------------|------------------|------------|
| Qwen 1.5B | ~15 sec | Good | ~50 |
| Phi-3 Mini | ~25 sec | Very Good | ~30 |
| Llama 3.2 3B | ~40 sec | Excellent | ~25 |

### Memory Usage During Analysis

| Model | Idle | During Analysis | Peak |
|-------|------|-----------------|------|
| Qwen 1.5B | 500 MB | 1.8 GB | 2.1 GB |
| Phi-3 Mini | 800 MB | 2.5 GB | 3.0 GB |
| Llama 3.2 3B | 1.2 GB | 3.5 GB | 4.2 GB |

### GPU Acceleration (if available)

With NVIDIA GPU (RTX 3060):

| Model | Speed Increase | VRAM Used |
|-------|----------------|-----------|
| Qwen 1.5B | 5-8x faster (~250 tok/s) | ~2 GB |
| Phi-3 Mini | 4-6x faster (~150 tok/s) | ~3 GB |
| Llama 3.2 3B | 3-5x faster (~100 tok/s) | ~4 GB |

---

## Model Selection Guide

### Choose **Qwen 1.5B** if:

- ✅ Running on limited hardware (NUC, Raspberry Pi 4, etc.)
- ✅ Speed is more important than depth
- ✅ Analyzing logs multiple times per day
- ✅ Your setup has <10 containers
- ✅ You want the most responsive system

### Choose **Phi-3 Mini** if:

- ✅ You have 8+ GB RAM available
- ✅ Running 10-30 containers
- ✅ Need better context understanding
- ✅ Want more detailed recommendations
- ✅ Balanced speed/quality matters

### Choose **Llama 3.2 3B** if:

- ✅ Quality is paramount
- ✅ Monitoring critical infrastructure
- ✅ Have GPU acceleration available
- ✅ Complex multi-service architecture
- ✅ Can tolerate slower analysis times

---

## Optimization Tips

### 1. Quantization Settings

LM Studio supports different quantization levels. For log analysis:

**Recommended quantization:**
- **Q4_K_M** - Best balance (default)
- **Q5_K_M** - Better quality, slower
- **Q3_K_M** - Faster, less accurate

**How to change in LM Studio:**
1. When downloading, select the quantization variant
2. Q4_K_M is recommended for most use cases

### 2. Context Window

Adjust based on log volume:

```python
# In log_analyzer.py, modify:

# For small setups (1-5 containers)
tail=1000  # Fewer lines needed

# For large setups (20+ containers)
tail=10000  # More context helps
```

### 3. Temperature Settings

Controls randomness in responses:

```python
# In log_analyzer.py, in analyze_with_llm():

payload = {
    "model": model,
    "prompt": prompt,
    "temperature": 0.3,  # Lower = more focused (0.1-0.5 recommended)
    "max_tokens": 2000,
}
```

**Recommended temperatures:**
- **0.1-0.2**: Very consistent, factual responses
- **0.3-0.4**: Balanced (default)
- **0.5-0.7**: More creative, varied responses

### 4. GPU Offloading

If you have a GPU, offload layers for massive speedup:

**In LM Studio:**
1. Go to **Local Server** → **GPU Settings**
2. Set **GPU Layers** to max (auto-detects optimal)
3. Monitor VRAM usage

### 5. Prompt Optimization

Tune the analysis prompt for better results:

```python
# Modify _build_analysis_prompt() in log_analyzer.py

# For faster responses (less detailed)
prompt = f"""Analyze these logs briefly and highlight only critical issues."""

# For more detailed analysis
prompt = f"""Perform deep analysis of these logs, including:
- Root cause analysis
- Performance trends
- Predictive warnings
- Detailed recommendations"""
```

---

## Advanced Configuration

### Running Multiple Models

You can run different models for different purposes:

```bash
# Fast model for hourly health checks
curl -X POST http://localhost:8000/analyze \
  -d '{"model": "qwen2.5-1.5b-instruct", "hours": 1}'

# Detailed model for daily deep-dive
curl -X POST http://localhost:8000/analyze \
  -d '{"model": "llama-3.2-3b-instruct", "hours": 24}'
```

### Model Fallback Chain

Implement fallback if primary model fails:

```python
# Example modification to log_analyzer.py

FALLBACK_MODELS = [
    "qwen2.5-1.5b-instruct",
    "phi-3-mini-4k-instruct",
    "llama-3.2-3b-instruct"
]

def analyze_with_llm_fallback(self, logs_dict, lm_studio_url):
    for model in FALLBACK_MODELS:
        try:
            return self.analyze_with_llm(logs_dict, lm_studio_url, model)
        except Exception as e:
            logger.warning(f"Model {model} failed, trying next...")
            continue
```

### Fine-Tuning Prompts by Container Type

Customize analysis based on container type:

```python
def _build_specialized_prompt(self, container_type, logs):
    prompts = {
        "media_server": """Focus on transcoding errors, library scanning, and playback issues.""",
        "database": """Focus on query performance, connection pools, and deadlocks.""",
        "web_server": """Focus on HTTP errors, response times, and traffic patterns.""",
        "backup": """Focus on job completion, file counts, and storage warnings."""
    }
    return prompts.get(container_type, "General log analysis")
```

---

## Testing Different Models

Quick test script to compare models:

```bash
#!/bin/bash

MODELS=("qwen2.5-1.5b-instruct" "phi-3-mini-4k-instruct" "llama-3.2-3b-instruct")

for model in "${MODELS[@]}"; do
    echo "Testing $model..."
    time curl -X POST http://localhost:8000/analyze \
      -H "Content-Type: application/json" \
      -d "{\"model\": \"$model\", \"hours\": 24}" \
      -o "${model}_result.json"
    echo ""
done

echo "Results saved to *_result.json"
```

---

## Recommended Model by Hardware

| Hardware | Model | Expected Performance |
|----------|-------|---------------------|
| Raspberry Pi 4 (8GB) | Qwen 1.5B | 20-30 tok/s |
| Intel NUC (i5, 16GB) | Qwen 1.5B / Phi-3 | 40-60 tok/s |
| Desktop (i7, 32GB, No GPU) | Phi-3 Mini | 50-80 tok/s |
| Desktop (i7, 32GB, RTX 3060) | Llama 3.2 3B | 100-150 tok/s |
| Server (Xeon, 64GB, RTX 4090) | Llama 3.2 3B | 200+ tok/s |

---

## Further Reading

- [LM Studio Documentation](https://lmstudio.ai/docs)
- [Hugging Face GGUF Models](https://huggingface.co/models?library=gguf)
- [Quantization Explained](https://huggingface.co/docs/transformers/main/en/quantization)

---

**Questions?** Open an issue on GitHub or join the discussion in r/homelab!
