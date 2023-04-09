from ubuntu:18.04

# Install prerequisites
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    curl \
    libcurl3-dev \
    git \
    python3-pip \
    wget

RUN mkdir /alpr
# Predownload large repository
RUN git clone https://github.com/tensorflow/models /alpr/tensorflow-models

# Install additional libraries
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libleptonica-dev \
    liblog4cplus-dev \
    libtesseract-dev \
    tesseract-ocr-rus \
    unzip \
    python3-opencv

RUN ln -s /usr/bin/python3 /usr/bin/python && pip3 install pytesseract tensorflow Cython path matplotlib

RUN git clone https://github.com/philferriere/cocoapi.git /alpr/cocoapi && cd /alpr/cocoapi/PythonAPI && make

ENV PYTHONPATH="/alpr/tensorflow-models/research:\
/alpr/tensorflow-models/research/slim:\
/alpr/tensorflow-models/research/nets:\
/alpr/tensorflow-models/research/object_detection:\
/alpr/tensorflow-models/research/object_detection/utils:\
${PYTHONPATH}"

RUN curl -OL https://github.com/google/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip \
    && unzip protoc-3.6.1-linux-x86_64.zip -d protoc3 \
    && mv protoc3/bin/* /usr/local/bin/ \
    && mv protoc3/include/* /usr/local/include/
    
RUN cd /alpr/tensorflow-models/research && protoc object_detection/protos/*.proto --python_out=.

COPY ./ /alpr/

WORKDIR /alpr

ENTRYPOINT ["/bin/bash"]
