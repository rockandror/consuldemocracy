#!/bin/bash

function custom {
  # Custom behaviour of the application
  :
}

function verbose {
  echo "DEBUGGING is $DEBUGGING..."
  echo "ENV is $ENV..."
  echo "CREATE is $CREATE..."
  echo "MIGRATE is $MIGRATE..."
  echo "SEED is $SEED..."
  echo "JUST_INITIALIZE is $JUST_INITIALIZE..."
}

function rails_env {
  echo ""
  echo "========="
  echo "Rails environment"
  echo "========="
  echo "1: Production"
  echo "2: Development"
  echo "3: Test"
  echo ""

  read -p "Choose: [1] -> " CHOOSE

  case "$CHOOSE" in
    2)
      ENV="development";;
    3)
      ENV="test";;
    *)
      ENV="production";;
  esac
}

function seed {
  echo ""
  echo "========="
  echo "Seed to populize"
  echo "========="
  echo "1: Production"
  echo "2: Development"
  echo "3: None"
  echo ""

  read -p "Choose: [3] -> " CHOOSE

  case "$CHOOSE" in
    1)
      SEED="seed";;
    2)
      SEED="dev_seed";;
  esac
}

function menu {

  rails_env

  read -p "Create the database? (y|n) [n] -> " CREATE

  echo ""

  case "$CREATE" in
    y)
      : ${CREATE:="y"};;
    *)
      : ${CREATE:="n"};;
  esac

  case "$CREATE" in
    y)
      read -p "Migrate the database? (y|n) [y] -> " MIGRATE;;
    *)
      read -p "Migrate the database? (y|n) [n] -> " MIGRATE;;
  esac

  case "$CREATE" in
    y)
      : ${MIGRATE:="y"};;
    *)
      : ${MIGRATE:="n"};;
  esac

  seed

  echo ""

  read -p "Run the server? (y|n) [y] -> " JUST_INITIALIZE
}

function help {
  echo ""
  echo "================================================================"
  echo "                          Consul Help"
  echo "================================================================"
  echo ""
  echo "Runs CONSUL application using unicorn and bundle."
  echo ""
  echo "By default, Rails environment is production and the server will start."
  echo ""
  echo "Usage:"
  echo "    -d: Debug mode. Any bundle exec will execute, use this just to test how application works."
  echo "    -h: Display this message"
  echo "    -v: Verbose mode. Show all variables."
  echo "    -m: Run the application manually"
  echo ""
  echo "          Rails environment (1|2|3) -> (Production, Development or Test respectivelly)"
  echo ""
  echo "          Create the database (y|n) [n]"
  echo "          Like \"bin/rake db:create\""
  echo "          If this option is \"y\", by default, MIGRATE is \"y\""
  echo ""
  echo "          Migrate the database (y|n) [n]"
  echo "          Like \"bin/rake db:migrate\""
  echo ""
  echo "          The seed that database will initialize. (1|2) -> (Production or Development respectivelly)"
  echo "          Like \"bin/rake db:seed\" or \"bin/rake db:dev_seed\""
  echo ""
  echo "          Run the server (y|n) [y]"
  echo ""
  echo ""
  exit 1
}

while test $# -gt 0
do
  case "$1" in
    -h)
        help;;
    -m)
        MENU="true";;
    -v)
        VERBOSE="true";;
    -d)
        DEBUGGING="true";;
  esac
  shift
done

if [[ $MENU == "true" ]]; then
  menu
fi

: ${DEBUGGING:="false"}

# Check existence of RAILS_ENV
if [ -z ${RAILS_ENV+x} ]; then
  : ${ENV:="production"}
else
  echo "Rails environment was setted manually to $RAILS_ENV"
  ENV=$RAILS_ENV
fi

: ${JUST_INITIALIZE:="y"}

# Call the custom behaviour
custom

if [[ $VERBOSE == "true" ]]; then
  verbose
fi

echo ""
echo "Using $ENV environment..."
echo ""

if [[ $CREATE == "y" ]]; then
  echo ""
  echo "Create the database..."
  echo ""
  [[ $DEBUGGING == "false" ]] && RAILS_ENV=$ENV bundle exec rake db:create
fi

if [[ $MIGRATE == "y" ]]; then
  echo ""
  echo "Migrating the database..."
  echo ""
  [[ $DEBUGGING == "false" ]] && RAILS_ENV=$ENV bundle exec rake db:migrate
fi

case "$SEED" in
  seed)
    echo ""
    echo "Using production seed..."
    echo ""
    [[ $DEBUGGING == "false" ]] && RAILS_ENV=$ENV bundle exec rake db:seed
    ;;
  dev_seed)
    echo ""
    echo "Using development seed..."
    echo ""
    [[ $DEBUGGING == "false" ]] && RAILS_ENV=$ENV bundle exec rake db:dev_seed
    ;;
esac

if [[ $ENV == "production" ]]; then
  echo ""
  echo "Generating assets for public folder..."
  echo ""
  [[ $DEBUGGING == "false" ]] && RAILS_ENV=$ENV bundle exec rake assets:precompile
fi

if [[ $JUST_INITIALIZE == "y" ]]; then
  echo ""
  echo "Server starting..."
  echo ""
  [[ $DEBUGGING == "false" ]] && RAILS_ENV=$ENV bundle exec unicorn -c config/unicorn.rb
else
  echo ""
  echo "Server will not start..."
  echo ""
fi
