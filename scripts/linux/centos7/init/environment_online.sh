#!/bin/bash
export LANG=en_US.UTF-8

function up_conf(){

    sed -i "s#$1$4.*#$1$4$2#g" $3
}

function init_sysctl(){

    vm_c=$(grep -c "$1" /etc/sysctl.conf)
    if [ $vm_c -eq 0 ];then

        echo "新增配置: $1"
        echo -e "\n$1 = $2" >> /etc/sysctl.conf
    else

        echo "修改配置: $1"
        up_conf "$1" "$2" "/etc/sysctl.conf" "="
    fi
    sysctl -p 1>>../init.log
}


# 初始化'vm.max_map_count'
init_sysctl "vm.max_map_count" "262144"

# 初始化'vm.overcommit_memory'
init_sysctl "vm.overcommit_memory" "1"


#更新yum包
yum update -y
#安装依赖包
yum install yum-utils device-mapper-persistent-data lvm2 -y
#安装依赖命令
yum install vim -y
yum install sshpass -y
yum install net-tools -y
yum install zip -y
yum install unzip -y

#删除旧版本docker（如果有的话）
echo "y" | yum remove docker  docker-common docker-selinux docker-engine
#添加yum 源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
#查看仓库中的docker版本
yum list docker-ce --showduplicates | sort -r
#Centos 7安装docker 
yum install docker-ce-3:26.1.4-1.el7.x86_64 -y
#启动docker
systemctl start docker
#设置docker开机启动
systemctl enable docker

#查找容量最大挂载点 
echo "查找容量最大挂载点"
MAX_PATH=`df -T | grep -vE 'tmpfs|devtmpfs' | sort -k3 -n | tail -1 | awk '{print $NF}'`

#创建docker的存储目录
echo "创建docker的存储目录"
DOCKER_PATH=""
if [[ "$MAX_PATH" = "/" ]];then
    DOCKER_PATH="/data/docker"
elif [ -z $MAX_PATH ];then
    while true
    do
        read -p "请输入Docker容器镜像存放位置 (默认/data/docker): " DOCKER_PATH
        if [ -z "$DOCKER_PATH" ];then
            DOCKER_PATH="/data/docker";
        fi
        if [ $? -eq 0 ]; then
            break
        else
            echo "创建$DOCKER_PATH目录失败，目录格式或权限不够。"
        fi
    done
else
    DOCKER_PATH=$MAX_PATH"/docker"
fi

mkdir -p $DOCKER_PATH

#设置docker配置
echo "设置docker配置"
mkdir -p /etc/docker
echo "{
        \"data-root\":\"$DOCKER_PATH\",
        \"registry-mirrors\":[\"https://registry.docker-cn.com\"],
        \"log-opts\": {\"max-size\": \"1024m\",\"max-file\": \"3\"}
}" > /etc/docker/daemon.json

#重新加载配置参数
systemctl daemon-reload

#重新启动docker服务
systemctl start docker

#设置开机自启动
systemctl enable docker.service