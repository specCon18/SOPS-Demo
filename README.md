# SOPS-Demo

A Demo of [Mozilla SOPS](https://github.com/mozilla/sops)

# Download and install Sops

## For All Linux Distros with Curl
```bash
SOPS_LATEST_VERSION=$(curl -s "https://api.github.com/repos/mozilla/sops/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
```

## For Debian Based
```bash
curl -Lo sops.deb "https://github.com/mozilla/sops/releases/latest/download/sops_${SOPS_LATEST_VERSION}_amd64.deb"
```

```bash
sudo apt --fix-broken install ./sops.deb
```

```bash
rm -rf sops.deb
```

## For RHEL Based
```bash
curl -Lo sops.rpm "https://github.com/mozilla/sops/releases/latest/download/sops_${SOPS_LATEST_VERSION}_x86_64.rpm"
```

```bash
sudo dnf localinstall ./sops.rpm
```

```bash
rm -rf sops.rpm
```

## Verify install
```bash
sops -v
```

## Download the querried file
```bash
curl -Lo age.tar.gz "https://github.com/FiloSottile/age/releases/latest/download/age-v${AGE_LATEST_VERSION}-linux-amd64.tar.gz"
```

## Untar the download
```bash
tar xf age.tar.gz
```

## move the binaries to thier proper location
```bash
sudo mv age/age /usr/local/bin sudo mv age/age-keygen /usr/local/bin
```

## Check for proper install
```bash
age -version
```

```bash
age-keygen -version
```

# SOps & Age

## Create the .sops directory and generate the keypair
```bash
mkdir ~/.sops && cd ~/.sops && age-keygen -o key
```

## Add the .sops dir to your PATH

### bash users
```bash
echo "export SOPS_AGE_KEY_FILE=$HOME/.sops/key" >> ~/.bashrc && . "$HOME"/.bashrc
```

### zsh users
```zsh
echo "typeset -g SOPS_AGE_KEY_FILE=$HOME/.sops/key" >> ~/.zshrc && . "$HOME"/.zshrc
```


## Example Encryption
```yaml
version: '3'
services:
  auth:
    container_name: auth    
    image: authelia/authelia:latest
    expose:
      - 9091
    volumes:
      - /opt/appdata/authelia:/config:Z
    labels:
      traefik.enable: true
      traefik.http.routers.auth.entryPoints: https
    networks:
      - traefik-socket-proxy
    restart: unless-stopped
    depends_on:
      - redis
      - mariadb

  redis:
    container_name: redis
    image: bitnami/redis:latest
    expose:
      - 6379
    volumes:
      - /opt/appdata/redis:/bitnami/
    environment:
      REDIS_PASSWORD: "${REDIS_PASS}"
    networks:
      - traefik-socket-proxy
    restart: unless-stopped

  mariadb:
    container_name: mariadb
    image: linuxserver/mariadb:latest
    expose:
      - 3306
    volumes:
      - /opt/appdata/mariadb:/config
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT}"
      MYSQL_ROOT_USER: root
      MYSQL_DATABASE: authelia
      MYSQL_USER: authelia
      MYSQL_PASSWORD: "${MYSQL_DB}"  
    networks:
      - traefik-socket-proxy
    restart: unless-stopped

networks:
  traefik-socket-proxy:
    driver: bridge
    external: true
```

```bash
sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --encrypted-regex '^(.*PASSWORD:)$' --in-place ./secret.yaml
```

This command is using the `sops` tool to encrypt a YAML file `./secret.yaml` in place.

The options used in this command are:

-   `--encrypt`: This option tells `sops` to encrypt the secrets in the file.
    
-   `--age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)")`: This option specifies the encryption algorithm to use, in this case `age`. The `cat` command is used to read the contents of the file specified by the environment variable `$SOPS_AGE_KEY_FILE`, and the `grep` command is used to extract the public key from that file. The extracted key is passed to `sops` as an argument to the `--age` option.
    
-   `--encrypted-regex '^(.*PASSWORD:)$'`: This option specifies a regular expression that `sops` will use to identify secrets in the file. In this case, the regex matches any string that starts with any number of characters (`.`) and ends with the string `"PASSWORD:"`.
    
-   `--in-place`: This option tells `sops` to modify the file in place, rather than writing the encrypted secrets to a new file.


in the case of the above example sops will encrypt the values of the environment variables `REDIS_PASS`, `MYSQL_ROOT`, and `MYSQL_DB` in the YAML file specified.

These values are assigned to the environment variables in the `redis` and `mariadb` services and can be seen in the following lines:

```yaml
environment:
	REDIS_PASSWORD: "${REDIS_PASS}"
```

```yaml
	environment: 
		MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT}"
		MYSQL_PASSWORD: "${MYSQL_DB}"
```  

The encrypted values will be written back to the same file, replacing the original clear-text values.

## Decrypt
```bash
sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --encrypted-regex '^(.*PASSWORD:)$' --in-place ./secret.yaml
```

The above command using the `sops` tool will decrypt the values of environment variables that were encrypted in the YAML file specified.

The regular expression specified in the `sops` command `'^(.*PASSWORD:)$'` matches strings that end with the string `PASSWORD:`, so these environment variables will be decrypted by `sops`. The decrypted values will be written back to the same file, replacing the encrypted values.

The `--age` option specifies the age public key to use for decryption. The value for this option is obtained from the file specified in the `$SOPS_AGE_KEY_FILE` variable and is extracted using `grep` with the `-oP` option to only print the matched part of the string. The regular expression `"public key: \K(.*)"` matches the string `"public key: "` followed by any characters, capturing the characters into a group that is printed by `grep`.