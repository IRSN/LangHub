# Ollama Provider

Ollama is a free, local LLM runtime that allows you to run models on your own hardware.

## Requirements

- **Ollama installed and running** (free, open source)
- No API keys needed
- Works completely offline once models are downloaded

## Setup

### 1. Install Ollama

**macOS:**
```bash
brew install ollama
```

**Linux:**
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**Windows:**
- Download from https://ollama.ai/download

### 2. Start Ollama Service

```bash
ollama serve
```

Or simply run any ollama command to auto-start the service:
```bash
ollama list
```

### 3. Download Models

```bash
# Small, fast model (recommended for testing)
ollama pull qwen2.5-coder:7b

# Larger, more capable model
ollama pull qwen2.5-coder:32b

# Other popular models
ollama pull mistral:7b
ollama pull llama3.1:8b
ollama pull codellama:13b
```

## Configuration

### Default URI

Ollama runs on `http://localhost:11434` by default.

### Custom URI

If you're running Ollama on a different host or port, you can specify a custom URI using the syntax `ollama:http://server:port`:

```bash
# Use localhost explicitly
./lh list ollama:http://localhost:11434
./lh ask ollama:http://localhost:11434 qwen2.5-coder:7b "Hello"

# Use remote Ollama server
./lh list ollama:http://192.168.1.100:11434
./lh ask ollama:http://192.168.1.100:11434 qwen2.5-coder:7b "Hello"
```

## Usage

### List Available Models

```bash
# List locally installed models
./lh list ollama
```

### Prompt a Model

```bash
# Simple prompt
./lh ask ollama qwen2.5-coder:7b "Write a hello world program in Python"

# With context
./lh ask ollama qwen2.5-coder:7b "Explain this code" --context lib/README.md

# Save output to file
./lh ask ollama qwen2.5-coder:7b "Summarize the documentation" \
    --context lib/ --output summary.md
```

### Use in .lmd Files

```markdown
\`\`\`ollama, model=qwen2.5-coder:7b, context=lib/, output=result.md
Analyze the code and provide insights.
\`\`\`
```

Process the .lmd file:
```bash
./lh render src/input.lmd
```

## Available Models

Popular models you can use with Ollama:

### Code Models
- `qwen2.5-coder:7b` - Fast, good for code (4GB)
- `qwen2.5-coder:32b` - Best quality code model (20GB)
- `codellama:13b` - Meta's code model (7GB)
- `deepseek-coder:6.7b` - Specialized for coding (4GB)

### General Purpose
- `mistral:7b` - Fast, good quality (4GB)
- `llama3.1:8b` - Latest Meta model (4.7GB)
- `phi3:14b` - Microsoft's efficient model (8GB)

### Chat/Instruction
- `mistral:7b-instruct` - Optimized for chat (4GB)
- `llama3.1:8b-instruct` - Chat-optimized (4.7GB)

Browse all models at: https://ollama.ai/library

## Tips

### Check Available Models

```bash
ollama list
```

### Check Model Info

```bash
ollama show qwen2.5-coder:7b
```

### Remove Models

```bash
ollama rm qwen2.5-coder:32b
```

### Monitor Performance

```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# View logs (Linux/macOS)
journalctl -u ollama -f
```

## Troubleshooting

### "Connection refused" Error

**Cause:** Ollama service not running

**Solution:**
```bash
# Start Ollama service
ollama serve

# Or simply run a command to auto-start
ollama list
```

### "Model not found" Error

**Cause:** Model not installed locally

**Solution:**
```bash
# Install the model
ollama pull qwen2.5-coder:7b

# List installed models
ollama list
```

### Slow Performance

**Cause:** Model too large for your hardware

**Solution:**
- Use smaller models (7b instead of 32b)
- Ensure you have enough RAM (8GB minimum, 16GB+ recommended)
- Close other applications

### Out of Memory

**Cause:** Not enough RAM/VRAM for the model

**Solution:**
```bash
# Use quantized versions (smaller)
ollama pull qwen2.5-coder:7b-q4

# Or switch to smaller model
ollama pull mistral:7b
```

## Advantages

- **Privacy**: Runs completely locally
- **Offline**: Works without internet after download
- **No network latency**: Local processing
- **Easy**: Simple installation and usage

## Limitations

- **Hardware requirements**: Needs decent CPU/GPU and RAM
- **Model size**: Large models require significant disk space
- **Setup time**: Initial model downloads can be large (4-20GB)

## Recommended Setup

**For testing and development:**
```bash
ollama pull qwen2.5-coder:7b
```

**For production quality:**
```bash
ollama pull qwen2.5-coder:32b
```

**For resource-constrained environments:**
```bash
ollama pull mistral:7b
```
