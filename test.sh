#!/bin/sh
find ./day* -name 'day*.rb' | sort | xargs -L1 ruby
