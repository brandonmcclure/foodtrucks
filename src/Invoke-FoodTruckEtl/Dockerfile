FROM bmcclure89/fc_powershell:main

RUN echo 'cd /src' >> /opt/microsoft/powershell/7-lts/profile.ps1
COPY Get-ETLConfig.ps1 /src/Get-ETLConfig.ps1
COPY Invoke-FoodTruckEtl.ps1 /src/Invoke-FoodTruckEtl.ps1

WORKDIR /src
VOLUME /mnt/prom
