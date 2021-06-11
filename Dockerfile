FROM openjdk:8-jdk-alpine as build
WORKDIR /workspace/app

COPY backend/target/backend-1.9.jar .

RUN mkdir -p dependency && (cd dependency; jar -xf ../*.jar)

FROM metersphere/fabric8-java-alpine-openjdk8-jre

MAINTAINER FIT2CLOUD <support@fit2cloud.com>

ARG MS_VERSION=dev
ARG DEPENDENCY=/workspace/app/dependency

COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

RUN mkdir -p /opt/jmeter/lib/junit
COPY backend/target/classes/jmeter/ /opt/jmeter/

ENV JAVA_CLASSPATH=/app:/app/lib/*
ENV JAVA_MAIN_CLASS=io.metersphere.Application
ENV AB_OFF=true
ENV MS_VERSION=${MS_VERSION}
ENV JAVA_OPTIONS="-Dfile.encoding=utf-8 -Djava.awt.headless=true"

CMD ["/deployments/run-java.sh"]
