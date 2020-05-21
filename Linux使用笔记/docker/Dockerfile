# 拉取基础环境镜像
FROM java:8
# 定义工作目录
VOLUME /tmp
# 添加工程文件
ADD *.jar app.jar
# 中文时间
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo 'Asia/Shanghai' >/etc/timezone
# 添加执行脚本
ADD ./run.sh /tmp
# 赋予执行权限
RUN chmod a+x /tmp/run.sh
# 暴露应用端口
ENV SERVER_PORT="8888"
# 执行脚本
ENTRYPOINT [ "sh", "-c", "/tmp/run.sh" ]