1. py -3.12 -m venv .venv
2. .\.venv\Scripts\Activate.ps1
3. Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

################################################

## Run th edocker

################################################
cd C:\python\ML-POC\huggingface-domain-specific-rag

docker run --rm -it -v "${PWD}:/workspace" -v hf-model-cache:/root/.cache/huggingface hf-domain-rag-cpu bash

we can see the the workspace looks like: /workspace/artifacts/local_checkpoint
