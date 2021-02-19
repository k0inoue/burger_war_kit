#!/bin/bash
set -e

# DEVELOPER_NAMEはdocker build時に置き換える
DEVELOPER_NAME=developer

if [ "$(id -u)" == "0" ]; then

  echo "RUN USER ID: $(id)"
  echo "DEVELOPER ID: $(gosu ${DEVELOPER_NAME} id)"

  if [ "${HOST_USER_ID}" != "$(gosu ${DEVELOPER_NAME} id -u)" ]; then
    # ホストPCとUSER ID/GROUP IDを合わせる(ファイルアクセスできなくなる為)
    usermod -u ${HOST_USER_ID} -o -m -d /home/${DEVELOPER_NAME} ${DEVELOPER_NAME}
    groupmod -g ${HOST_GROUP_ID} ${DEVELOPER_NAME}
    chown -R ${HOST_USER_ID}:${HOST_GROUP_ID} /home/${DEVELOPER_NAME} /home/${DEVELOPER_NAME}/.*
  fi
  echo "DEVELOPER ID: $(gosu ${DEVELOPER_NAME} id)"

  su - ${DEVELOPER_NAME}
fi

exec gosu ${DEVELOPER_NAME} "$@" 
