#!/usr/bin/env bash
java  -jar -Djava.security.egd=file:/dev/./urandom /app.jar \
    --server.port=$SERVER_PORT
