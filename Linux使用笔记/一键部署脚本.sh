#!/bin/bash

PYTHON_COMPILE="/Users/yzj/anaconda3/bin/python"
PYTHON_SCRIPT="pyc_process.py"

ZIPFILE="nlpservice.zip"
ZIPFOLDER="nlpservice"
CPFOLDER="nlpservice_CP"
DEPLOYFLODER="service_deployment"

CP_FILES_DIRS="./nlpservice/nlpservice
               ./nlpservice/service_deployment
               ./nlpservice/bin
               ./nlpservice/config
               ./nlpservice/README.md
               ./nlpservice/start_xiaok.py
               ./nlpservice/requirements.txt
               ./nlpservice/calfdata
               ./nlpservice/calfnlp
               "

ZIP_FILES_DIRS="./nlpservice_CP/nlpservice/
               ./nlpservice_CP/bin
               ./nlpservice_CP/config
               ./nlpservice_CP/README.md
               ./nlpservice_CP/start_xiaok.py
               ./nlpservice_CP/requirements.txt
               ./nlpservice_CP/calfdata
               ./nlpservice_CP/calfnlp
               "

# 注意这个路径是复制目录的路径，千万别搞错了，不然会把你原项目的源代码给编译成pyc的
PYC_COMPILE_PATH="/Users/yzj/lefugang/yzj_Calf/"${CPFOLDER}"/src"

# dv_test
USER="kduser"
IP="172.18.8.35"
PASSWORD="Kingdee@2018"
SCP_PATH="/var/fugang_le"
PROJECT_FOLDER="nlpservice"
RUN="cd .."

# dv_test
#USER="kduser"
#IP="172.18.8.117"
#PASSWORD="Kingdee@2019"
#SCP_PATH="/var/fugang_le"
#PROJECT_FOLDER="nlpservice"
#RUN="cd .."

# kd_test
#USER="yzj"
#IP="10.247.17.22"
#PASSWORD="XMKuai@2064"
#SCP_PATH="/kingdee/lefugang/yzj_calf"
#PROJECT_FOLDER="ai-intent_recognition"
#RUN="cd .."

# product
#USER="yzj"
#IP="10.247.10.131"
#PASSWORD="XMKuai@2064"
#SCP_PATH="/kingdee/lefugang/yzj_calf"
#PROJECT_FOLDER="ai-intent_recognition"
#RUN="cd .."


cd ../..
echo 'copying ......'

mkdir ${CPFOLDER}
cp -R ${CP_FILES_DIRS} ${CPFOLDER}

cd ${CPFOLDER}/${DEPLOYFLODER}
#${PYTHON_COMPILE} ${PYTHON_SCRIPT} ${PYC_COMPILE_PATH}

cd ../..
echo 'zipping ......'
zip -r ${ZIPFILE} ${ZIP_FILES_DIRS}

_CURRENTPATH=$(pwd)

# 传输项目至服务器
expect -c "
spawn scp -r ${_CURRENTPATH}/${ZIPFILE} ${USER}@${IP}:${SCP_PATH}
expect {
\"*assword\" {set timeout 300; send \"${PASSWORD}\n\";}
\"yes/no\" {send \"yes\r\"; exp_continue;}
}
expect eof"


# 服务器端处理
expect -c "
spawn ssh ${USER}@${IP}
expect {
\"yes/no\" {send \"yes\r\";exp_continue }
\"password:\" {set timeout 60; send \"${PASSWORD}\r\";}
}
expect \"]# \"
send \"cd  ${SCP_PATH} \r\"
send \"unzip ${ZIPFILE} \r\"
send \"cp -rf ./${CPFOLDER}/. ./${PROJECT_FOLDER} \r\"
send \"rm -rf ${CPFOLDER} \r\"
send \"rm -rf ${ZIPFILE} \r\"
send \"cd ./${PROJECT_FOLDER} \r\"
send \"${RUN} \r\"
send \"exit \r\"

expect eof"

rm -rf ${ZIPFILE}
rm -rf ${CPFOLDER}

echo "finish!!!"