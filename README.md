# llama-rpc

CUDA-enabled `llama.cpp` Docker image with the RPC backend enabled.

## Image

The GitHub Actions workflow publishes to:

```text
ghcr.io/hrntknr/llama-rpc:latest
ghcr.io/hrntknr/llama-rpc:<llama.cpp-release>
```

## Run

```bash
docker run --rm --gpus all -p 50052:50052 ghcr.io/hrntknr/llama-rpc:latest
```

The container starts `rpc-server --host 0.0.0.0 --port 50052` by default.
Do not expose this port to an untrusted network; upstream marks the RPC server as experimental and insecure.

The image includes the standard `llama.cpp` binaries produced under `build/bin`, with CUDA and RPC enabled. Override the entrypoint to run another binary such as `llama-cli` or `llama-server`.

## Updates

Renovate tracks `ARG LLAMA_CPP_VERSION` in `Dockerfile` against `ggml-org/llama.cpp` GitHub releases. When upstream publishes a new release, Renovate opens and automerges the update after CI passes. Merging to `main` builds and pushes the updated image to GHCR.

The default CUDA target is `70-real` for NVIDIA V100. Override `CMAKE_CUDA_ARCHITECTURES` at build time if you need a different GPU target.
