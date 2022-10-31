ARG IMAGE=mcr.microsoft.com/mssql/server:2019-GDR2-ubuntu-16.04
FROM $IMAGE
USER 0:0
ARG CD_SA_PASSWORD

LABEL maintainer="brandonmcclure89@gmail.com" Description="A POC SQl image to store some data"
RUN apt-get update 


USER 10001:0

COPY --chown=10001:0 entrypoint.sh /usr/bin
COPY --chown=10001:0 init.sh /usr/bin
COPY --chown=10001:0 init.sql /mnt/init.sql

ENV ACCEPT_EULA="Y"
ENV SA_PASSWORD=$CD_SA_PASSWORD
 
 EXPOSE 1433
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=10 \
   CMD /opt/mssql-tools/bin/sqlcmd -S localhost -d master -V16 -U sa -P $SA_PASSWORD -Q "SELECT 1" || exit 1


CMD /bin/bash /usr/bin/entrypoint.sh