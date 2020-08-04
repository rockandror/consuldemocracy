#!/usr/bin/env bash

echo -e "Make sure that you execute first bin/configurator first in order to access the database"

DROP=y CREATE=y MIGRATE=y JUST_INITIALIZE=n RAILS_ENV=test run.sh

RAILS_ENV=test COVERAGE=yes rspec
