#!/bin/sh

rake assets:precompile -j4 --trace
bundle exec rails server -b 0.0.0.0
