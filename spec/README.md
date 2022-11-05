# API Specification 
This directory houses the RAML spec for Ptolemy, as well as a shell script that
can be used to view the documentation in an HTML preview.

## Dependencies

The `serve_docs` script has several dependencies:
- python3 (for the http server)
- raml2html :: `npm install -g raml2html`
- inotify-utils :: `supdo apt install inotify-utils`
- xdg-utils :: `sudo apt install xdg-utils`

On WSL, you also need to install `wslu` and set the `BROWSER` variable to `wslview`, as per: https://superuser.com/a/1368878

## Usage
1. `cd spec` :: Both the file watches and HTTP server are sensitive to the
current working directory. The script expects to be launched from the `spec` directory.
2. `./serve_doc.sh`

On start:
- A Python server will begin serving files from the `spec` directory
- A browser window will open, showing the contents of `ptolemy.html`.
- Upon any edits to `ptolemy.raml`, the output HTML will be rebuilt. A refresh
of the browser window can be used to view the changes.