#!/usr/bin/env bash

function seed {
  echo ""
  echo "========="
  echo "Seed to populize"
  echo "========="
  echo "1: Production"
  echo "2: Development"
  echo ""

  read -p "Choose: [1] -> " CHOOSE

  case "$CHOOSE" in
    2)
      ENV="development"
      SEED="dev_seed";;
    *)
      ENV="production"
      SEED="seed";;
  esac
}

function confirmation() {
  echo $1
  echo ""

  read -p "Choose: [y|N] -> " CHOOSE

  case "$CHOOSE" in
    y)
      ;;
    *)
      echo "Exiting..."
      exit 1;;
  esac
}

function database_selection() {
  echo ""
  echo "Type the database name, the environment is not necessary (consul_<name>_environment)"
  echo "Ex: 'someProject' => This will be computed as consul_someProject_environment"
  echo "If you leave this in blank, the default db will be populized, you can see it in config/database.yml"
  echo ""

  read -p "Database name: -> " CHOOSE

  case "$CHOOSE" in
    "")
      echo "Using default database";;
    *)
      DB_NAME=$CHOOSE;;
  esac
}

while test $# -gt 0
do
  case "$1" in
    -n)
        echo "Running without questions..."
        ACCEPT=true;;
  esac
  shift
done

ENV="production"

if [[ $ACCEPT != "true" ]]; then
  confirmation "Are you sure that you want to populize the database?"

  database_selection

  seed

  DB_NAME="consul_${DB_NAME}"
fi

echo ""
echo "Using $ENV environment..."

if [[ $DB_NAME != "" ]]; then
  echo "Attacking ${DB_NAME}_$ENV database..."
else
  echo "Attacking default database..."
fi

if [[ $ACCEPT != "true" ]]; then
  echo ""
  echo "Making a pause of 5 seconds for security..."
  sleep 5
fi

if [[ $DB_NAME != "" ]]; then
  case "$SEED" in
    seed)
      echo ""
      echo "Using production seed..."
      echo ""
      RAILS_ENV=$ENV DATABASE=$DB_NAME bundle exec rake db:seed
      ;;
    dev_seed)
      echo ""
      echo "Using development seed..."
      echo ""
      RAILS_ENV=$ENV DATABASE=$DB_NAME bundle exec rake db:dev_seed
      ;;
  esac
else
  case "$SEED" in
    seed)
      echo ""
      echo "Using production seed..."
      echo ""
      RAILS_ENV=$ENV bundle exec rake db:seed
      ;;
    dev_seed)
      echo ""
      echo "Using development seed..."
      echo ""
      RAILS_ENV=$ENV bundle exec rake db:dev_seed
      ;;
  esac
fi
