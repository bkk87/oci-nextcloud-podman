# Nextcloud hosting on Always-free tier Oracle Cloud (OCI)

Oracle Cloud (OCI) is offering a generous "Always-free tier" including several CPU cores/instances, 24GB(!) memory and 200GB of block storage. Deploying Nextcloud on this offering works really well.

- I have decided on a single VM deployment with podman. My focus was on maximising performance and storage instead of high-availability. Each VM boot volume would consume at least 50GB. As we only get 200GB for free, I have chosen a single instance compared to e.g. a multi-node k3s cluster.  
- Terraform templates for the OCI infrastructure is provided. For the deployments on the instance, instructions are provided as well.
- Object Storage bucket included which can be integrated with Nextcloud's external storage plugin. We get 20GB for free.
- Bastion host setup included to access the VM over ssh in a private subnet.
- WAF included in front of the load balancer to protect the web application
- TLS encryption using the acme.sh certbot and a hook script to update a new cert at the load balancer (TLS offloading)

## OCI deployment with Terraform

Run terraform in the this root folder. With the output variables (`bastion_session_id, instance_private_ip`) you will be able to `ssh` into the instance. Use a `ssh config` like this:

```text
Host oci
 HostName <instance_private_ip>
 User opc
 Port 22
 IdentityFile /home/you/.ssh/id_rsa_oci 
 ProxyCommand ssh -i /home/you/.ssh/id_rsa_oci -W %h:%p -p 22 <bastion_session_id>
 ```

## Instance/VM configuration

### add a password for the default user (opc) and prevent sudo without password
```bash
sudo passwd opc 
<your password>
sudo nano /etc/sudoers.d/90-cloud-init-users -> opc ALL=(ALL) ALL
```

### add automatic OS updates
```bash
vi /etc/dnf/automatic.conf
vi /usr/lib/systemd/system/dnf-automatic.timer
sudo systemctl enable dnf-automatic.timer --now
```

