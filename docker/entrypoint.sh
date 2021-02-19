#!/bin/bash
set -e

# DEVELOPER_NAMEはdocker build時に置き換える
DEVELOPER_NAME=developer

if [ "$(id -u)" == "0" ]; then

  echo "HOST_USER_ID: ${HOST_USER_ID}"
  echo "HOST_GROUP_ID: ${HOST_GROUP_ID}"

  echo "RUN USER ID: $(id)"
  echo "DEVELOPER ID: $(gosu ${DEVELOPER_NAME} id)"

  if [ "${HOST_USER_ID}" != "$(gosu ${DEVELOPER_NAME} id -u)" ]; then
    # ホストPCとUSER ID/GROUP IDを合わせる(ファイルアクセスできなくなる為)
    set -x
    echo "DEVELOPER ID1: $(gosu ${DEVELOPER_NAME} id)"
    usermod -u ${HOST_USER_ID} -o -m -d /home/${DEVELOPER_NAME} ${DEVELOPER_NAME}
    echo "DEVELOPER ID2: $(gosu ${DEVELOPER_NAME} id)"
    groupmod -g ${HOST_GROUP_ID} ${DEVELOPER_NAME}
    chown -R ${DEVELOPER_NAME}:${DEVELOPER_NAME} /home/${DEVELOPER_NAME}
    echo "DEVELOPER ID3: $(gosu ${DEVELOPER_NAME} id)"
    set +x
  fi

  su - ${DEVELOPER_NAME}
  echo "DEVELOPER ID4: $(gosu ${DEVELOPER_NAME} id)"
fi

exec gosu ${DEVELOPER_NAME} "$@" 
