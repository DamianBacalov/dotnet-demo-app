FROM mcr.microsoft.com/dotnet/sdk:3.1.415 as builder 
 
RUN mkdir -p /root/src/app/dotnet
WORKDIR /root/src/app/dotnet
 
COPY devops-net-core.csproj . 
RUN dotnet restore ./devops-net-core.csproj 

COPY . .
RUN dotnet publish -c release -o published 


FROM mcr.microsoft.com/dotnet/nightly/runtime:3.1-alpine

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
COPY --from=builder /root/src/app/dotnet/published .

# CMD Entry point
RUN touch ./nginx-dotnet.sh                        && \ 
    chmod +x ./nginx-dotnet.sh                     && \
    echo $'#!/bin/bash\n\n\
    set -m\n\
    dotnet ./devops-net-core.dll & \n\
    nginx -g "pid /tmp/nginx.pid;" -c /etc/nginx/nginx.conf\n\
    fg %1' > ./nginx-dotnet.sh

ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 80/tcp
CMD ["./nginx-dotnet.sh"]