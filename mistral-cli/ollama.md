
qwen3-coder
devstral-small-2

stored at:
- snap: /var/snap/ollama/common/models/
- local: .ollama

curl http://localhost:11434/api/generate -d '{
  "model": "devstral-small-2",
  "prompt": "Howto say hello in French?"
}'

