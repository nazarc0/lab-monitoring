# Dockerfile
# --- беремо готові бінарники з офіційних образів ---
FROM prom/prometheus:latest AS prometheus
FROM prom/alertmanager:latest AS alertmanager
FROM prom/node-exporter:latest AS nodeexp
#FROM ghcr.io/google/cadvisor:latest AS cadvisor
FROM grafana/grafana:latest AS grafana
# --- фінальний образ ---
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y supervisor ca-certificates && rm -rf /var/lib/apt/lists/*
# копіюємо бінарники
COPY --from=prometheus /bin/prometheus /bin/prometheus
COPY --from=alertmanager /bin/alertmanager /bin/alertmanager
COPY --from=nodeexp /bin/node_exporter /bin/node_exporter
#COPY --from=cadvisor /usr/bin/cadvisor /usr/bin/cadvisor
COPY --from=grafana / /grafana-root

ENV GF_PATHS_CONFIG=/grafana-root/etc/grafana/grafana.ini \
    GF_PATHS_DATA=/grafana-root/var/lib/grafana \
    GF_PATHS_HOME=/grafana-root/usr/share/grafana \
    GF_PATHS_LOGS=/grafana-root/var/log/grafana \
    GF_PATHS_PLUGINS=/grafana-root/var/lib/grafana/plugins \
    GF_PATHS_PROVISIONING=/grafana-root/etc/grafana/provisioning \
    PATH="/grafana-root/usr/share/grafana/bin:${PATH}"

RUN mkdir -p /grafana-root/var/lib/grafana /grafana-root/var/log/grafana

# конфіги
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY alert.rules.yml /etc/prometheus/alert.rules.yml
COPY alertmanager.yml /etc/alertmanager/alertmanager.yml
COPY supervisord.conf /etc/supervisord.conf
EXPOSE 3000 9090 9093 9100 8080
CMD ["supervisord", "-c", "/etc/supervisord.conf"]



