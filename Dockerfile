FROM golang:1.23-alpine AS builder

# 构建执行文件
WORKDIR /app
RUN apk add git make && git clone https://github.com/bincooo/chatgpt-adapter.git -b main .
RUN make install
# RUN make
RUN make build-linux
# RUN make build-osx
# RUN make build-win

FROM ubuntu:latest

RUN apt update \
  && apt-get install -y curl unzip wget gnupg2 tree

WORKDIR /app
COPY --from=builder /app/bin/linux/server ./server
ADD config.yaml .
RUN chmod +x server

# Install google
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && apt-get install -y google-chrome-stable
RUN google-chrome-stable --version

# 下载过盾文件
RUN curl -JLO https://raw.githubusercontent.com/bincooo/chatgpt-adapter/refs/heads/hel/bin.zip
RUN unzip bin.zip && tree .
RUN mkdir log && chmod -R 777 /app
ENV ARG "--port 7860"
CMD ["./server ${ARG}"]
ENTRYPOINT ["sh", "-c"]
