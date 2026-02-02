#!/bin/bash
set -e

# 基础路径
BASE_DIR="/app"
DATE=$(date +%m%d)
DEPLOY_DIR="$BASE_DIR/deploy"

# 服务映射表：包名 => 服务名、类型、目标目录、解压目录（前端）
declare -A SERVICE_MAP=(
  [gateway.jar]="gateway:backend:$BASE_DIR/gateway:gateway.jar:"
  [login.zip]="login:frontend:$BASE_DIR/login:login.zip:login"
)

# 1. 收集需要部署的服务
SERVICES=()
for pkg in $(ls $DEPLOY_DIR); do
  if [[ -n "${SERVICE_MAP[$pkg]}" ]]; then
    svc_name=$(echo ${SERVICE_MAP[$pkg]} | cut -d: -f1)
    SERVICES+=("$svc_name")
  fi
done

# 2. 停止服务
echo "Stopping services: ${SERVICES[*]}"
docker compose stop ${SERVICES[*]}

# 3. 逐个处理包
for pkg in $(ls $DEPLOY_DIR); do
  conf="${SERVICE_MAP[$pkg]}"
  if [[ -z "$conf" ]]; then
    echo "Unknown package: $pkg, skip."
    continue
  fi
  svc_name=$(echo $conf | cut -d: -f1)
  svc_type=$(echo $conf | cut -d: -f2)
  svc_dir=$(echo $conf | cut -d: -f3)
  target_file=$(echo $conf | cut -d: -f4)
  extract_dir=$(echo $conf | cut -d: -f5)

  echo "Processing $pkg for $svc_name ($svc_type)"
  cd $svc_dir

  # 3.1 备份
  if [[ -f $target_file ]]; then
    cp $target_file ${target_file}.${DATE}.bak
    # 保留5个备份
    ls -1t ${target_file}.*.bak 2>/dev/null | tail -n +6 | xargs -r rm -f
  fi

  # 3.2 删除原包
  rm -f $target_file
  if [[ "$svc_type" == "frontend" && -n "$extract_dir" ]]; then
    rm -rf $extract_dir
  fi

  # 3.3 拷贝新包
  cp $DEPLOY_DIR/$pkg $target_file

  # 3.4 解压（前端）
  if [[ "$svc_type" == "frontend" && -n "$extract_dir" ]]; then
    unzip -o $target_file -d $extract_dir
  fi

  cd - >/dev/null
done

# 4. 启动服务
echo "Starting services: ${SERVICES[*]}"
docker compose up -d ${SERVICES[*]}

echo "Deploy done." 