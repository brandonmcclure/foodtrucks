# Foodtrucks

This project is a demonstration of how I would use monitoring as code for some [foodtruck](https://data.sfgov.org/Economy-and-Community/Mobile-Food-Facility-Permit/rqzj-sfat/data) data. I am going to focus on production readiness of this code and document where there are shortcomings.

## User Story

As a connoisseur of food trucks, I would like to ensure that there are enough food trucks of a specific type in a close enough location so that I can actively petition/deploy new trucks when needed.

## Dependencies

Docker, pwsh core, gnu make, git

### Docker

The prometheus stack will run as a docker compose file running our own linux based images. See the [docker documentation](https://docs.docker.com/engine/install/) for how to install. I am using [docker desktop on windows](https://docs.docker.com/desktop/install/windows-install/)

### pwsh core

I am targeting [powershell 7](https://docs.microsoft.com/en-us/shows/it-ops-talk/how-to-install-powershell-7), or more generally pwsh core. My favorite way to keep pwsh maintained is through a [chocolatey package](https://community.chocolatey.org/packages/pwsh)

### gnu make

I use [gnu make](https://www.gnu.org/software/make/) as a semantic layer and early prototype for CI. The [Makefile](Makefile) will be the main documentation for that thinking until I build github actions.

### git

You will need git and git-lfs to interact with this repo. If you do not have lfs, the only thing that will be affected is the documentation. 

### VS Code (Nice to have)

I used VS Code for my development environment. The Docker, Gremlins tracker for Visual Studio Code, HashiCorp Terraform, and Powershell extensions are all very helpful. As is the ability to customize/write code snippets. Also MarkdownImage was great for streamlining images into markdown files