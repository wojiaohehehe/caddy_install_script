# caddy_install_script


## Caddy 一键安装脚本
参考 1. 233boy一键安装脚本*https://github.com/233boy/v2ray/tree/master*  
     2. caddy 官方systemd配置 *https://github.com/caddyserver/caddy/tree/master/dist/init/linux-systemd*  
     3. 其他一键安装脚本 *https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/caddy_install.sh*  

## 功能
   文件安装位置  /usr/local/bin/caddy  
   Caddyfile   /etc/caddy/Caddyfile  
   配置文件默认为 websocket反向代理，请自行修改Caddyfile文件,[官方文档](https://caddyserver.com/v1/tutorial)，然后执行  `systemctl restart caddy.service`  
   
## 基本操作
  1. 查看caddy服务  `systemctl status caddy.service`  
  2. 重启caddy服务  `systemctl restart caddy.service`  
