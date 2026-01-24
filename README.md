# dokku solr [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-solr/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-solr/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official solr plugin for dokku. Currently defaults to installing [solr 9.10.1](https://hub.docker.com/_/solr/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-solr.git --name solr
```

## Commands

```
solr:app-links <app>                               # list all solr service links for a given app
solr:backup-set-public-key-encryption <service> <public-key-id> # set GPG Public Key encryption for all future backups of solr service
solr:backup-unset-public-key-encryption <service>  # unset GPG Public Key encryption for future backups of the solr service
solr:create <service> [--create-flags...]          # create a solr service
solr:destroy <service> [-f|--force]                # delete the solr service/data/container if there are no links left
solr:enter <service>                               # enter or run a command in a running solr service container
solr:exists <service>                              # check if the solr service exists
solr:expose <service> <ports...>                   # expose a solr service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
solr:info <service> [--single-info-flag]           # print the service information
solr:link <service> <app> [--link-flags...]        # link the solr service to the app
solr:linked <service> <app>                        # check if the solr service is linked to an app
solr:links <service>                               # list all apps linked to the solr service
solr:list                                          # list all solr services
solr:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
solr:pause <service>                               # pause a running solr service
solr:promote <service> <app>                       # promote service <service> as SOLR_URL in <app>
solr:restart <service>                             # graceful shutdown and restart of the solr service container
solr:set <service> <key> <value>                   # set or clear a property for a service
solr:start <service>                               # start a previously stopped solr service
solr:stop <service>                                # stop a running solr service
solr:unexpose <service>                            # unexpose a previously exposed solr service
solr:unlink <service> <app>                        # unlink the solr service from the app
solr:upgrade <service> [--upgrade-flags...]        # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to solr:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `solr:help` command for any undocumented commands.

### Basic Usage

### create a solr service

```shell
# usage
dokku solr:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-p|--password PASSWORD`: override the user-level service password
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-r|--root-password PASSWORD`: override the root-level service password
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for solr docker container

Create a solr service named lollipop:

```shell
dokku solr:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the solr image.

```shell
export SOLR_IMAGE="solr"
export SOLR_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku solr:create lollipop
```

You can also specify custom environment variables to start the solr service in semicolon-separated form.

```shell
export SOLR_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku solr:create lollipop
```

### print the service information

```shell
# usage
dokku solr:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--initial-network`: show the initial network being connected to
- `--links`: show the service app links
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku solr:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku solr:info lollipop --config-dir
dokku solr:info lollipop --data-dir
dokku solr:info lollipop --dsn
dokku solr:info lollipop --exposed-ports
dokku solr:info lollipop --id
dokku solr:info lollipop --internal-ip
dokku solr:info lollipop --initial-network
dokku solr:info lollipop --links
dokku solr:info lollipop --post-create-network
dokku solr:info lollipop --post-start-network
dokku solr:info lollipop --service-root
dokku solr:info lollipop --status
dokku solr:info lollipop --version
```

### list all solr services

```shell
# usage
dokku solr:list
```

List all services:

```shell
dokku solr:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku solr:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku solr:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku solr:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku solr:logs lollipop --tail 5
```

### link the solr service to the app

```shell
# usage
dokku solr:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link
- `-n|--no-restart "false"`: whether or not to restart the app on link (default: true)

A solr service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku solr:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_SOLR_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_SOLR_LOLLIPOP_PORT=tcp://172.17.0.1:8983
DOKKU_SOLR_LOLLIPOP_PORT_8983_TCP=tcp://172.17.0.1:8983
DOKKU_SOLR_LOLLIPOP_PORT_8983_TCP_PROTO=tcp
DOKKU_SOLR_LOLLIPOP_PORT_8983_TCP_PORT=8983
DOKKU_SOLR_LOLLIPOP_PORT_8983_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
SOLR_URL=http://dokku-solr-lollipop:8983/solr/lollipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku solr:link other_service playground
```

It is possible to change the protocol for `SOLR_URL` by setting the environment variable `SOLR_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground SOLR_DATABASE_SCHEME=http2
dokku solr:link lollipop playground
```

This will cause `SOLR_URL` to be set as:

```
http2://dokku-solr-lollipop:8983/solr/lollipop
```

### unlink the solr service from the app

```shell
# usage
dokku solr:unlink <service> <app>
```

flags:

- `-n|--no-restart "false"`: whether or not to restart the app on unlink (default: true)

You can unlink a solr service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku solr:unlink lollipop playground
```

