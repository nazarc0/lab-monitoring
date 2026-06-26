# Dockerfile
# --- беремо готові бінарники з офіційних образів ---
FROM prom/prometheus:latest AS prometheus
FROM prom/alertmanager:latest AS alertmanager
FROM prom/node-exporter:latest AS nodeexp
FROM gcr.io/cadvisor/cadvisor:latest AS cadvisor
FROM grafana/grafana:latest AS grafana
# --- фінальний образ ---
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y supervisor ca-certificates && rm -rf var/lib/apt/lists/*
# копіюємо бінарники
COPY --from=prometheus /bin/prometheus /bin/prometheus
COPY --from=alertmanager /bin/alertmanager /bin/alertmanager
COPY --from=nodeexp /bin/node_exporter /bin/node_exporter
COPY --from=cadvisor /usr/bin/cadvisor /usr/bin/cadvisor
COPY --from=grafana / /grafana-root 
# конфіги
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY alert.rules.yml /etc/prometheus/alert.rules.yml
COPY alertmanager.yml /etc/alertmanager/alertmanager.yml
COPY supervisord.conf /etc/supervisord.conf
EXPOSE 3000 9090 9093 9100 8080
CMD ["supervisord", "-c", "/etc/supervisord.conf"]