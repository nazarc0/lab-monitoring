# Беремо офіційні образи
FROM prom/prometheus:latest AS prom
FROM prom/alertmanager:latest AS am
FROM prom/node-exporter:latest AS nodeexp
FROM grafana/grafana:latest AS grafana

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y supervisor ca-certificates libc6 && rm -rf /var/lib/apt/lists/*

# Копіюємо бінарники
COPY --from=prom /bin/prometheus /usr/bin/prometheus
COPY --from=am /bin/alertmanager /usr/bin/alertmanager
COPY --from=nodeexp /bin/node_exporter /usr/bin/node_exporter

# Копіюємо Grafana та створюємо посилання
COPY --from=grafana /usr/share/grafana /usr/share/grafana
# Створюємо посилання на бінарник у місце, яке бачить система
RUN ln -s /usr/share/grafana/bin/grafana /usr/bin/grafana-server

# Створюємо директорії для логів та даних
RUN mkdir -p /etc/prometheus /etc/alertmanager /var/lib/prometheus /var/log/grafana /var/lib/grafana

# Копіюємо конфіги
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY alert.rules.yml /etc/prometheus/alert.rules.yml
COPY alertmanager.yml /etc/alertmanager/alertmanager.yml
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 3000 9090 9093 9100
CMD ["supervisord", "-c", "/etc/supervisord.conf"]