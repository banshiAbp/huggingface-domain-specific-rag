FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV TOKENIZERS_PARALLELISM=false

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip

# CPU-only PyTorch: no NVIDIA GPU is required.
RUN pip install torch --index-url https://download.pytorch.org/whl/cpu

COPY requirements-local.txt /tmp/requirements-local.txt

RUN pip install -r /tmp/requirements-local.txt

EXPOSE 8888

CMD ["bash"]