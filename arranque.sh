#!/bin/bash
set -euo pipefail

# Instalar los servicios necesarios desde los repositorios de Debian.
apt-get update -y
apt-get install -y nginx python3 curl

# Obtener la IP interna de esta máquina.
IP_APP=$(curl -fsS -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

# Crear la aplicación que consultará al servidor privado.
mkdir -p /opt/aplicacion

cat > /opt/aplicacion/app.py <<'PY'
#!/usr/bin/env python3

import html
import json
import os
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

IP_APP = os.environ.get("IP_APP", "no disponible")

# Terraform sustituirá ip_datos por la IP interna real de la máquina privada.
DATOS_URL = "http://${ip_datos}:8080/datos.json"


class Aplicacion(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/":
            self.send_error(404)
            return

        try:
            # Se consulta la máquina privada en cada solicitud.
            with urllib.request.urlopen(DATOS_URL, timeout=5) as respuesta:
                datos = json.load(respuesta)

            origen = html.escape(datos["origen"])
            mensaje = html.escape(datos["mensaje"])

            pagina = f"""<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Práctica 3 - Nelson Conde</title>
</head>
<body>
    <h1>Nelson Conde</h1>
    <p>Servidor de aplicación. IP interna: {html.escape(IP_APP)}</p>
    <h2>Dato obtenido de la máquina privada</h2>
    <p>Origen: {origen}</p>
    <p>{mensaje}</p>
</body>
</html>"""

            contenido = pagina.encode("utf-8")

            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(contenido)))
            self.end_headers()
            self.wfile.write(contenido)

        except Exception:
            # Si la máquina privada no responde, no se sirve la página normal.
            contenido = b"Error: el servidor privado no responde."

            self.send_response(502)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Content-Length", str(len(contenido)))
            self.end_headers()
            self.wfile.write(contenido)


ThreadingHTTPServer(("127.0.0.1", 8000), Aplicacion).serve_forever()
PY

# Mantener la aplicación funcionando como servicio del sistema.
cat > /etc/systemd/system/aplicacion.service <<SERVICE
[Unit]
Description=Aplicacion web de la practica 3
After=network-online.target
Wants=network-online.target

[Service]
Environment=IP_APP=$IP_APP
ExecStart=/usr/bin/python3 /opt/aplicacion/app.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now aplicacion.service

# Nginx recibe las solicitudes públicas y las entrega a la aplicación.
cat > /etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_connect_timeout 5s;
        proxy_read_timeout 8s;
    }
}
NGINX

nginx -t
systemctl enable nginx
systemctl restart nginx