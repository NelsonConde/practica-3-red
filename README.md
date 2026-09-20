# Práctica 3. Una red propia, dos máquinas y una aplicación

## 1. Identificación

**Integrantes:** Nelson Conde, Yoset Piedrahita y Jose Peres

**Proyecto de Google Cloud:** `project-dbb36c67-9183-4c5d-aff`

## 2. Diagrama de la infraestructura

## 3. Evidencias

### Evidencia 0. Preparación del entorno

![Versión de Terraform y configuración de Google Cloud](docs/evidencias/fase-00-preparacion/01-entorno.png)

### Fase 1. La red y su subred

**Evidencia 1.** Lista de subredes con nombre, región y rango, y resultado del `terraform apply` con los dos recursos creados.

![Creación de la red y la subred con Terraform](docs/evidencias/fase-01-red/01-terraform-apply.png)

![Lista de subredes](docs/evidencias/fase-01-red/02-subred.png)

### Fase 2. Variables y salidas

**Evidencia 2.** Resultado completo de `terraform plan` sin cambios y de `terraform output` con los dos valores.

![Plan de Terraform sin cambios](docs/evidencias/fase-02-variables/01-terraform-plan.png)

![Nombre de la red e identificador de la subred](docs/evidencias/fase-02-variables/02-terraform-output.png)

### Fase 3. La aplicación

**Evidencia 3.** Instancia conectada a la subred propia, con su dirección IP interna.

![Instancia conectada a la subred propia e IP interna](docs/evidencias/fase-03-aplicacion/01-instancia-red.png)

### Fase 4. Las puertas

**Evidencia 4.** Aplicación abierta con la IP visible, reglas de cortafuegos y sesión SSH mediante IAP.

![Aplicación accesible desde internet](docs/evidencias/fase-04-firewall/01-aplicacion-publica.png)

![Reglas de cortafuegos de la VPC](docs/evidencias/fase-04-firewall/02-reglas-firewall.png)

![Conexión SSH mediante IAP](docs/evidencias/fase-04-firewall/03-ssh-iap.png)

### Fase 5. Reproducir desde cero

**Evidencia 5.** Destrucción de los recursos, comprobación de los listados vacíos y reconstrucción de la infraestructura con la aplicación funcionando.

Se eliminaron los cinco recursos de la práctica mediante Terraform.

![Destrucción de los cinco recursos](docs/evidencias/fase-05-reconstruccion/01-terraform-destroy.png)

Después de la destrucción, se comprobó que no quedaban máquinas virtuales y que la red `practica-3-vpc` había sido eliminada. La red `default` permaneció en el proyecto.

![Verificación de los recursos eliminados](docs/evidencias/fase-05-reconstruccion/02-verificacion-destroy.png)

Se reconstruyó la infraestructura utilizando el mismo código de Terraform, con cinco recursos creados correctamente.

![Reconstrucción de la infraestructura](docs/evidencias/fase-05-reconstruccion/03-terraform-apply.png)

Finalmente, se comprobó que la aplicación volvió a funcionar. La máquina recibió una nueva IP pública: `34.41.201.178`, diferente de la anterior, `34.28.223.243`.

![Aplicación funcionando después de la reconstrucción](docs/evidencias/fase-05-reconstruccion/04-aplicacion-reconstruida.png)

### Fase 6. La máquina que nadie puede alcanzar

**Evidencia 6.** Diagrama de la red final, aplicación mostrando el dato de la máquina privada y pruebas de acceso externo e interno.

## 4. Comandos ejecutados

### Preparación del entorno

### Fase 1. La red y su subred

```bash
terraform init
terraform plan
terraform apply
gcloud compute networks subnets list
```

### Fase 2. Variables y salidas

```bash
terraform plan
terraform apply
terraform plan
terraform output
```

### Fase 3. La aplicación

```bash
terraform plan
terraform apply
terraform output
```

### Fase 4. Las puertas

```bash
git pull origin main
terraform plan
terraform apply
terraform output -raw ip_publica
curl http://34.28.223.243
gcloud compute ssh practica-3-app --zone=us-central1-a --tunnel-through-iap
hostname
exit
```

### Fase 5. Reproducir desde cero

```bash
terraform output -raw ip_publica
terraform plan -destroy
terraform destroy
gcloud compute instances list
gcloud compute networks list
terraform apply
terraform output -raw ip_publica
curl http://$(terraform output -raw ip_publica)
```

### Fase 6. La máquina que nadie puede alcanzar

## 5. Decisiones de diseño

**1. Servicio y puerto de la máquina de datos:**

**2. Organización de los archivos de Terraform:**

**3. Administración de la máquina sin IP pública:**

**4. Direccionamiento de las dos subredes:**

## 6. Preguntas de análisis

### 6.1. Si le quitas la etiqueta de red a la máquina de aplicación y aplicas, ¿qué deja de funcionar exactamente, y por qué la regla de cortafuegos sigue existiendo?

### 6.2. ¿Por qué el plan de la fase 2 no propuso ningún cambio, si el código era distinto? ¿Qué habrías tenido que cambiar para que sí propusiera recrear un recurso?

### 6.3. Con la red completa encendida, ¿cuánto costaría un mes? Desglosa por recurso y señala cuál es el que más sorprende.