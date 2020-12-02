FROM amazon/aws-cli:2.0.26

WORKDIR /app

ARG _HOME_DIR_NAME=fp-aws-log-import-service
ENV _HOME_DIR_NAME=${_HOME_DIR_NAME}

COPY container-files container-files/

RUN yum install -y cronie rsync tar \
    && chkconfig crond on \
    && mkdir -p /forcepoint-logs/initial/pa ${_HOME_DIR_NAME}/logs \
    && tar -zxvf container-files/${_HOME_DIR_NAME}-v*.tar.gz \
    && rm -f container-files/${_HOME_DIR_NAME}-v*.tar.gz \
    && chmod 700 container-files/entrypoint.sh \
    ${_HOME_DIR_NAME}/scripts/start-sync-process-crond.sh \
    ${_HOME_DIR_NAME}/scripts/sync-process-util.sh \
    ${_HOME_DIR_NAME}/scripts/start-sync-todays-logs.sh \
    ${_HOME_DIR_NAME}/scripts/clean-logs.sh 
    
ENTRYPOINT ["./container-files/entrypoint.sh"]
