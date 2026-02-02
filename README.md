# grace-env

用于快速初始化本地开发环境与 Linux 服务器环境的项目骨架，提供 Docker 初始化脚本、基础设施/中间件与应用示例的 Docker Compose、以及快速更新脚本与配置示例。

## 设计目标
| 目标 | 说明 |
| --- | --- |
| 本地 + 服务器 | 覆盖本地开发与 Linux 服务器环境的快速初始化。 |
| 组件解耦 | 将基础设施（CI/CD 等）与中间件、应用示例分层，便于独立部署。 |
| 维护友好 | 脚本与 Compose 分层清晰，便于扩展与维护。 |

## 目录说明
| 目录 | 用途 | 说明 |
| --- | --- | --- |
| `docker/app/` | 应用示例 | 网关/登录/反向代理的 Compose 与 Nginx 配置示例。 |
| `docker/infra/` | 基础设施 | GitLab、Nexus 等 CI/CD 服务的 Compose。 |
| `docker/middleware/` | 中间件 | MySQL、Redis、Nacos、MinIO、Postgres 等 Compose 与配置。 |
| `scripts/linux/centos7/init/` | 初始化脚本 | CentOS7 安装/配置 Docker 与系统参数初始化脚本。 |
| `scripts/linux/centos7/update/` | 更新脚本 | 服务包快速替换与重启脚本。 |
| `env/` | 环境模板 | 本地/服务器环境变量模板目录（按需补充）。 |