### nextcloud deployment using rootless podman 
```bash
export PODNAME="nextcloud"
podman volume create nextcloud
podman volume create mariadb

podman pod create --hostname ${PODNAME} --name ${PODNAME} -p 8080:80

podman run \
  -d \
  --restart=always \
  --pod=${PODNAME} \
  --label "io.containers.autoupdate=registry" \
  -e MYSQL_ROOT_PASSWORD="<your password>" \
  -e MYSQL_DATABASE="nextcloud" \
  -e MYSQL_USER="nextcloud" \
  -e MYSQL_PASSWORD="<your password>" \
  -v mariadb:/var/lib/mysql \
  --name=${PODNAME}-mariadb docker.io/library/mariadb:10.6 \
  --transaction-isolation="READ-COMMITTED" --binlog-format="ROW"


podman run \
  -d \
  --restart=always \
  --pod=${PODNAME} \
  --label "io.containers.autoupdate=registry" \
  --name=${PODNAME}-redis docker.io/library/redis:7

podman run \
  -d \
  --pod=${PODNAME} \
  --label "io.containers.autoupdate=registry" \
  -e REDIS_HOST="localhost" \
  -e MYSQL_HOST="localhost" \
  -e MYSQL_USER="nextcloud" \
  -e MYSQL_PASSWORD="<your password>" \
  -e MYSQL_DATABASE="nextcloud" \
  -e PHP_UPLOAD_LIMIT="20G" \
  -e PHP_MEMORY_LIMIT="4G" \
  -v nextcloud:/var/www/html \
  --name=${PODNAME}-app docker.io/library/nextcloud:stable

podman exec --user www-data nextcloud-app php occ maintenance:install \
  --da/app/Bitwarden/resources/app.asar/index.htmltabase "mysql" \
  --database-host "127.0.0.1" \
  --database-name "nextcloud" \
  --database-user "nextcloud" \
  --database-pass "<your password>" \
  --admin-user "<your admin username>" \
  --admin-pass "<your password>" 
podman exec --user www-data nextcloud-app php occ config:system:set trusted_domains 2 --value=<your domain static ip>
podman exec --user www-data nextcloud-app php occ config:system:set trusted_domains 3 --value=<your domain>
podman exec --user www-data nextcloud-app php occ config:system:set trusted_proxies 0 --value=<your domain static ip>
podman exec --user www-data nextcloud-app php occ config:system:set default_phone_region --type string --value="DE"
podman exec --user www-data nextcloud-app php occ config:system:set overwriteprotocol --value "https"

# optimized preview configuration: https://ownyourbits.com/2019/06/29/understanding-and-improving-nextcloud-previews/
podman exec --user www-data nextcloud-app php occ config:app:set previewgenerator squareSizes --value="32 256"
podman exec --user www-data nextcloud-app php occ config:app:set previewgenerator widthSizes  --value="256 384"
podman exec --user www-data nextcloud-app php occ config:app:set previewgenerator heightSizes --value="256"
podman exec --user www-data nextcloud-app php occ config:system:set preview_max_x --value 2048
podman exec --user www-data nextcloud-app php occ config:system:set preview_max_y --value 2048
podman exec --user www-data nextcloud-app php occ config:system:set jpeg_quality --value 60
podman exec --user www-data nextcloud-app php occ config:app:set preview jpeg_quality --value="60"

# in case you want to generate previews of non-default file types, eg movie or heic files, this snippet needs to run regularly
# currently, ffmpeg, ghostscript and imagemagick are not part of the official docker image
podman exec nextcloud-app apt-get update
podman exec nextcloud-app apt-get install ffmpeg imagemagick ghostscript --yes

podman exec --user www-data nextcloud-app php occ config:system:set enable_previews --value=true

podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 0 --value="OC\\Preview\\TXT"
podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 1 --value="OC\\Preview\\MarkDown"
podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 2 --value="OC\\Preview\\MP4"
podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 3 --value="OC\\Preview\\Image"
podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 4 --value="OC\\Preview\\Movie"
podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 5 --value="OC\\Preview\\GIF"
podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 6 --value="OC\\Preview\\HEIC"
podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 7 --value="OC\\Preview\\BMP"
podman exec --user www-data nextcloud-app php occ config:system:set enabledPreviewProviders 8 --value="OC\\Preview\\JPEG"


podman exec --user www-data nextcloud-app php occ preview:generate-all -vvv


sudo loginctl enable-linger opc
mkdir -p ~/.config/systemd/user
cd ~/.config/systemd/user
podman generate systemd --name nextcloud --files --new
systemctl --user daemon-reload
systemctl --user enable pod-nextcloud --now
systemctl --user enable podman-auto-update.timer --now
sudo systemctl enable podman 
```

### add letsencrypt acme.sh for TLS termination on OCI load balancer
```bash
sudo curl https://get.acme.sh | sh -s email=<your email>

# when the letsencrypt cert is about to expire, it will be renewed using a cronjob. we want to also update the cert in the OCI load balancer. this script will be invoked after each cert renewal.
vi update_lb.sh 
# script start:

#/usr/bin/bash
now=$(date "+%Y%m%d_%H%M")
CertificateName=Certificate-$now
ocicli=/usr/bin/oci
ListenerName=https_443
BackendName=http_8080_ingress
LB_OCID=<your LB ocid>
certificate_path=/home/opc/.acme.sh/<your domain>

$ocicli lb certificate create \
--auth instance_principal \
--certificate-name $CertificateName \
--load-balancer-id $LB_OCID \
--private-key-file "$certificate_path/<your domain>" \
--public-certificate-file "$certificate_path/fullchain.cer"

sleep 20

$ocicli lb listener update \
--auth instance_principal \
--default-backend-set-name $BackendName \
--listener-name $ListenerName \
--load-balancer-id $LB_OCID \
--port 8080 \
--protocol HTTP \
--ssl-certificate-name $CertificateName \
--force
# script end

chmod +x update_lb.sh

# get a certificate and setup auto-renewal
sudo /home/opc/.acme.sh/acme.sh --home /home/opc/.acme.sh --issue -d <your domain> --standalone --force --renew-hook /home/opc/update_lb.sh --server letsencrypt

# initially deploy the script at the OCI load balancer
./update_lb.sh

# the auto-renewal script will run is placed in crontab of user opc. however, we need to run the script with root priviledged. move the auto-generated line from the user's crontab to /etc/crontab
crontab -e
sudo vi /etc/crontab
31 0 * * * root "/home/opc/.acme.sh"/acme.sh --cron --home "/home/opc/.acme.sh" > /dev/null
```
