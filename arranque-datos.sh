#!/bin/bash
set -e

# Instalar Python desde los repositorios de Debian.
apt-get update -y
apt-get install -y python3

# Preparar el contenido que consultará la máquina de aplicación.
mkdir -p /opt/datos

cat > /opt/datos/datos.json <<'JSON'
{
  "origen": "servidor privado",
  "mensaje": "La comunicación interna entre las dos máquinas funciona"
}
JSON

# Crear un servicio que atienda solicitudes HTTP en el puerto 8080.
cat > /etc/systemd/system/servidor-datos.service <<'SERVICE'
[Unit]
Description=Servicio HTTP de datos privados
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 8080 --bind 0.0.0.0 --directory /opt/datos
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE

# Activar e iniciar el servicio.
systemctl daemon-reload
systemctl enable --now servidor-datos.service