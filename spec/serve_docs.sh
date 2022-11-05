#!/bin/bash

python3 -m http.server 9000 &

xdg-open http://localhost:9000/ptolemy.html

# https://stackoverflow.com/a/2173421
# Kills the http server when the script exits
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# https://superuser.com/a/181543
# magic incantation to rerun raml2html when the raml file changes.
inotifywait -e close_write,moved_to,create -m . |
while read -r directory events filename; do
  if [ "$filename" = "ptolemy.raml" ]; then
    raml2html ptolemy.raml > ptolemy.html
  fi
done

