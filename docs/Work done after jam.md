This document contains a list of things that I changed in the repo since the end of the 3 hour jam. the `main` branch is now protected and is a snapshot of what the code/project looked like after 3 hours. 

- Added a branch protection rule for `main` branch in github
- Created this document, [What I Learned](), and [What I would have done differently]()
- renamed `Docker-compose.yaml` to `docker-compose.yaml` to to allow for running the Makefile on linux/case sensitive os. 
- removed errant `/` in `docker-compose.yaml`
- comment out the `app_mode` property in `grafana.ini`. This was me playing with a setting that I did not know what it did while on the default branch. I want to keep it production so that the web server is started. 