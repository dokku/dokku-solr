# dokku solr [![Build Status](https://img.shields.io/travis/dokku/dokku-solr.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-solr) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official solr plugin for dokku. Currently defaults to installing [solr 7.7.2](https://hub.docker.com/_/solr/).

## Requirements

- dokku 0.12.x+
- docker 1.8.x

## Installation

```shell
# on 0.12.x+
sudo dokku plugin:install https://github.com/dokku/dokku-solr.git solr
```

## Commands

```
solr:app-links <app>                               # list all solr service links for a given app
solr:backup <service> <bucket-name> [--use-iam]    # creates a backup of the solr service to an existing s3 bucket
solr:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # sets up authentication for backups on the solr service
solr:backup-deauth <service>                       # removes backup authentication for the solr service
solr:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedules a backup of the solr service
solr:backup-schedule-cat <service>                 # cat the contents of the configured backup cronfile for the service
solr:backup-set-encryption <service> <passphrase>  # sets encryption for all future backups of solr service
solr:backup-unschedule <service>                   # unschedules the backup of the solr service
solr:backup-unset-encryption <service>             # unsets encryption for future backups of the solr service
solr:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
solr:connect <service>                             # connect to the service via the solr connection tool
solr:create <service> [--create-flags...]          # create a solr service
solr:destroy <service> [-f|--force]                # delete the solr service/data/container if there are no links left
solr:enter <service>                               # enter or run a command in a running solr service container
solr:exists <service>                              # check if the solr service exists
solr:export <service>                              # export a dump of the solr service database
solr:expose <service> <ports...>                   # expose a solr service on custom port if provided (random port otherwise)
solr:import <service>                              # import a dump into the solr service database
solr:info <service> [--single-info-flag]           # print the connection information
solr:link <service> <app> [--link-flags...]        # link the solr service to the app
solr:linked <service> <app>                        # check if the solr service is linked to an app
solr:links <service>                               # list all apps linked to the solr service
solr:list                                          # list all solr services
solr:logs <service> [-t|--tail]                    # print the most recent log(s) for this service
solr:promote <service> <app>                       # promote service <service> as SOLR_URL in <app>
solr:restart <service>                             # graceful shutdown and restart of the solr service container
solr:start <service>                               # start a previously stopped solr service
solr:stop <service>                                # stop a running solr service
solr:unexpose <service>                            # unexpose a previously exposed solr service
solr:unlink <service> <app>                        # unlink the solr service from the app
solr:upgrade <service> [--upgrade-flags...]        # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to solr:help. Please consult the `solr:help` command for any undocumented commands.

### Basic Usage
### list all solr services

```shell
# usage
dokku solr:list 
```

examples:

List all services:

```shell
dokku solr:list
```
### create a solr service

```shell
# usage
dokku solr:create <service> [--create-flags...]
```

examples:

Create a solr service named lolipop:

```shell
dokku solr:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the ${plugin_image} image. :

```shell
export SOLR_IMAGE="${PLUGIN_IMAGE}"
export SOLR_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku solr:create lolipop
```

You can also specify custom environment variables to start the solr service in semi-colon separated form. :

```shell
export SOLR_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku solr:create lolipop
```
### print the connection information

```shell
# usage
dokku solr:info <service> [--single-info-flag]
```

examples:

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
### print the most recent log(s) for this service

```shell
# usage
dokku solr:logs <service> [-t|--tail]
```

examples:

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

examples:

A solr service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app. :

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

It is possible to change the protocol for solr_url by setting the environment variable solr_database_scheme on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding. :

```shell
dokku config:set playground SOLR_DATABASE_SCHEME=http2
dokku solr:link lolipop playground
```

This will cause solr_url to be set as:

```
http2://lolipop:SOME_PASSWORD@dokku-solr-lolipop:8983/lolipop
```
### unlink the solr service from the app

```shell
# usage
dokku solr:unlink <service> <app>
```

examples:

You can unlink a solr service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku solr:unlink lolipop playground
```
### delete the solr service/data/container if there are no links left

```shell
# usage
dokku solr:destroy <service> [-f|--force]
```

examples:

Destroy the service, it's data, and the running container:

```shell
dokku solr:destroy lolipop
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the solr connection tool

```shell
# usage
dokku solr:connect <service>
```

examples:

Connect to the service via the solr connection tool:

```shell
dokku solr:connect lolipop
```
### enter or run a command in a running solr service container

```shell
# usage
dokku solr:enter <service>
```

examples:

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk. :

