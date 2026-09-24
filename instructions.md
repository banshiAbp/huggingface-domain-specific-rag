# Local and Docker Execution Guide

This document explains how to set up the Python environment and manage the complete Docker lifecycle for the Hugging Face domain-specific RAG project.

## Resource Names Used

The commands below use consistent names so the container, image, and cache are easy to identify.

| Resource | Name | Purpose |
|---|---|---|
| Docker image | `hf-domain-rag-cpu` | Reproducible Python and RAG runtime |
| Docker container | `hf-domain-rag` | Running or stopped project environment |
| Docker volume | `hf-model-cache` | Persistent Hugging Face model downloads |
| Local project directory | Current `${PWD}` | Notebook, source files, and generated artifacts |

The project directory is bind-mounted from Windows into `/workspace`. Removing the Docker container, image, or model-cache volume does **not** remove the repository from Windows.

## Option 1: Run Locally Without Docker

### Create the virtual environment

Run these commands from PowerShell in the repository root:

```powershell
py -3.12 -m venv .venv
```

This creates an isolated Python environment in `.venv`.

### Activate the virtual environment

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

The execution-policy change applies only to the current PowerShell process.

### Install dependencies

```powershell
python -m pip install --upgrade pip
python -m pip install -r requirements-local.txt
```

### Start JupyterLab

```powershell
python -m jupyter lab notebooks\domain_specific_rag.ipynb
```

### Leave the virtual environment

```powershell
deactivate
```

## Option 2: Run with Docker

Run all host-side commands below from the repository root:

```powershell
cd C:\python\ML-POC\huggingface-domain-specific-rag
```

### 1. Build the Docker image

```powershell
docker build -t hf-domain-rag-cpu .
```

This creates the reusable `hf-domain-rag-cpu` image from `Dockerfile`. Run it after changing the Dockerfile or dependency file.

Verify that the image exists:

```powershell
docker image ls hf-domain-rag-cpu
```

### 2. Create and start the container for the first time

```powershell
docker run --name hf-domain-rag -it `
  -p 8888:8888 `
  -v "${PWD}:/workspace" `
  -v hf-model-cache:/root/.cache/huggingface `
  hf-domain-rag-cpu bash
```

This command performs both **create** and **up** for the first run:

- `--name hf-domain-rag` gives the container a stable name.
- `-it` opens an interactive Bash terminal.
- `-p 8888:8888` exposes JupyterLab to Windows.
- `-v "${PWD}:/workspace"` mounts the repository into the container.
- `-v hf-model-cache:/root/.cache/huggingface` keeps downloaded models between runs.
- `hf-domain-rag-cpu` is the image created in the previous step.
- `bash` starts a shell inside the container.

Do not add `--rm` if you want to stop and restart the same container later. With `--rm`, Docker deletes the container automatically when the shell exits.

### 3. Start JupyterLab inside the container

After the container shell opens, run:

```bash
python -m jupyter lab \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root
```

Open the URL printed by JupyterLab in the Windows browser. The notebook is available at:

```text
/workspace/notebooks/domain_specific_rag.ipynb
```

Press `Ctrl+C` inside the container to stop JupyterLab without deleting the container.

## Docker Up, Down, and Restart Commands

### Bring an existing container up

Use this after the container has already been created:

```powershell
docker start -ai hf-domain-rag
```

- `docker start` starts the stopped container.
- `-a` attaches the terminal to its output.
- `-i` keeps the Bash input stream interactive.

Do not run `docker run --name hf-domain-rag ...` again while that container exists; Docker container names must be unique.

### Bring the container down gracefully

From another PowerShell window, run:

```powershell
docker stop hf-domain-rag
```

This stops the container but preserves it. The image, Hugging Face cache volume, and Windows project files remain available.

If you are already inside the container shell, this also stops it:

```bash
exit
```

### Check container status

```powershell
docker ps
docker ps -a --filter "name=hf-domain-rag"
```

- `docker ps` shows running containers.
- `docker ps -a` also shows stopped containers.

## Destroy and Cleanup Commands

Use the cleanup level that matches what you want to remove.

### Remove only the container

```powershell
docker stop hf-domain-rag
docker rm hf-domain-rag
```

This removes the container's writable layer. It preserves:

- The `hf-domain-rag-cpu` image
- The `hf-model-cache` volume
- All files in the Windows project directory

If the container is already stopped, run only:

```powershell
docker rm hf-domain-rag
```

### Remove the container and image, but keep downloaded models

```powershell
docker stop hf-domain-rag
docker rm hf-domain-rag
docker image rm hf-domain-rag-cpu
```

Keeping `hf-model-cache` avoids downloading Hugging Face models again if the project image is rebuilt later.

### Fully destroy all Docker resources for this project

Run the commands in this order:

```powershell
docker stop hf-domain-rag
docker rm hf-domain-rag
docker image rm hf-domain-rag-cpu
docker volume rm hf-model-cache
```

This removes:

1. The project container
2. The project Docker image
3. The Hugging Face model-cache volume

Removing `hf-model-cache` permanently deletes the Docker-managed model cache. Models can be downloaded again later. The bind-mounted Windows repository is not deleted.

### Force-remove a container only when normal stop/remove fails

```powershell
docker rm -f hf-domain-rag
```

Use this only when the container cannot be stopped normally. It immediately terminates and removes the container.

## Verify That Project Docker Resources Are Gone

```powershell
docker ps -a --filter "name=hf-domain-rag"
docker image ls hf-domain-rag-cpu
docker volume ls --filter "name=hf-model-cache"
```

If cleanup succeeded, these commands should not list the project container, image, or cache volume.

## Common Errors

### Image cannot be deleted because a container is using it

Example:

```text
conflict: unable to delete hf-domain-rag-cpu:latest - container ... is using its referenced image
```

Fix it by removing the container first:

```powershell
docker stop hf-domain-rag
docker rm hf-domain-rag
docker image rm hf-domain-rag-cpu
```

### Volume cannot be deleted because it is in use

Example:

```text
remove hf-model-cache: volume is in use
```

The container referencing the volume must be removed first:

```powershell
docker stop hf-domain-rag
docker rm hf-domain-rag
docker volume rm hf-model-cache
```

### Container name is already in use

If `docker run` reports that `hf-domain-rag` already exists, either restart it:

```powershell
docker start -ai hf-domain-rag
```

or remove and recreate it:

```powershell
docker rm -f hf-domain-rag
```

Then run the original `docker run` command again.

## Safe Cleanup Guidance

Avoid running the following command unless you intentionally want to remove unused Docker resources from other projects:

```powershell
docker system prune --all --volumes
```

This repository shares Docker Desktop with other images and volumes, so project-specific removal commands are safer.
