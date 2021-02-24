#!/bin/bash
set -e
set -x

# check arg num
if [ $# -ne 2 ]; then
    RED_NAME="you"
    BLUE_NAME="enemy"
else
    RED_NAME=$1
    BLUE_NAME=$2
fi


# judge
# run judge server and visualize window
(python judge/judgeServer.py)&
sleep 1
(python judge/JudgeWindow.py -t >/dev/null 2>&1)&

# init judge server for sim setting
bash judge/test_scripts/init_single_play.sh judge/marker_set/sim.csv localhost:5000  $RED_NAME $BLUE_NAME

# robot
roslaunch burger_war setup_sim.launch gui:=true record:=true