```shell
dokku solr:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk. :

```shell
dokku solr:enter lolipop touch /tmp/test
```
### expose a solr service on custom port if provided (random port otherwise)

```shell
# usage
dokku solr:expose <service> <ports...>
```

examples:

Expose the service on the service's normal ports, allowing access to it from the public interface (0. 0. 0. 0):

```shell
dokku solr:expose lolipop ${PLUGIN_DATASTORE_PORTS[@]}
```
### unexpose a previously exposed solr service

```shell
# usage
dokku solr:unexpose <service>
```

examples:

Unexpose the service, removing access to it from the public interface (0. 0. 0. 0):

```shell
dokku solr:unexpose lolipop
```
### promote service <service> as SOLR_URL in <app>

```shell
# usage
dokku solr:promote <service> <app>
```

examples:

If you have a solr service linked to an app and try to link another solr service another link environment variable will be generated automatically:

```
DOKKU_SOLR_BLUE_URL=http://other_service:ANOTHER_PASSWORD@dokku-solr-other-service:8983/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku solr:promote other_service playground
```

This will replace solr_url with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
SOLR_URL=http://other_service:ANOTHER_PASSWORD@dokku-solr-other-service:8983/other_service
DOKKU_SOLR_BLUE_URL=http://other_service:ANOTHER_PASSWORD@dokku-solr-other-service:8983/other_service
DOKKU_SOLR_SILVER_URL=http://lolipop:SOME_PASSWORD@dokku-solr-lolipop:8983/lolipop
```
### graceful shutdown and restart of the solr service container

```shell
# usage
dokku solr:restart <service>
```

examples:

Restart the service:

```shell
dokku solr:restart lolipop
```
### start a previously stopped solr service

```shell
# usage
dokku solr:start <service>
```

examples:

Start the service:

```shell
dokku solr:start lolipop
```
### stop a running solr service

```shell
# usage
dokku solr:stop <service>
```

examples:

Stop the service and the running container:

```shell
dokku solr:stop lolipop
```
### upgrade service <service> to the specified versions

```shell
# usage
dokku solr:upgrade <service> [--upgrade-flags...]
```

examples:

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

examples:

List all solr services that are linked to the 'playground' app. :

```shell
dokku solr:app-links playground
```
### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku solr:clone <service> <new-service> [--clone-flags...]
```

examples:

You can clone an existing service to a new one:

```shell
dokku solr:clone lolipop lolipop-2
```
### check if the solr service exists

```shell
# usage
dokku solr:exists <service>
```

examples:

Here we check if the lolipop solr service exists. :

```shell
dokku solr:exists lolipop
```
### check if the solr service is linked to an app

```shell
# usage
dokku solr:linked <service> <app>
```

examples:

Here we check if the lolipop solr service is linked to the 'playground' app. :

```shell
dokku solr:linked lolipop playground
```
### list all apps linked to the solr service

```shell
# usage
dokku solr:links <service>
```

examples:

List all apps linked to the 'lolipop' solr service. :

```shell
dokku solr:links lolipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the solr service database

```shell
# usage
dokku solr:import <service>
```

examples:

Import a datastore dump:

```shell
dokku solr:import lolipop < database.dump
```
### export a dump of the solr service database

```shell
# usage
dokku solr:export <service>
```

examples:

By default, datastore output is exported to stdout:

```shell
dokku solr:export lolipop
```

You can redirect this output to a file:

```shell
dokku solr:export lolipop > lolipop.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### sets up authentication for backups on the solr service

```shell
# usage
dokku solr:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

examples:

Setup s3 backup authentication:

```shell
dokku solr:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku solr:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku solr:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku solr:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```
### removes backup authentication for the solr service

```shell
# usage
dokku solr:backup-deauth <service>
```

examples:

Remove s3 authentication:

```shell
dokku solr:backup-deauth lolipop
```
### creates a backup of the solr service to an existing s3 bucket

```shell
# usage
dokku solr:backup <service> <bucket-name> [--use-iam]
```

examples:

Backup the 'lolipop' service to the 'my-s3-bucket' bucket on aws:

```shell
dokku solr:backup lolipop my-s3-bucket --use-iam
```
### sets encryption for all future backups of solr service

```shell
# usage
dokku solr:backup-set-encryption <service> <passphrase>
```

examples:

Set a gpg passphrase for backups:

```shell
dokku solr:backup-set-encryption lolipop
```
### unsets encryption for future backups of the solr service

```shell
# usage
dokku solr:backup-unset-encryption <service>
```

examples:

Unset a gpg encryption key for backups:

```shell
dokku solr:backup-unset-encryption lolipop
```
### schedules a backup of the solr service

```shell
# usage
dokku solr:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

examples:

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku solr:backup-schedule lolipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku solr:backup-schedule lolipop "0 3 * * *" my-s3-bucket --use-iam
```
### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku solr:backup-schedule-cat <service>
```

examples:

Cat the contents of the configured backup cronfile for the service:

```shell
dokku solr:backup-schedule-cat lolipop
```
### unschedules the backup of the solr service

```shell
# usage
dokku solr:backup-unschedule <service>
```

examples:

Remove the scheduled backup from cron:

```shell
dokku solr:backup-unschedule lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `SOLR_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.