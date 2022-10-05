# vaultwarden-rclone
Vaultwarden server that backs up via rclone

## About
Based off the vaultwarden docker image and adds sqlite, rclone, and cron plus logic to do backups via rclone.  Meant to be used when running VaultWarden in k8s, where it's hard to share a persistant volume with another container, such as https://github.com/ttionya/vaultwarden-backup.  

## Usage
You need to set the following environment variables:
 - BKUP_PROVIDER_DEST
 - BKUP_PROVIDER_AUTH

The following environment variables can be set to override the defaults:
- BKUP_DT_FORMAT="+%Y-%m"
- BKUP_PROVIDER_NAME="backblaze"
- BKUP_PROVIDER_TYPE="b2"
- BKUP_AT_MIN=17
- BKUP_AT_HOUR=3

For example your k8s yaml might look like this:

```
containers:
      - name: vaultwarden
        image: polandj/vaultwarden-rclone
        env:
          - name: BKUP_PROVIDER_DEST
            value: my-bucket-name
          - name: BKUP_PROVIDER_AUTH
            value: "account 123456 key 123456"  
 ```
