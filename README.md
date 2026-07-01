# llama-rpc

CUDA-enabled `llama.cpp` Docker image with the RPC backend enabled.

## Image

The GitHub Actions workflow publishes to:

```text
ghcr.io/hrntknr/llama-rpc:latest
ghcr.io/hrntknr/llama-rpc:<llama.cpp-release>
```

## Run

The image sets no `ENTRYPOINT` or `CMD`; specify the binary explicitly.

```bash
# rpc-server (GPU node)
docker run --rm --gpus all -p 50052:50052 ghcr.io/hrntknr/llama-rpc:latest \
  rpc-server --host 0.0.0.0 --port 50052

# llama-server (client, aggregating multiple rpc-servers)
docker run --rm ghcr.io/hrntknr/llama-rpc:latest \
  llama-server -m model.gguf --rpc host1:50052,host2:50052 -ngl 999
```

The RPC server is upstream-marked experimental and insecure; do not expose its port to an untrusted network.

The image includes the standard `llama.cpp` binaries produced under `build/bin`, with CUDA and RPC enabled. Run `rpc-server`, `llama-cli`, or `llama-server` by passing the binary name as the command.

## Updates

Renovate tracks `ARG LLAMA_CPP_VERSION` in `Dockerfile` against `ggml-org/llama.cpp` GitHub releases. When upstream publishes a new release, Renovate opens and automerges the update after CI passes. Merging to `main` builds and pushes the updated image to GHCR.

The default CUDA target is `70-real` for NVIDIA V100. Override `CMAKE_CUDA_ARCHITECTURES` at build time if you need a different GPU target.
