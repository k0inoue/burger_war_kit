#!/bin/bash
set -e
set -x

# DEVELOPER_NAMEはdocker build時に置き換える
DEVELOPER_NAME=developer

# echo "HOST_USER_ID: ${HOST_USER_ID}"
# echo "HOST_GROUP_ID: ${HOST_GROUP_ID}"
# echo "RUN USER ID: $(id)"

if [ "$(id -u)" == "0" ]; then

  echo "/etc/passwd"
  cat /etc/passwd
  echo "/etc/group"
  cat /etc/group

  if [ "${HOST_USER_ID}" != "$(gosu ${DEVELOPER_NAME} id -u)" ]; then
    # ホストPCとUSER ID/GROUP IDを合わせる(ファイルアクセスできなくなる為)
    usermod -u ${HOST_USER_ID} -o -m -d /home/${DEVELOPER_NAME} ${DEVELOPER_NAME}
    groupmod -g ${HOST_GROUP_ID} ${DEVELOPER_NAME}
    chown -R ${DEVELOPER_NAME}:${DEVELOPER_NAME} /home/${DEVELOPER_NAME} /home/${DEVELOPER_NAME}/.*
  fi

  su - ${DEVELOPER_NAME}
  echo "RUN USER ID: $(id)"
fi

exec gosu ${DEVELOPER_NAME} "$@" 
