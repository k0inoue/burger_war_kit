#!/bin/bash
###############################################################################
#-burger-warのシミュレーションを実施する
#-
#+[USAGE]
#+  $0 [-j JudgeServerのURL] [-h] [シミュレータ起動待ちタイムアウト時間]
#+
#-[OPTIONS]
#-  -j URL        JudgeServerのURL(Default: http://localhost:5000/warState)
#-  -h            このヘルプを表示
#-
###############################################################################
set -e
set -u
CMD_NAME=$(basename $0)
SCRIPT_DIR=$(cd "$(dirname $0)"; pwd)
SIM_JUDGE_PID=
SIM_START_PID=
ROOT_PID=$$

# 設定
#------------------------------------------------
# ログ出力先ファイル
SIM_JUDGE_LOG="${HOME}/sim_with_judge_nogui.log"
SIM_START_LOG="${HOME}/start_test.log"
JUDGE_SERVER_ADDR=http://localhost:5000/warState

# 中断処理
#------------------------------------------------
cancel_user() {
  echo "user interrupt..."
  sleep 5
  exit 1
}
trap cancel_user SIGINT
timeout_exit() {
  echo "simulation statup timeout..."
  [ -n "${SIM_JUDGE_PID}" ] && echo JUDGE_PID:${SIM_JUDGE_PID} && killpstree ${SIM_JUDGE_PID}
  [ -n "${SIM_START_PID}" ] && echo START_PID:${SIM_START_PID} && killpstree ${SIM_START_PID}
  sleep 5
  exit 1
}
trap cancel_exit SIGHUP SIGQUIT SIGTERM

# 関数定義
#------------------------------------------------
usage_exit() {
  # ファイル冒頭のコメントからUSAGEを出力
  sed '/^[^#]/q' "$0"             \
  | sed -n '/^#+/s/^#+//p'        \
  | sed "s/\$0/${CMD_NAME}/g"     1>&2
  exit 1
}
help_exit() {
  # ファイル冒頭のコメントからヘルプを出力
  sed '/^[^#]/q' "$0"             \
  | sed -n '/^#[-+]/s/^#[-+]//p'  \
  | sed "s/\$0/${CMD_NAME}/g"     1>&2
  exit 0
}
killpstree(){
  # 指定PIDのプロセスをKILLする
  local children=$(ps --ppid $1 --no-heading | sed "s/^ //" | awk '{ print $1 }')
  for child in $children
  do
      killpstree $child
  done
  if [ "$1" != "${ROOT_PID}" ]; then
    echo "KILL SIGINT --> $1"
    sudo kill -INT $1
  fi
}

# オプション・引数解析
#------------------------------------------------
BUILD_OPTION=
IMAGE_VERSION=latest
while getopts j:h OPT
do
  case $OPT in
    j  ) # JudgeServerのURLを指定
      JUDGE_SERVER_ADDR=$OPTARG
      ;;
    h  ) # ヘルプの表示
      help_exit
      ;;
    \? ) # 不正オプション時のUSAGE表示
      usage_exit
      ;;
  esac
done
shift $((OPTIND - 1))

# タイムアウト時間
TIMEOUT_SECOND=${1:-30}

# テスト実施
#------------------------------------------------
# 終了時のメッセージと状態を出力
echo "==============================================================================="
echo " Simulation Start"
echo "==============================================================================="
# シミュレータ起動
(bash ${SCRIPT_DIR}/sim_with_judge_nogui.sh > "${SIM_JUDGE_LOG}" 2>&1) &
SIM_JUDGE_PID=$!

# judgeサーバーが立ち上がるまでの仮待機(時間は要調整)
sleep 5

# シミュレーター起動(ロボット準備)待ち
while :
do
  sleep 1
  ready_count=$(curl -s ${JUDGE_SERVER_ADDR} | jq .ready[] | grep -c 'true' && :)
  echo REDAY_COUNT: $ready_count
  if [ ${ready_count} -eq 2 ]; then
    # 2台ともready=trueになったら、準備完了と見なす
    echo SUCCESS: simulator is running ...
    break
  elif [ ${TIMEOUT_SECOND} -eq 0 ]; then
    # タイムアウト
    echo ERROR: simulator is not running ...
    kill -QUIT ${ROOT_PID}
  fi
  TIMEOUT_SECOND=$((TIMEOUT_SECOND - 1)) 
done

sleep 5

# シミュレーション開始
(bash ${SCRIPT_DIR}/start_test.sh  > "${SIM_START_LOG}" 2>&1) &
SIM_START_PID=$!

sleep 1

# シミュレーション終了待ち
TIMEOUT_SECOND=250
while [ ${TIMEOUT_SECOND} -ne 0 ]
do
  curl -s ${JUDGE_SERVER_ADDR} | jq -c '. | { time:.time, state:.state, ready:.ready, scores:.scores }'
  sleep 1
  if ! ( curl -s ${JUDGE_SERVER_ADDR} | jq .state | grep -c 'running' > /dev/null ) ; then
    # シミュレーション状態が実施中以外になった場合、終了
    break
  fi
  TIMEOUT_SECOND=$((TIMEOUT_SECOND - 1))
done

#killpstree ${SIM_START_PID}

# 得点取得
BLUE_POINT=$( curl -s ${JUDGE_SERVER_ADDR} | jq .scores.b )
RED_POINT=$( curl -s ${JUDGE_SERVER_ADDR} | jq .scores.r )

# 終了時のメッセージと状態を出力
echo "==============================================================================="
echo " Simulation Finished!"
echo "-------------------------------------------------------------------------------"
echo "   SCORE (blue vs red): ${BLUE_POINT} vs ${RED_POINT}"
echo "==============================================================================="

# 子プロセスを落とす
killpstree ${SIM_START_PID}
killpstree ${SIM_JUDGE_PID}

# 親プロセス(本スクリプト)が早く落ちすぎて子プロセスがゾンビプロセスとして残るため、少し待機
sleep 8

# テストPASS
exit 0
