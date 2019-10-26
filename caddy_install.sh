#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#==================:===============================
#       System Required: CentOS/Debian/Ubuntu
#       Description: Caddy Install       
#=================================================

Info_font_prefix="\033[32m" && Error_font_prefix="\033[31m" && Info_background_prefix="\033[42;37m" && Error_background_prefix="\033[41;37m" && Font_suffix="\033[0m"
systemd=true

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
check_sys(){
	sys_bit=$(uname -m)
    case $sys_bit in
    i[36]86)
        v2ray_bit="32"
        release="386"
        ;;
    x86_64)
        v2ray_bit="64"
        release="amd64"
        ;;
    *armv6*)
        v2ray_bit="arm"
        release="arm6"
        ;;
    *armv7*)
        v2ray_bit="arm"
        release="arm7"
        ;;
    *aarch64* | *armv8*)
        v2ray_bit="arm64"
        release="arm64"
        ;;
    *)
        echo -e " 
        哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}
        备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
        " && exit 1
        ;;
    esac
}
download_caddy_file() {
    rm -rf /tmp/install_caddy
	caddy_tmp="/tmp/install_caddy/"
	caddy_tmp_file="/tmp/install_caddy/caddy.tar.gz"
	[[ -d $caddy_tmp ]] && rm -rf $caddy_tmp
	if [[ ! ${release} ]]; then
		echo -e "$red 获取 Caddy 下载参数失败！$none" && exit 1
	fi
	local caddy_download_link="https://caddyserver.com/download/linux/${release}?license=personal"

	mkdir -p $caddy_tmp

	if ! wget --no-check-certificate -O "$caddy_tmp_file" $caddy_download_link; then
		echo -e "$red 下载 Caddy 失败！$none" && exit 1
	fi

	tar zxf $caddy_tmp_file -C $caddy_tmp
	cp -f ${caddy_tmp}caddy /usr/local/bin/

	# wget -qO- https://getcaddy.com | bash -s personal

	if [[ ! -f /usr/local/bin/caddy ]]; then
		echo -e "$red 安装 Caddy 出错！$none" && exit 1
	fi
}
install_caddy_service() {
    if ! [ -x "$(command -v setcap)" ]; then
        apt-get update && apt-get install libcap2-bin
    fi
	setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/caddy

	if [[ $systemd ]]; then
        # 这里是从官方，下载Caddy的systemd文件 ref https://github.com/caddyserver/caddy/tree/master/dist/init/linux-systemd
		if ! wget https://raw.githubusercontent.com/caddyserver/caddy/master/dist/init/linux-systemd/caddy.service -O /lib/systemd/system/caddy.service; then
			echo -e "$red 下载 caddy.service 失败！$none" && exit 1
		fi
		systemctl enable caddy
	else
		cp -f ${caddy_tmp}init/linux-sysvinit/caddy /etc/init.d/caddy
		# sed -i "s/www-data/root/g" /etc/init.d/caddy
		chmod +x /etc/init.d/caddy
		update-rc.d -f caddy defaults
	fi

	if [ -z "$(grep www-data /etc/passwd)" ]; then
		useradd -M -s /usr/sbin/nologin www-data
	fi

	mkdir -p /etc/caddy
	chown -R root:root /etc/caddy
	mkdir -p /etc/ssl/caddy
	chown -R root:www-data /etc/ssl/caddy
	chmod 0770 /etc/ssl/caddy

	## create sites dir
	mkdir -p /etc/caddy/sites
    mkdir -p /var/www
    chown www-data:www-data /var/www
    chmod 555 /var/www

    local email=$(((RANDOM << 22)))
    cat >/etc/caddy/Caddyfile <<-EOF
caddy_install.com {
	tls /etc/v2ray/cf.crt /etc/v2ray/cf.key
	gzip
    		timeouts none
    	proxy /https://cn.bing.com {
        	except /v2ice
    	}
    	proxy /v2ice 127.0.0.1:9000 {
        	without /v2ice
        	websocket
    	}
}
import sites/*
EOF
}

check_sys
download_caddy_file
install_caddy_service
