FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine as builder 
 
RUN mkdir -p /root/src/app/dotnet
WORKDIR /root/src/app/dotnet
 
COPY *.csproj .
RUN dotnet restore -r linux-musl-x64

COPY . .
RUN dotnet publish -c release -o /app -r linux-musl-x64 --self-contained true --no-restore /p:PublishTrimmed=true /p:PublishReadyToRun=true


FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.1-alpine

RUN set -x \
    && apk update && apk upgrade \
    && apk add --no-cache nginx bash

# Nginx site config
RUN echo $'server {\n\
  listen 80 default_server;\n\
  listen [::]:80 default_server;\n\
  location / {\n\
  proxy_pass http://localhost:5000;\n\
  }\n\
  }' > /etc/nginx/http.d/default.conf

WORKDIR /root/  
COPY --from=builder /app .

# CMD Entry point
RUN touch ./nginx-dotnet.sh                        && \ 
    chmod +x ./nginx-dotnet.sh                     && \
    echo $'#!/bin/bash\n\n\
    set -m\n\
    ./dotnet-demo-app & \n\
    nginx -g "pid /tmp/nginx.pid;" -c /etc/nginx/nginx.conf\n\
    fg %1' > ./nginx-dotnet.sh

ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 80/tcp
ENTRYPOINT ["./nginx-dotnet.sh"]