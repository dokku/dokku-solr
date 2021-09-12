# dokku solr [![Build Status](https://img.shields.io/github/workflow/status/dokku/dokku-solr/CI/master?style=flat-square "Build Status")](https://github.com/dokku/dokku-solr/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official solr plugin for dokku. Currently defaults to installing [solr 8.9.0](https://hub.docker.com/_/solr/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-solr.git solr
```

## Commands

```
solr:app-links <app>                        # list all solr service links for a given app
solr:create <service> [--create-flags...]   # create a solr service
solr:destroy <service> [-f|--force]         # delete the solr service/data/container if there are no links left
solr:enter <service>                        # enter or run a command in a running solr service container
solr:exists <service>                       # check if the solr service exists
solr:expose <service> <ports...>            # expose a solr service on custom port if provided (random port otherwise)
solr:info <service> [--single-info-flag]    # print the service information
solr:link <service> <app> [--link-flags...] # link the solr service to the app
solr:linked <service> <app>                 # check if the solr service is linked to an app
solr:links <service>                        # list all apps linked to the solr service
solr:list                                   # list all solr services
solr:logs <service> [-t|--tail]             # print the most recent log(s) for this service
solr:promote <service> <app>                # promote service <service> as SOLR_URL in <app>
solr:restart <service>                      # graceful shutdown and restart of the solr service container
solr:start <service>                        # start a previously stopped solr service
solr:stop <service>                         # stop a running solr service
solr:unexpose <service>                     # unexpose a previously exposed solr service
solr:unlink <service> <app>                 # unlink the solr service from the app
solr:upgrade <service> [--upgrade-flags...] # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to solr:help. Please consult the `solr:help` command for any undocumented commands.

### Basic Usage

### create a solr service

```shell
# usage
dokku solr:create <service> [--create-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password

Create a solr service named lolipop:

```shell
dokku solr:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the solr image. 

```shell
export SOLR_IMAGE="solr"
export SOLR_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku solr:create lolipop
```

You can also specify custom environment variables to start the solr service in semi-colon separated form. 

```shell
export SOLR_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku solr:create lolipop
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
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku solr:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku solr:info lolipop --config-dir
dokku solr:info lolipop --data-dir
dokku solr:info lolipop --dsn
dokku solr:info lolipop --exposed-ports
dokku solr:info lolipop --id
dokku solr:info lolipop --internal-ip
dokku solr:info lolipop --links
dokku solr:info lolipop --service-root
dokku solr:info lolipop --status
dokku solr:info lolipop --version
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
dokku solr:logs <service> [-t|--tail]
```

flags:

- `-t|--tail`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku solr:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku solr:logs lolipop --tail
```

### link the solr service to the app

```shell
# usage
dokku solr:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A solr service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app. 

> NOTE: this will restart your app

```shell
dokku solr:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_SOLR_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_SOLR_LOLIPOP_PORT=tcp://172.17.0.1:8983
DOKKU_SOLR_LOLIPOP_PORT_8983_TCP=tcp://172.17.0.1:8983
DOKKU_SOLR_LOLIPOP_PORT_8983_TCP_PROTO=tcp
DOKKU_SOLR_LOLIPOP_PORT_8983_TCP_PORT=8983
DOKKU_SOLR_LOLIPOP_PORT_8983_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
SOLR_URL=http://lolipop:SOME_PASSWORD@dokku-solr-lolipop:8983/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the 'expose' subcommand. Another service can be linked to your app:

```shell
dokku solr:link other_service playground
```

It is possible to change the protocol for `SOLR_URL` by setting the environment variable `SOLR_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding. 

```shell
dokku config:set playground SOLR_DATABASE_SCHEME=http2
dokku solr:link lolipop playground
```

This will cause `SOLR_URL` to be set as:

```
http2://lolipop:SOME_PASSWORD@dokku-solr-lolipop:8983/lolipop
```

### unlink the solr service from the app

```shell
# usage
dokku solr:unlink <service> <app>
```

You can unlink a solr service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku solr:unlink lolipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running solr service container

```shell
# usage
dokku solr:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk. 

```shell
dokku solr:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk. 

```shell
dokku solr:enter lolipop touch /tmp/test
```

### expose a solr service on custom port if provided (random port otherwise)

```shell
# usage
dokku solr:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku solr:expose lolipop 8983
```

### unexpose a previously exposed solr service

```shell
# usage
dokku solr:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku solr:unexpose lolipop
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
DOKKU_SOLR_SILVER_URL=http://lolipop:SOME_PASSWORD@dokku-solr-lolipop:8983/lolipop
```

### start a previously stopped solr service

```shell
# usage
dokku solr:start <service>
```

Start the service:

```shell
dokku solr:start lolipop
```

### stop a running solr service

```shell
# usage
dokku solr:stop <service>
```

Stop the service and the running container:

```shell
dokku solr:stop lolipop
```

### graceful shutdown and restart of the solr service container

```shell
# usage
dokku solr:restart <service>
```

Restart the service:

```shell
dokku solr:restart lolipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku solr:upgrade <service> [--upgrade-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart

You can upgrade an existing service to a new image or image-version:

```shell
dokku solr:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all solr service links for a given app

```shell
# usage
dokku solr:app-links <app>
```

List all solr services that are linked to the 'playground' app. 

```shell
dokku solr:app-links playground
```

### check if the solr service exists

```shell
# usage
dokku solr:exists <service>
```

Here we check if the lolipop solr service exists. 

```shell
dokku solr:exists lolipop
```

### check if the solr service is linked to an app

```shell
# usage
dokku solr:linked <service> <app>
```

Here we check if the lolipop solr service is linked to the 'playground' app. 

```shell
dokku solr:linked lolipop playground
```

### list all apps linked to the solr service

```shell
# usage
dokku solr:links <service>
```

List all apps linked to the 'lolipop' solr service. 

```shell
dokku solr:links lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `SOLR_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
