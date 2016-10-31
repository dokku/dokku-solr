#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
  dokku apps:create my_app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm -rf "$DOKKU_ROOT/my_app"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l
  assert_contains "${lines[*]}" "Please specify an app to run the command on"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l not_existing_app
  assert_contains "${lines[*]}" "App not_existing_app does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" not_existing_service my_app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service is already promoted" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  assert_contains "${lines[*]}" "already promoted as SOLR_URL"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) changes SOLR_URL" {
  dokku config:set my_app "SOLR_URL=http://u:p@host:8983/db" "DOKKU_SOLR_BLUE_URL=http://dokku-solr-l:8983/solr/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app SOLR_URL)
  assert_equal "$url" "http://dokku-solr-l:8983/solr/l"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) creates new config url when needed" {
  dokku config:set my_app "SOLR_URL=http://u:p@host:8983/db" "DOKKU_SOLR_BLUE_URL=http://dokku-solr-l:8983/solr/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  run dokku config my_app
  assert_contains "${lines[*]}" "DOKKU_SOLR_"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) uses SOLR_DATABASE_SCHEME variable" {
  dokku config:set my_app "SOLR_DATABASE_SCHEME=solr2" "SOLR_URL=http://host:8983" "DOKKU_SOLR_BLUE_URL=solr2://dokku-solr-l:8983/solr/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app SOLR_URL)
  assert_equal "$url" "solr2://dokku-solr-l:8983/solr/l"
}
