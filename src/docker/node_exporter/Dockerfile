FROM prom/node-exporter
VOLUME /mnt/prom
CMD ["--collector.disable-defaults", "--collector.textfile","--collector.textfile.directory","/mnt/prom"]