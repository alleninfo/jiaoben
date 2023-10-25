#!/bin/bash


#
domain_flag=''
until [ "$domain_flag" != '' ]
do
    read -p "请输入域名: " input_domain
    echo "域名为: $input_domain"
    domain_flag=$(echo $input_domain | gawk '/^(http(s)?:\/\/)?[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+(:[0-9]{1,5})?$/{print $0}')
    if [ ! -n "${domain_flag}" ]; then
        echo "域名有误,请重新输入!!!"
    else
        mkdir -p /data/wwwroot/$input_domain
        echo '你的网站创建成功' > /data/wwwroot/$input_domain/index.php
        cp -a ./default.conf /data/nginx/conf/$input_domain.conf
        echo '你的网站创建成功'
        sed -i "s/server_name  _/server_name  $input_domain/" /data/nginx/conf/$input_domain.conf
        sed -i "s/default.access.log/$input_domain.access.log/" /data/nginx/conf/$input_domain.conf
        sed -i "s/\/usr\/share\/nginx\/html\/default/\/usr\/share\/nginx\/html\/$input_domain/" /data/nginx/conf/$input_domain.conf

done




