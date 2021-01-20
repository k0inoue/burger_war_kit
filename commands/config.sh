#----------------------------------------------------------
# Repository config values
#----------------------------------------------------------
# Dockerイメージを登録するレジストリのURL
REGISTRY_ROOT=ghcr.io
REGISTRY_URL=${REGISTRY_ROOT}/p-robotics-hub

# Dockerイメージ名
KIT_DOCKER_IMAGE_NAME=burger-war-kit

#----------------------------------------------------------
# Local config values
#----------------------------------------------------------
# 開発者ユーザー名
DEVELOPER_NAME=developer

# GitHubのPersonal access tokensを保存したファイルのパス
GITHUB_TOKEN_FILE=${HOME}/.github-token

# ワークスペースのrootディレクトリのパス
HOST_WS_DIR=${HOME}/catkin_ws

# コンテナ上のワークスペースディレクトリ
CONTAINER_WS_DIR=/home/${DEVELOPER_NAME}/catkin_ws

# ワークスペースのsrcディレクトリのパス
BURGER_WAR_KIT_DIR=${HOST_WS_DIR}/src/burger_war_kit

# ビルドするDockerfileパス
DOCKER_ROOT_DIR=${BURGER_WAR_KIT_DIR}/docker
KIT_DOCKER_FILE_PATH=${DOCKER_ROOT_DIR}/kit/Dockerfile

