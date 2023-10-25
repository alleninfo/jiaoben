#!/bin/bash


## install docker

sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

yum makecache
function docker_install()
{
	echo "检查Docker......"
	docker -v
    if [ $? -eq  0 ]; then
        echo "检查到Docker已安装!"
		echo "开始安装PHP环境"
		php_install
		
		
		
		
		
    else
    	echo "安装docker环境..."
        yum install -y yum-utils
		yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 
		yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
		systemctl start docker && systemctl enable docker

		curl -SL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
		ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        echo "安装docker环境...安装完成!"
    fi
	php_install
    # 创建公用网络==bridge模式
    #docker network create share_network
}
 
function php_install()
{
		mkdir -p /data/{nginx/{conf,rewrite},wwwroot,wwwlogs}
		echo "开始安装MySQL!"
		docker run -itd \
			  -d \
			  -p 3306:3306 \
			  -e MYSQL_ROOT_PASSWORD=12345678910 \
			  --name m_mysql mysql:5.7
		echo "MySQL安装完毕,Mysql初始密码：12345678910"
		echo "开始安装PHP!"
		docker run -itd \
			  -d \
			  -p 9000:9000 \
			  -v /data/wwwroot:/usr/share/nginx/html \
			  --link m_mysql:mysql \
			  --name m_phpfpm bitnami/php-fpm:8.0
		echo "PHP安装完毕!"
		echo "开始安装Nginx!"
		docker run  \
			  -d \
			  -p 80:80 \
			  --name m_nginx nginx:1.12
		docker cp m_nginx:/etc/nginx/nginx.conf /data/nginx
		docker cp m_nginx:/etc/nginx/conf.d/default.conf /data/nginx/conf
		docker stop m_nginx && docker rm m_nginx
		docker run -itd \
			  -d \
			  -p 80:80 \
			  -v /data/wwwroot:/usr/share/nginx/html \
			  -v /data/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
			  -v /data/nginx/conf:/etc/nginx/conf.d \
			  -v /data/wwwlogs:/var/log/nginx \
			  --link m_phpfpm:phpfpm \
			  --name m_nginx nginx:1.12
		echo "===============安装完成=============="
		
}
 
# 执行函数
docker_install





