可在网页访问的QQ，使用的Linux原生版本QQ，基础镜像来自于[LinuxServer.io](https://www.linuxserver.io/)

## 支持的架构
该镜像支持的架构有：
| Architecture | Available | Tag |
|-----------|---|--------------------------------|
|x86-64|✅|amd64-<版本标签>|
|ARM64|❌|arm64v8-<版本标签>|
|armhf|❌|

## 应用程序设置
该应用程序可以通过以下地址访问：
- http://yourhost:3000/
- https://yourhost:3001/
### 所有基于 KasmVNC 的 GUI 容器中的选项
该容器基于Docker Baseimage KasmVNC，这意味着有额外的环境变量和运行配置来启用或禁用特定功能。
#### 可选环境变量
|Variable|Description|
|---|---|
|CUSTOM_PORT|Internal port the container listens on for http if it needs to be swapped from the default 3000.|
|CUSTOM_HTTPS_PORT|Internal port the container listens on for https if it needs to be swapped from the default 3001.|
|CUSTOM_USER|HTTP Basic auth username, abc is default.|
|PASSWORD|HTTP Basic auth password, abc is default. If unset there will be no auth|
|SUBFOLDER|Subfolder for the application if running a subfolder reverse proxy, need both slashes IE /subfolder/|
|TITLE|The page title displayed on the web browser, default "KasmVNC Client".|
|FM_HOME|This is the home directory (landing) for the file manager, default "/config".|
|START_DOCKER|If set to false a container with privilege will not automatically start the DinD Docker setup.|
|DRINODE|If mounting in /dev/dri for DRI3 GPU Acceleration allows you to specify the device to use IE /dev/dri/renderD128|
|LC_ALL|Set the Language for the container to run as IE fr_FR.UTF-8 ar_AE.UTF-8|
|NO_DECOR|If set the application will run without window borders for use as a PWA.|
|NO_FULL|Do not autmatically fullscreen applications when using openbox.|
#### 可选的运行配置
|Variable|Description|
|---|---|
|--privileged|Will start a Docker in Docker (DinD) setup inside the container to use docker in an isolated environment. For increased performance mount the Docker directory inside the container to the host IE -v /home/user/docker-data:/var/lib/docker.|
|-v /var/run/docker.sock:/var/run/docker.sock|Mount in the host level Docker socket to either interact with it via CLI or use Docker enabled applications.|
|--device /dev/dri:/dev/dri|Mount a GPU into the container, this can be used in conjunction with the DRINODE environment variable to leverage a host video card for GPU accelerated appplications. Only Open Source drivers are supported IE (Intel,AMDGPU,Radeon,ATI,Nouveau)|
## 用法
为了帮助您开始从此映像创建容器，您可以使用 docker-compose 或 docker cli。
### docker-compose(推荐)
```yaml
services:
  wechat:
    image: firephoenix/qq:latest
    container_name: wechat
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - LC_ALL=zh_CN.UTF-8
      - CUSTOM_USER=admin
      - PASSWORD=admin
      - DRINODE=/dev/dri/renderD128
    devices:
      - /dev/dri:/dev/dri
    volumes:
      - /data/docker-data/wechat/data:/config
    ports:
      - 3000:3000
      - 3001:3001
    shm_size: "4gb"
    restart: unless-stopped
    #network_mode: "host"
```
### docker cli
```yaml
docker run -d \
  --name=qq \
  --security-opt seccomp=unconfined `#optional` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e DRINODE=/dev/dri/renderD128 \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /data/docker-data/wechat/data:/config \
  --device /dev/dri:/dev/dri \
  --shm-size="4gb" \
  --restart unless-stopped \
  firephoenix/qq:latest
```
## 参数
容器是通过在运行时传递的参数（如上述所示）进行配置的。这些参数用冒号分隔，并分别表示`< external >:< internal >`。例如，`-p 8080:80` 将使容器内的80端口可以从容器外部的主机 IP 的8080端口上进行访问。
|Parameter|Function|
|---|---|
|-p 3000|Wechat desktop gui.|
|-p 3001|HTTPS Wechat desktop gui.|
|-e PUID=1000|for UserID - see below for explanation|
|-e PGID=1000|for GroupID - see below for explanation|
|-e TZ=Etc/UTC|specify a timezone to use, see this list.|
|-v /config|Users home directory in the container, stores local files and settings|
|--shm-size=|This is needed for any modern website to function like youtube.|
|--security-opt seccomp=unconfined|For Docker Engine only, many modern gui apps need this to function on older hosts as syscalls are unknown to Docker. Wechat runs in no-sandbox test mode without it.|
## 通过域名访问
### Nginx配置
```conf
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name qq.example.com;

    ssl_certificate /etc/nginx/ssl/example.com/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com/example.com.key;

    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    }

    location / {
        # WebSocket Support
        proxy_set_header        Upgrade $http_upgrade;
        proxy_set_header        Connection "upgrade";

        # Host and X headers
        proxy_set_header        Host $host;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;

        add_header 'Cross-Origin-Embedder-Policy' 'require-corp';
        add_header 'Cross-Origin-Opener-Policy' 'same-origin';
        add_header 'Cross-Origin-Resource-Policy' 'same-site';

        # Connectivity Options
        proxy_http_version      1.1;
        proxy_read_timeout      1800s;
        proxy_send_timeout      1800s;
        proxy_connect_timeout   1800s;
        proxy_buffering         off;
        proxy_pass http://127.0.0.1:3000;
    }
}
```
## 输入法
此镜像默认已安装中文语言包、fcitx5输入法框架、pinyin输入法, 使用`Left Shift`切换中英文输入法。

## 已知问题
- KasmVNC不能使用启用本地输入法选项

