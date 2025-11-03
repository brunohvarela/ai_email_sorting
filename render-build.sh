#!/usr/bin/env bash
set -o errexit

mix deps.get --only prod
mix deps.compile

#npm install --prefix ./assets
#mix assets.deploy  # compila JS/CSS e roda phx.digest

mix phx.digest

#mix compile
mix release