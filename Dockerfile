ARG CUDA_VERSION=12.9.1
ARG UBUNTU_VERSION=24.04

FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} AS build

ARG LLAMA_CPP_VERSION=b9738
ARG CMAKE_CUDA_ARCHITECTURES="70-real"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${LLAMA_CPP_VERSION}" https://github.com/ggml-org/llama.cpp.git

WORKDIR /src/llama.cpp
RUN cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CUDA_ARCHITECTURES="${CMAKE_CUDA_ARCHITECTURES}" \
        -DCMAKE_CUDA_FLAGS="-Wno-deprecated-gpu-targets" \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,--allow-shlib-undefined" \
        -DCMAKE_INSTALL_PREFIX=/opt/llama.cpp \
        -DGGML_CUDA=ON \
        -DGGML_RPC=ON \
        -DLLAMA_BUILD_TESTS=OFF \
    && cmake --build build --config Release --parallel 2 \
    && mkdir -p /opt/llama.cpp/bin /opt/llama.cpp/lib \
    && find build/bin -maxdepth 1 -type f -executable ! -name "*.so*" -exec cp {} /opt/llama.cpp/bin/ \; \
    && cp -P build/bin/*.so* /opt/llama.cpp/lib/

FROM nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        ffmpeg \
        ibverbs-providers \
        libgomp1 \
        libibverbs1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/llama.cpp /opt/llama.cpp

ENV PATH="/opt/llama.cpp/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/llama.cpp/lib:${LD_LIBRARY_PATH}"

EXPOSE 50052
ENTRYPOINT ["rpc-server"]
CMD ["--host", "0.0.0.0", "--port", "50052"]