### set or clear a property for a service

```shell
# usage
dokku solr:set <service> <key> <value>
```

Set the network to attach after the service container is started:

```shell
dokku solr:set lollipop post-create-network custom-network
```

Set multiple networks:

```shell
dokku solr:set lollipop post-create-network custom-network,other-network
```

Unset the post-create-network value:

```shell
dokku solr:set lollipop post-create-network
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running solr service container

```shell
# usage
dokku solr:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku solr:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku solr:enter lollipop touch /tmp/test
```

### expose a solr service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku solr:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku solr:expose lollipop 8983
```

Expose the service on the service's normal ports, with the first on a specified ip address (127.0.0.1):

```shell
dokku solr:expose lollipop 127.0.0.1:8983
```

### unexpose a previously exposed solr service

```shell
# usage
dokku solr:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku solr:unexpose lollipop
```

### promote service <service> as SOLR_URL in <app>

```shell
# usage
dokku solr:promote <service> <app>
```

If you have a solr service linked to an app and try to link another solr service another link environment variable will be generated automatically:

```
DOKKU_SOLR_BLUE_URL=http://other_service:ANOTHER_PASSWORD@dokku-solr-other-service:8983/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku solr:promote other_service playground
```

This will replace `SOLR_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
SOLR_URL=http://other_service:ANOTHER_PASSWORD@dokku-solr-other-service:8983/other_service
DOKKU_SOLR_BLUE_URL=http://other_service:ANOTHER_PASSWORD@dokku-solr-other-service:8983/other_service
DOKKU_SOLR_SILVER_URL=http://lollipop:SOME_PASSWORD@dokku-solr-lollipop:8983/lollipop
```

### start a previously stopped solr service

```shell
# usage
dokku solr:start <service>
```

Start the service:

```shell
dokku solr:start lollipop
```

### stop a running solr service

```shell
# usage
dokku solr:stop <service>
```

Stop the service and removes the running container:

```shell
dokku solr:stop lollipop
```

### pause a running solr service

```shell
# usage
dokku solr:pause <service>
```

Pause the running container for the service:

```shell
dokku solr:pause lollipop
```

### graceful shutdown and restart of the solr service container

```shell
# usage
dokku solr:restart <service>
```

Restart the service:

```shell
dokku solr:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku solr:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-R|--restart-apps "true"`: whether or not to force an app restart (default: false)
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for solr docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku solr:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all solr service links for a given app

```shell
# usage
dokku solr:app-links <app>
```

List all solr services that are linked to the `playground` app.

```shell
dokku solr:app-links playground
```

### check if the solr service exists

```shell
# usage
dokku solr:exists <service>
```

Here we check if the lollipop solr service exists.

```shell
dokku solr:exists lollipop
```

### check if the solr service is linked to an app

```shell
# usage
dokku solr:linked <service> <app>
```

Here we check if the lollipop solr service is linked to the `playground` app.

```shell
dokku solr:linked lollipop playground
```

### list all apps linked to the solr service

```shell
# usage
dokku solr:links <service>
```

List all apps linked to the `lollipop` solr service.

```shell
dokku solr:links lollipop
```
### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

If both passphrase and public key forms of encryption are set, the public key encryption will take precedence.

The underlying core backup script is present [here](https://github.com/dokku/docker-s3backup/blob/main/backup.sh).

Backups can be performed using the backup commands:

### set GPG Public Key encryption for all future backups of solr service

```shell
# usage
dokku solr:backup-set-public-key-encryption <service> <public-key-id>
```

Set the `GPG` Public Key for encrypting backups:

```shell
dokku solr:backup-set-public-key-encryption lollipop
```

This method currently requires the <public-key-id> to be present on the keyserver `keyserver.ubuntu.com`:

### unset GPG Public Key encryption for future backups of the solr service

```shell
# usage
dokku solr:backup-unset-public-key-encryption <service>
```

Unset the `GPG` Public Key encryption for backups:

```shell
dokku solr:backup-unset-public-key-encryption lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `SOLR_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
