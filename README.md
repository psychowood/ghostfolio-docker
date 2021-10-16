# ghostfolio-docker
All-in-one ghostfolio setup in a docker environment

**[Ghostfolio](https://github.com/ghostfolio/ghostfolio)** is an open source wealth management software built with web technology. The application empowers busy people to keep track of their wealth like stocks, ETFs or cryptocurrencies and make solid, data-driven investment decisions. 

Imho it is a very nice and promising project, and deserves to be looked upon.

## Why?

While Ghostfolio [setup](https://github.com/ghostfolio/ghostfolio#getting-started) is quite straighforward and well documented, it has different drawbacks for someone - like me - that wants to really selfhost it in a docker headless environment. 

The official setup
- requires a bunch of dependencies to be installed locally (Node.js, Yarn)
- exposes both postgres and redis ports from the docker host 
- requires Ghostfolio server and client processes to be run separately

Since I'm quite a pain in the a** when I'm required to run things manually, I wanted to make everything run in a single docker stack using docker-compose.
So yes, you need docker-compose installed.

## What about this project?

This repository contains just scripts and configuration files, if you look inside everything is quite self-explanatory. 

Some notes about my choices, in case you were wondering:

- The ghostfolio-base container will not run, it will start then stop. This is normal, it's used as a base to run the setup scripts (steps 3 and 4). It could be replaced with a longer docker run command including all the volume mappings needed, but I find it cleaner cleaner having everything in a compose file 
- The base, server and client containers could probably be distributed as docker images. Maybe in the future, if the official team will not release an official image
- This project is developed and tested on [BurmillaOS](https://burmillaos.org/)
- The default UID and GID are 1100:1100

## Enough said, I want to run it!

You can set it up following these steps:

<details>
<summary> 1. <code>git clone</code> this repo in a folder of your choice inside your docker host.</summary><p>

```vb
rancher@burmilla:/mnt/containers$ git clone https://github.com/psychowood/ghostfolio-docker
Cloning into 'ghostfolio-docker'...
remote: Enumerating objects: 24, done.
remote: Counting objects: 100% (24/24), done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 24 (delta 2), reused 23 (delta 1), pack-reused 0
Unpacking objects: 100% (24/24), done.
rancher@burmilla:/mnt/containers$ cd ghostfolio-docker
rancher@burmilla:/mnt/containers/ghostfolio-docker$ ll
total 76
drwxr-xr-x 1 rancher rancher   242 Oct  2 09:53 .
drwxr-xr-x 1 rancher rancher   882 Sep 27 17:05 ..
-rw-r--r-- 1 rancher rancher  1544 Oct  2 09:53 docker-compose.yml
-rw-r--r-- 1 rancher rancher   613 Oct  2 09:53 Dockerfile
-rw-r--r-- 1 rancher rancher   352 Oct  2 09:53 .env
drwxr-xr-x 1 rancher rancher   158 Oct  2 09:54 .git
-rw-r--r-- 1 rancher rancher    66 Oct  2 09:53 .gitattributes
-rw-r--r-- 1 rancher rancher    58 Oct  2 09:53 .gitignore
-rw-r--r-- 1 rancher rancher 34503 Oct  2 09:53 LICENSE
drwxr-xr-x 1 rancher rancher    20 Oct  2 09:53 postgres-data
-rw-r--r-- 1 rancher rancher    73 Oct  2 09:53 README.md
drwxr-xr-x 1 rancher rancher    20 Oct  2 09:53 redis-data
drwxr-xr-x 1 rancher rancher   128 Oct  2 09:53 scripts
```

</details>

<details>
<summary> 2. Run <code>docker build -t ghostfolio-base .</code> inside the repo directory</summary>

to create the *ghostfolio-base* tagged image that will be used to install and run ghostfolio

```vb
rancher@burmilla:/mnt/containers/ghostfolio-docker$ docker build -t ghostfolio-base .
Sending build context to Docker daemon  270.8kB
Step 1/19 : FROM node:14-alpine3.14
 ---> 07c1d305fe0a
Step 2/19 : RUN apk --no-cache add curl xdg-utils
 ---> Using cache
 ---> 329cf685359d
Step 3/19 : ENV USER=ghostfolio
 ---> Using cache
 ---> 2fa0092fb6bb
Step 4/19 : ENV UID=1100
 ---> Using cache
 ---> 19e537c5e3c7
Step 5/19 : ENV GROUP=ghostfolio
 ---> Using cache
 ---> 75893bd79ad7
Step 6/19 : ENV GID=1100
 ---> Using cache
 ---> 969e274db440
Step 7/19 : RUN addgroup -g "$GID" "$GROUP"
 ---> Using cache
 ---> 4b0b99b46869
Step 8/19 : WORKDIR /ghostfolio/tmp
 ---> Using cache
 ---> d7e7a4bf7cea
Step 9/19 : WORKDIR /.cache
 ---> Using cache
 ---> 9719bb43270c
Step 10/19 : RUN adduser     --disabled-password     --gecos ""     --home "/ghostfolio/tmp"     --ingroup "$GROUP"     --no-create-home     --uid "$UID"     "$USER"
 ---> Using cache
 ---> d8cdb5af3337
Step 11/19 : RUN chown "$USER":"$GROUP" -vR /ghostfolio /.cache
 ---> Using cache
 ---> 00d8fbb4b2a1
Step 12/19 : USER "$USER"
 ---> Using cache
 ---> 3116c782d45d
Step 13/19 : WORKDIR /scripts
 ---> Using cache
 ---> 5d6091363273
Step 14/19 : COPY --chown="$USER":"$GROUP" scripts/* ./
 ---> e2dd30615318
Step 15/19 : RUN chmod +x *.sh
 ---> Running in cd2172d285fe
Removing intermediate container cd2172d285fe
 ---> 0b2590745e8d
Step 16/19 : WORKDIR /ghostfolio
 ---> Running in 01f10ffb6399
Removing intermediate container 01f10ffb6399
 ---> 81a11c2369f5
Step 17/19 : ENTRYPOINT
 ---> Running in 74615d3d1b1e
Removing intermediate container 74615d3d1b1e
 ---> 1456ffa4dfeb
Step 18/19 : CMD ["echo", "Nothing to run here."]
 ---> Running in 8e8fd9bf83d4
Removing intermediate container 8e8fd9bf83d4
 ---> 4e24220aff95
Step 19/19 : VOLUME ["/ghostfolio"]
 ---> Running in f94b8dcb69d4
Removing intermediate container f94b8dcb69d4
 ---> 21c6aec603bb
Successfully built 21c6aec603bb
Successfully tagged ghostfolio-base:latest
```

</details>

<details>
<summary> 3. Run <code>docker-compose run --rm base /scripts/install.sh</code>.</summary>

  This will:
   - Pull the latest Ghostfolio [release](https://github.com/ghostfolio/ghostfolio/releases/latest) from its repo
   - Decompress it
   - Run Yarn install and build ghostfolio *inside the ghostfolio-data volume*
   - Patch package.json with
       - `"start:client": "ng serve client --hmr -o"` → `start:client": "ng serve client --disable-host-check --host 0.0.0.0"` 
           - remove `--hmr` since hot module replacement is not needed 
           - remove `-o` since you can't open a browser inside an remote docker host
           - add `--disable-host-check` to allow reaching ghostfolio with a different hostname than *localhost* 
           - add `--host 0.0.0.0` to listen on every network interface, needed for remote access
       - `"start:server": "nx serve api --watch"` → `start:server": "nx serve api"`
           - remove `--watch` since watches for changes and rebuilds application is not needed
           
   - Patch apps/client/proxy.conf.json
       - `"target": "http://localhost:3333"` → `"target": "http://server:3333"`
           - Use *server* as api hostname as defined in docker-compose.yml

```vb
rancher@burmilla:/mnt/containers/ghostfolio-docker$ docker-compose run --rm base /scripts/install.sh
Creating volume "ghostfolio_postgres-data" with default driver
Creating volume "ghostfolio_redis-data" with default driver
Creating ghostfolio_base_run ... done
Connecting to api.github.com (140.82.121.6:443)
Connecting to codeload.github.com (140.82.121.9:443)
writing to stdout
-                    100% |************************************************************************************************|  765k  0:00:00 ETA
written to stdout
yarn install v1.22.5
[1/5] Validating package.json...
[2/5] Resolving packages...
[3/5] Fetching packages...
info fsevents@2.3.2: The platform "linux" is incompatible with this module.
info "fsevents@2.3.2" is an optional dependency and failed compatibility check. Excluding it from installation.
info fsevents@1.2.13: The platform "linux" is incompatible with this module.
info "fsevents@1.2.13" is an optional dependency and failed compatibility check. Excluding it from installation.
[4/5] Linking dependencies...
warning "@nrwl/angular > @nrwl/cypress > @cypress/webpack-preprocessor@4.1.5" has unmet peer dependency "webpack@^4.18.1".
warning " > bootstrap@4.6.0" has unmet peer dependency "jquery@1.9.1 - 3".
warning " > bootstrap@4.6.0" has unmet peer dependency "popper.js@^1.16.1".
warning " > @nrwl/eslint-plugin-nx@12.8.0" has incorrect peer dependency "@typescript-eslint/parser@~4.28.3".
warning " > @storybook/addon-essentials@6.3.8" has unmet peer dependency "@babel/core@^7.9.6".
warning " > @storybook/addon-essentials@6.3.8" has unmet peer dependency "babel-loader@^8.0.0".
warning "@storybook/addon-essentials > @storybook/addon-measure@2.0.0" has unmet peer dependency "@storybook/components@^6.3.0".
warning "@storybook/addon-essentials > @storybook/addon-measure@2.0.0" has unmet peer dependency "@storybook/core-events@^6.3.0".
warning "@storybook/addon-essentials > @storybook/addon-measure@2.0.0" has unmet peer dependency "@storybook/theming@^6.3.0".
warning "@storybook/addon-essentials > @storybook/addons@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addons@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/api@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/api@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > storybook-addon-outline@1.4.1" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > storybook-addon-outline@1.4.1" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/builder-webpack5 > @storybook/client-api@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/builder-webpack5 > @storybook/client-api@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/builder-webpack5 > @storybook/components@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/builder-webpack5 > @storybook/components@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/builder-webpack5 > @storybook/theming@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/builder-webpack5 > @storybook/theming@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > react-inspector@5.1.1" has unmet peer dependency "react@^16.8.4 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @mdx-js/react@1.6.22" has unmet peer dependency "react@^16.13.1 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/builder-webpack4@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/builder-webpack4@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/source-loader@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/source-loader@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > react-element-to-jsx-string@14.3.2" has unmet peer dependency "react@^0.14.8 || ^15.0.1 || ^16.0.0 || ^17.0.1".
warning "@storybook/addon-essentials > @storybook/addon-docs > react-element-to-jsx-string@14.3.2" has unmet peer dependency "react-dom@^0.14.8 || ^15.0.1 || ^16.0.0 || ^17.0.1".
warning "@storybook/builder-webpack5 > @storybook/router@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/builder-webpack5 > @storybook/router@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/api > @reach/router@1.3.4" has unmet peer dependency "react@15.x || 16.x || 16.4.0-alpha.0911da3".
warning "@storybook/addon-essentials > @storybook/api > @reach/router@1.3.4" has unmet peer dependency "react-dom@15.x || 16.x || 16.4.0-alpha.0911da3".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > markdown-to-jsx@7.1.3" has unmet peer dependency "react@>= 0.14.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-colorful@5.4.0" has unmet peer dependency "react@>=16.8.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-colorful@5.4.0" has unmet peer dependency "react-dom@>=16.8.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-popper-tooltip@3.1.1" has unmet peer dependency "react@^16.6.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-popper-tooltip@3.1.1" has unmet peer dependency "react-dom@^16.6.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-syntax-highlighter@13.5.3" has unmet peer dependency "react@>= 0.14.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-textarea-autosize@8.3.3" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/theming > @emotion/core@10.1.1" has unmet peer dependency "react@>=16.3.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/theming > @emotion/styled@10.0.27" has unmet peer dependency "react@>=16.3.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/theming > emotion-theming@10.0.27" has unmet peer dependency "react@>=16.3.0".
warning "@storybook/manager-webpack5 > @storybook/ui@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/manager-webpack5 > @storybook/ui@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/manager-webpack5 > @storybook/core-client@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/manager-webpack5 > @storybook/core-client@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/core > @storybook/core-server@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/core > @storybook/core-server@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/api > @reach/router > create-react-context@0.3.0" has unmet peer dependency "react@^0.14.0 || ^15.0.0 || ^16.0.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-popper-tooltip > react-popper@2.2.5" has unmet peer dependency "react@^16.8.0 || ^17".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-textarea-autosize > use-composed-ref@1.1.0" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-textarea-autosize > use-latest@1.2.0" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/theming > @emotion/styled > @emotion/styled-base@10.0.31" has unmet peer dependency "react@>=16.3.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/builder-webpack4 > @storybook/ui > downshift@6.1.7" has unmet peer dependency "react@>=16.12.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/builder-webpack4 > @storybook/ui > markdown-to-jsx@6.11.4" has unmet peer dependency "react@>= 0.14.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/builder-webpack4 > @storybook/ui > react-draggable@4.4.4" has unmet peer dependency "react@>= 16.3.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/builder-webpack4 > @storybook/ui > react-draggable@4.4.4" has unmet peer dependency "react-dom@>= 16.3.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/builder-webpack4 > @storybook/ui > react-helmet-async@1.1.2" has unmet peer dependency "react@^16.6.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/builder-webpack4 > @storybook/ui > react-helmet-async@1.1.2" has unmet peer dependency "react-dom@^16.6.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/core > @storybook/core-server > @storybook/manager-webpack4@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-docs > @storybook/core > @storybook/core-server > @storybook/manager-webpack4@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning "@storybook/addon-essentials > @storybook/addon-actions > @storybook/components > react-textarea-autosize > use-latest > use-isomorphic-layout-effect@1.1.1" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning " > @storybook/angular@6.3.8" has unmet peer dependency "@angular-devkit/architect@>=0.8.9".
warning " > @storybook/angular@6.3.8" has unmet peer dependency "@angular-devkit/core@^0.6.1 || >=7.0.0".
warning " > @storybook/angular@6.3.8" has unmet peer dependency "@babel/core@*".
warning " > @storybook/builder-webpack5@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning " > @storybook/builder-webpack5@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning " > @storybook/manager-webpack5@6.3.8" has unmet peer dependency "react@^16.8.0 || ^17.0.0".
warning " > @storybook/manager-webpack5@6.3.8" has unmet peer dependency "react-dom@^16.8.0 || ^17.0.0".
warning " > codelyzer@6.0.1" has incorrect peer dependency "@angular/compiler@>=2.3.1 <12.0.0 || ^11.0.0-next || ^11.1.0-next || ^11.2.0-next".
warning " > codelyzer@6.0.1" has incorrect peer dependency "@angular/core@>=2.3.1 <12.0.0 || ^11.0.0-next || ^11.1.0-next || ^11.2.0-next".
warning " > codelyzer@6.0.1" has unmet peer dependency "tslint@^5.0.0 || ^6.0.0".
[5/5] Building fresh packages...
warning Your current version of Yarn is out of date. The latest version is "1.22.15", while you're on "1.22.5".
info To upgrade, run the following command:
$ curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
$ prisma generate && ngcc --properties es2015 browser module main
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma

✔ Generated Prisma Client (2.30.2) to ./node_modules/@prisma/client in 2.25s
You can now start using Prisma Client in your code. Reference: https://pris.ly/d/client

import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()

Compiling @angular/animations : es2015 as esm2015
Compiling @angular/cdk/keycodes : es2015 as esm2015
Compiling @angular/core : es2015 as esm2015
Compiling @angular/compiler/testing : es2015 as esm2015
Compiling @nrwl/angular/testing : es2015 as esm2015
Compiling @angular/animations : main as umd
Compiling @angular/cdk/keycodes : main as umd
Compiling @nrwl/angular/testing : main as umd
Compiling @angular/compiler/testing : main as umd
Compiling @angular/animations/browser : es2015 as esm2015
Compiling @angular/cdk/observers : es2015 as esm2015
Compiling @angular/common : es2015 as esm2015
Compiling @angular/cdk/collections : es2015 as esm2015
Compiling @angular/cdk/platform : es2015 as esm2015
Compiling @angular/cdk/bidi : es2015 as esm2015
Compiling @angular/platform-browser : es2015 as esm2015
Compiling @angular/cdk/a11y : es2015 as esm2015
Compiling @angular/forms : es2015 as esm2015
Compiling @angular/platform-browser/animations : es2015 as esm2015
Compiling @angular/cdk/scrolling : es2015 as esm2015
Compiling @angular/cdk/portal : es2015 as esm2015
Compiling @angular/cdk/layout : es2015 as esm2015
Compiling @angular/cdk/overlay : es2015 as esm2015
Compiling @angular/common/http : es2015 as esm2015
Compiling @angular/material/core : es2015 as esm2015
Compiling @angular/cdk/text-field : es2015 as esm2015
Compiling @angular/cdk/accordion : es2015 as esm2015
Compiling @angular/cdk/stepper : es2015 as esm2015
Compiling @angular/material/form-field : es2015 as esm2015
Compiling @angular/material/button : es2015 as esm2015
Compiling @angular/material/icon : es2015 as esm2015
Compiling @angular/material/tooltip : es2015 as esm2015
Compiling @angular/material/select : es2015 as esm2015
Compiling @angular/material/input : es2015 as esm2015
Compiling @angular/material/divider : es2015 as esm2015
Compiling @angular/cdk/table : es2015 as esm2015
Compiling @angular/material/sort : es2015 as esm2015
Compiling @angular/material/paginator : es2015 as esm2015
Compiling @angular/cdk/tree : es2015 as esm2015
Compiling @angular/core/testing : es2015 as esm2015
Compiling @angular/platform-browser-dynamic : es2015 as esm2015
Compiling @angular/platform-browser/testing : es2015 as esm2015
Compiling @angular/common/testing : es2015 as esm2015
Compiling @angular/router : es2015 as esm2015
Compiling ngx-skeleton-loader : es2015 as esm2015
Compiling @angular/animations/browser/testing : es2015 as esm2015
Compiling @angular/cdk/clipboard : es2015 as esm2015
Compiling @angular/cdk/drag-drop : es2015 as esm2015
Compiling @angular/common/http/testing : es2015 as esm2015
Compiling @angular/material/autocomplete : es2015 as esm2015
Compiling @angular/material/badge : es2015 as esm2015
Compiling @angular/material/bottom-sheet : es2015 as esm2015
Compiling @angular/material/button-toggle : es2015 as esm2015
Compiling @angular/material/checkbox : es2015 as esm2015
Compiling @angular/material/card : es2015 as esm2015
Compiling @angular/material/chips : es2015 as esm2015
Compiling @angular/material/datepicker : es2015 as esm2015
Compiling @angular/material/dialog : es2015 as esm2015
Compiling @angular/material/expansion : es2015 as esm2015
Compiling @angular/material/grid-list : es2015 as esm2015
Compiling @angular/material/icon/testing : es2015 as esm2015
Compiling @angular/material/list : es2015 as esm2015
Compiling @angular/material/menu : es2015 as esm2015
Compiling @angular/material/progress-bar : es2015 as esm2015
Compiling @angular/material/progress-spinner : es2015 as esm2015
Compiling @angular/material/radio : es2015 as esm2015
Compiling @angular/material/sidenav : es2015 as esm2015
Compiling @angular/material/slide-toggle : es2015 as esm2015
Compiling @angular/material/slider : es2015 as esm2015
Compiling @angular/material/snack-bar : es2015 as esm2015
Compiling @angular/material/stepper : es2015 as esm2015
Compiling @angular/material/table : es2015 as esm2015
Compiling @angular/material/tabs : es2015 as esm2015
Compiling @angular/material/toolbar : es2015 as esm2015
Compiling @angular/material/tree : es2015 as esm2015
Compiling @angular/platform-browser-dynamic/testing : es2015 as esm2015
Compiling @angular/router/testing : es2015 as esm2015
Compiling angular-material-css-vars : es2015 as esm2015
Compiling ngx-device-detector : es2015 as esm2015
Compiling ngx-stripe : es2015 as esm2015
Compiling @angular/animations/browser : main as umd
Compiling @angular/animations/browser/testing : main as umd
Compiling @angular/core : main as umd
Compiling @angular/common : main as umd
Compiling @angular/cdk/clipboard : main as umd
Compiling @angular/cdk/platform : main as umd
Compiling @angular/cdk/bidi : main as umd
Compiling @angular/cdk/collections : main as umd
Compiling @angular/cdk/scrolling : main as umd
Compiling @angular/cdk/observers : main as umd
Compiling @angular/cdk/a11y : main as umd
Compiling @angular/cdk/drag-drop : main as umd
Compiling @angular/common/http : main as umd
Compiling @angular/common/http/testing : main as umd
Compiling @angular/platform-browser : main as umd
Compiling @angular/platform-browser/animations : main as umd
Compiling @angular/forms : main as umd
Compiling @angular/material/core : main as umd
Compiling @angular/cdk/portal : main as umd
Compiling @angular/cdk/overlay : main as umd
Compiling @angular/material/form-field : main as umd
Compiling @angular/cdk/layout : main as umd
Compiling @angular/material/badge : main as umd
Compiling @angular/material/autocomplete : main as umd
Compiling @angular/material/bottom-sheet : main as umd
Compiling @angular/material/button-toggle : main as umd
Compiling @angular/material/card : main as umd
Compiling @angular/material/checkbox : main as umd
Compiling @angular/material/chips : main as umd
Compiling @angular/material/button : main as umd
Compiling @angular/cdk/text-field : main as umd
Compiling @angular/material/input : main as umd
Compiling @angular/material/datepicker : main as umd
Compiling @angular/material/dialog : main as umd
Compiling @angular/cdk/accordion : main as umd
Compiling @angular/material/expansion : main as umd
Compiling @angular/material/grid-list : main as umd
Compiling @angular/material/icon : main as umd
Compiling @angular/material/icon/testing : main as umd
Compiling @angular/material/divider : main as umd
Compiling @angular/material/list : main as umd
Compiling @angular/material/menu : main as umd
Compiling @angular/material/progress-bar : main as umd
Compiling @angular/material/progress-spinner : main as umd
Compiling @angular/material/radio : main as umd
Compiling @angular/material/sidenav : main as umd
Compiling @angular/material/slide-toggle : main as umd
Compiling @angular/material/slider : main as umd
Compiling @angular/material/snack-bar : main as umd
Compiling @angular/cdk/stepper : main as umd
Compiling @angular/material/stepper : main as umd
Compiling @angular/material/select : main as umd
Compiling @angular/cdk/table : main as umd
Compiling @angular/material/tooltip : main as umd
Compiling @angular/material/paginator : main as umd
Compiling @angular/material/sort : main as umd
Compiling @angular/material/table : main as umd
Compiling @angular/material/tabs : main as umd
Compiling @angular/material/toolbar : main as umd
Compiling @angular/cdk/tree : main as umd
Compiling @angular/material/tree : main as umd
Compiling @angular/platform-browser-dynamic : main as umd
Compiling @angular/core/testing : main as umd
Compiling @angular/platform-browser/testing : main as umd
Compiling @angular/platform-browser-dynamic/testing : main as umd
Compiling @angular/common/testing : main as umd
Compiling @angular/router/testing : main as umd
Compiling angular-material-css-vars : main as umd
Compiling @angular/router : main as umd
Compiling ngx-device-detector : main as umd
Compiling ngx-skeleton-loader : module as esm5
Compiling ngx-skeleton-loader : main as umd
Compiling ngx-stripe : main as umd
Done in 734.24s.
```

</details>
 
<details>
<summary> 4. Run <code>docker-compose up -d postgres && docker-compose run --rm base /scripts/setup-database.sh && docker-compose stop postgres</code>.</summary>
It will start postgres, wait for it to be ready, then execute the ghostfolio db setup via *yarn setup:database*

```vb
rancher@burmilla:/mnt/containers/ghostfolio-docker$ docker-compose up -d postgres && docker-compose run --rm base /scripts/setup-database.sh && docker-compose stop postgres
Building with native build. Learn about native build in Compose here: https://docs.docker.com/go/compose-native-build/
Creating ghostfolio_postgres_1 ... done
Creating ghostfolio_base_run ... done
curl: (52) Empty reply from server
yarn run v1.22.5
$ yarn database:push && yarn database:seed
$ prisma db push
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Datasource "db": PostgreSQL database "ghostfolio-db", schema "public" at "postgres:5432"

🚀  Your database is now in sync with your schema. Done in 21.55s

✔ Generated Prisma Client (2.30.2) to ./node_modules/@prisma/client in 915ms

┌─────────────────────────────────────────────────────────┐
│  Update available 2.30.2 -> 3.2.0                       │
│  Run the following to update                            │
│    yarn add --dev prisma                                │
│    yarn add @prisma/client                              │
└─────────────────────────────────────────────────────────┘
$ prisma db seed --preview-feature
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Running seed: ts-node --compiler-options '{"module":"CommonJS"}' "prisma/seed.ts" ...
{
  platformBitcoinSuisse: {
    id: '70b6e475-a2b9-4527-99db-943e4f38ce45',
    name: 'Bitcoin Suisse',
    url: 'https://www.bitcoinsuisse.com'
  },
  platformBitpanda: {
    id: 'debf9110-498f-4811-b972-7ebbd317e730',
    name: 'Bitpanda',
    url: 'https://www.bitpanda.com'
  },
  platformCoinbase: {
    id: '8dc24b88-bb92-4152-af25-fe6a31643e26',
    name: 'Coinbase',
    url: 'https://www.coinbase.com'
  },
  platformDegiro: {
    id: '94c1a2f4-a666-47be-84cd-4c8952e74c81',
    name: 'DEGIRO',
    url: 'https://www.degiro.eu'
  },
  platformInteractiveBrokers: {
    id: '9da3a8a7-4795-43e3-a6db-ccb914189737',
    name: 'Interactive Brokers',
    url: 'https://www.interactivebrokers.com'
  },
  platformPostFinance: {
    id: '5377d9df-0d25-42c2-9d9b-e4c63166281e',
    name: 'PostFinance',
    url: 'https://www.postfinance.ch'
  },
  platformSwissquote: {
    id: '1377d9df-0d25-42c2-9d9b-e4c63156291f',
    name: 'Swissquote',
    url: 'https://swissquote.com'
  },
  userAdmin: {
    accessToken: 'c689bcc894e4a420cb609ee34271f3e07f200594f7d199c50d75add7102889eb60061a04cd2792ebc853c54e37308271271e7bf588657c9e0c37faacbc28c3c6',
    alias: 'Admin',
    authChallenge: null,
    createdAt: 2021-10-05T22:37:58.350Z,
    id: '4e1af723-95f6-44f8-92a7-464df17f6ec3',
    provider: null,
    role: 'ADMIN',
    thirdPartyId: null,
    updatedAt: 2021-10-05T22:37:58.352Z
  },
  userDemo: {
    accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjliMTEyYjRkLTNiN2QtNGJhZC05YmRkLTNiMGY3YjRkYWMyZiIsImlhdCI6MTYxODUxMjAxNCwiZXhwIjoxNjIxMTA0MDE0fQ.l3WUxpI0hxuQtdPrD0kd7sem6S2kx_7CrdNvkmlKuWw',
    alias: 'Demo',
    authChallenge: null,
    createdAt: 2021-10-05T22:37:58.576Z,
    id: '9b112b4d-3b7d-4bad-9bdd-3b0f7b4dac2f',
    provider: null,
    role: 'DEMO',
    thirdPartyId: null,
    updatedAt: 2021-10-05T22:37:58.578Z
  }
}

🌱  Your database has been seeded.
Done in 124.89s.
Login as Admin with the following Security Token: ae76872ae8f3419c6d6f64bf51888ecbcc703927a342d815fafe486acdb938da07d0cf44fca211a0be74a423238f535362d390a41e81e633a9ce668a6e31cdf9
Go to the Admin Control Panel and click Gather All Data to fetch historical data
Click Sign out and check out the Live Demo
Enjoy!
Stopping ghostfolio_postgres_1 ... done
```

</details>

<details>
<summary> 5. At this point, ghostfolio is ready to go and you can start it as usual using <code>docker-compose up -d</code> and, after a good while, you'll be able to reach ghostfolio app @ http://yourdockerhost:4200 .
</summary><p>If you want to monitor the startup sequence you can run <code>docker-compose logs -f</code>

```vb
rancher@burmilla:/mnt/containers/ghostfolio-docker$ docker-compose logs -f
Attaching to ghostfolio_client_1, ghostfolio_server_1, ghostfolio_base_1, ghostfolio_redis_1, ghostfolio_postgres_1
redis_1     | 1:C 06 Oct 2021 18:00:45.253 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
redis_1     | 1:C 06 Oct 2021 18:00:45.254 # Redis version=6.2.5, bits=64, commit=00000000, modified=0, pid=1, just started
redis_1     | 1:C 06 Oct 2021 18:00:45.254 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
redis_1     | 1:M 06 Oct 2021 18:00:45.255 * monotonic clock: POSIX clock_gettime
redis_1     | 1:M 06 Oct 2021 18:00:45.256 * Running mode=standalone, port=6379.
redis_1     | 1:M 06 Oct 2021 18:00:45.257 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
redis_1     | 1:M 06 Oct 2021 18:00:45.257 # Server initialized
redis_1     | 1:M 06 Oct 2021 18:00:45.258 * Ready to accept connections
postgres_1  | The files belonging to this database system will be owned by user "postgres".
postgres_1  | This user must also own the server process.
postgres_1  |
postgres_1  | The database cluster will be initialized with locale "en_US.utf8".
postgres_1  | The default database encoding has accordingly been set to "UTF8".
postgres_1  | The default text search configuration will be set to "english".
postgres_1  |
postgres_1  | Data page checksums are disabled.
postgres_1  |
postgres_1  | fixing permissions on existing directory /var/lib/postgresql/data ... ok
postgres_1  | creating subdirectories ... ok
postgres_1  | selecting dynamic shared memory implementation ... posix
postgres_1  | selecting default max_connections ... 100
postgres_1  | selecting default shared_buffers ... 128MB
postgres_1  | selecting default time zone ... Etc/UTC
postgres_1  | creating configuration files ... ok
postgres_1  | running bootstrap script ... ok
postgres_1  | performing post-bootstrap initialization ... ok
postgres_1  | syncing data to disk ... ok
postgres_1  |
postgres_1  | initdb: warning: enabling "trust" authentication for local connections
postgres_1  | You can change this by editing pg_hba.conf or using the option -A, or
postgres_1  | --auth-local and --auth-host, the next time you run initdb.
postgres_1  |
postgres_1  | Success. You can now start the database server using:
postgres_1  |
postgres_1  |     pg_ctl -D /var/lib/postgresql/data -l logfile start
postgres_1  |
postgres_1  | waiting for server to start....2021-10-05 22:34:18.615 UTC [46] LOG:  starting PostgreSQL 12.8 (Debian 12.8-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
postgres_1  | 2021-10-05 22:34:18.944 UTC [46] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgres_1  | .....2021-10-05 22:34:23.639 UTC [47] LOG:  database system was shut down at 2021-10-05 22:32:58 UTC
postgres_1  | .......2021-10-05 22:34:30.970 UTC [46] LOG:  database system is ready to accept connections
postgres_1  |  done
postgres_1  | server started
postgres_1  | CREATE DATABASE
postgres_1  |
postgres_1  |
postgres_1  | /usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*
postgres_1  |
postgres_1  | 2021-10-05 22:35:46.169 UTC [46] LOG:  received fast shutdown request
postgres_1  | waiting for server to shut down....2021-10-05 22:35:46.309 UTC [46] LOG:  aborting any active transactions
postgres_1  | 2021-10-05 22:35:46.312 UTC [46] LOG:  background worker "logical replication launcher" (PID 53) exited with exit code 1
postgres_1  | 2021-10-05 22:35:46.314 UTC [48] LOG:  shutting down
postgres_1  | .....2021-10-05 22:35:52.053 UTC [46] LOG:  database system is shut down
postgres_1  |  done
postgres_1  | 2021-10-05 22:35:52.286 UTC [1] LOG:  starting PostgreSQL 12.8 (Debian 12.8-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
postgres_1  | 2021-10-05 22:35:52.286 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
postgres_1  | 2021-10-05 22:35:52.286 UTC [1] LOG:  listening on IPv6 address "::", port 5432
postgres_1  | server stopped
postgres_1  |
postgres_1  | PostgreSQL init process complete; ready for start up.
postgres_1  |
postgres_1  | 2021-10-05 22:35:52.744 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgres_1  | 2021-10-05 22:35:56.287 UTC [75] LOG:  database system was shut down at 2021-10-05 22:35:51 UTC
postgres_1  | 2021-10-05 22:35:56.287 UTC [76] LOG:  invalid length of startup packet
postgres_1  | 2021-10-05 22:35:56.498 UTC [1] LOG:  database system is ready to accept connections
postgres_1  | 2021-10-05 22:36:14.860 UTC [83] LOG:  could not receive data from client: Connection reset by peer
postgres_1  | 2021-10-05 22:38:17.574 UTC [1] LOG:  received fast shutdown request
postgres_1  | 2021-10-05 22:38:17.729 UTC [1] LOG:  aborting any active transactions
postgres_1  | 2021-10-05 22:38:17.732 UTC [1] LOG:  background worker "logical replication launcher" (PID 82) exited with exit code 1
postgres_1  | 2021-10-05 22:38:17.734 UTC [77] LOG:  shutting down
postgres_1  |
postgres_1  | PostgreSQL Database directory appears to contain a database; Skipping initialization
postgres_1  |
postgres_1  | 2021-10-06 18:00:48.812 UTC [1] LOG:  starting PostgreSQL 12.8 (Debian 12.8-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
postgres_1  | 2021-10-06 18:00:48.824 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
postgres_1  | 2021-10-06 18:00:48.824 UTC [1] LOG:  listening on IPv6 address "::", port 5432
postgres_1  | 2021-10-06 18:00:49.015 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
postgres_1  | 2021-10-06 18:00:49.422 UTC [25] LOG:  database system shutdown was interrupted; last known up at 2021-10-05 22:38:17 UTC
postgres_1  | 2021-10-06 18:00:50.164 UTC [25] LOG:  database system was not properly shut down; automatic recovery in progress
postgres_1  | 2021-10-06 18:00:50.264 UTC [25] LOG:  redo starts at 0/164E6F8
postgres_1  | 2021-10-06 18:00:50.478 UTC [25] LOG:  invalid record length at 0/16B9A58: wanted 24, got 0
postgres_1  | 2021-10-06 18:00:50.478 UTC [25] LOG:  redo done at 0/16B9A30
postgres_1  | 2021-10-06 18:00:58.969 UTC [1] LOG:  database system is ready to accept connections
base_1      | Nothing to run here.
server_1    | yarn run v1.22.5
server_1    | $ nx serve api
server_1    |
server_1    | > nx run api:serve
server_1    |
server_1    | >  NX  Using webpack 5. Reason: detected version 5 in node_modules/webpack/package.json
server_1    |
server_1    | Found an outdated version of webpack-merge
server_1    |
server_1    | If you want to use webpack 5, try installing compatible versions of the plugins.
server_1    | See: https://nx.dev/guides/webpack-5
server_1    |
server_1    | >  NX  Falling back to webpack 4 due to incompatible plugin versions
server_1    |
server_1    | Hash: ed1d775da9dd7eea6685
server_1    | Built at: 10/06/2021 6:01:38 PM
server_1    | Entrypoint main [big] = main.js main.js.map
server_1    | chunk {main} main.js, main.js.map (main) 300 KiB [entry] [rendered]
server_1    | Issues checking in progress...
server_1    | Debugger listening on ws://localhost:9229/8c56ce70-e232-499e-9b67-ee55db58320a
server_1    | For help, see: https://nodejs.org/en/docs/inspector
server_1    | No issues found.
server_1    | [Nest] 53   - 10/06/2021, 6:03:11 PM   [NestFactory] Starting Nest application...
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ConfigurationModule dependencies initialized +790ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] PrismaModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] JwtModule dependencies initialized +93ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] JwtModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] DiscoveryModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ConfigHostModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ImpersonationModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ServeStaticModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ScheduleModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] DataProviderModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ConfigModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ConfigModule dependencies initialized +0ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ExchangeRateDataModule dependencies initialized +248ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] SubscriptionModule dependencies initialized +15ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] AccessModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] AuthDeviceModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] CacheModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] DataGatheringModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ExportModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] UserModule dependencies initialized +3ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] RedisCacheModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] InfoModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] SymbolModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] AuthModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ExperimentalModule dependencies initialized +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] AccountModule dependencies initialized +6ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] CacheModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] AppModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] AdminModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] OrderModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] ImportModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [InstanceLoader] PortfolioModule dependencies initialized +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] AppController {/api}: +276ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] AdminController {/api/admin}: +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/admin, GET} route +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/admin/gather/max, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/admin/gather/profile-data, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] SubscriptionController {/api/subscription}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/subscription/stripe/callback, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/subscription/stripe/checkout-session, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] AccessController {/api/access}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/access, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] AccountController {/api/account}: +0ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/account/:id, DELETE} route +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/account, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/account/:id, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/account, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/account/:id, PUT} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] UserController {/api/user}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/user/:id, DELETE} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/user, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/user, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/user/setting, PUT} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/user/settings, PUT} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] AuthDeviceController {/api/auth-device}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/auth-device/:id, DELETE} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] AuthController {/api/auth}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/auth/anonymous/:accessToken, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/auth/google, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/auth/google/callback, GET} route +0ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/auth/webauthn/generate-registration-options, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/auth/webauthn/verify-attestation, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/auth/webauthn/generate-assertion-options, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/auth/webauthn/verify-assertion, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] CacheController {/api/cache}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/cache/flush, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] ExperimentalController {/api/experimental}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/experimental/benchmarks, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/experimental/benchmarks/:symbol, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] ExportController {/api/export}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/export, GET} route +2ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] ImportController {/api/import}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/import, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] InfoController {/api/info}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/info, GET} route +5ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] OrderController {/api/order}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/order/:id, DELETE} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/order, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/order/:id, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/order, POST} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/order/:id, PUT} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] PortfolioController {/api/portfolio}: +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/portfolio/investments, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/portfolio/chart, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/portfolio/details, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/portfolio/performance, GET} route +0ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/portfolio/positions, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/portfolio/summary, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/portfolio/position/:symbol, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/portfolio/report, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RoutesResolver] SymbolController {/api/symbol}: +0ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/symbol/lookup, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:12 PM   [RouterExplorer] Mapped {/api/symbol/:dataSource/:symbol, GET} route +1ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:15 PM   [NestApplication] Nest application successfully started +2274ms
server_1    | [Nest] 53   - 10/06/2021, 6:03:15 PM   Listening at http://localhost:3333 +2ms
server_1    | 7d data gathering has been started.
server_1    | 7d data gathering has been completed.
server_1    | data-gathering-7d: 9.863s
ghostfolio_base_1 exited with code 0
client_1    | yarn run v1.22.5
client_1    | $ ng serve client --disable-host-check --host 0.0.0.0
client_1    | Warning: Running a server with --disable-host-check is a security risk. See https://medium.com/webpack/webpack-dev-server-middleware-security-issues-1489d950874a for more information.
client_1    | - Generating browser application bundles (phase: setup)...
client_1    | ✔ Browser application bundle generation complete.
client_1    |
client_1    | Initial Chunk Files                                                                                     | Names         |      Size
client_1    | vendor.js                                                                                               | vendor        |   5.34 MB
client_1    | styles.css                                                                                              | styles        | 284.38 kB
client_1    | main.js                                                                                                 | main          | 168.29 kB
client_1    | polyfills.js                                                                                            | polyfills     | 136.83 kB
client_1    | scripts.js                                                                                              | scripts       |  93.05 kB
client_1    | runtime.js                                                                                              | runtime       |  12.54 kB
client_1    |
client_1    | | Initial Total |   6.02 MB
client_1    |
client_1    | Lazy Chunk Files                                                                                        | Names         |      Size
client_1    | apps_client_src_app_pages_portfolio_transactions_transactions-page_module_ts.js                         | -             | 624.25 kB
client_1    | default-node_modules_chartjs-adapter-date-fns_dist_chartjs-adapter-date-fns_esm_js.js                   | -             | 604.86 kB
client_1    | apps_client_src_app_pages_portfolio_allocations_allocations-page_module_ts.js                           | -             | 502.38 kB
client_1    | default-node_modules_angular_material_fesm2015_select_js-node_modules_angular_material_fesm20-9355cf.js | -             | 295.33 kB
client_1    | default-libs_ui_src_lib_line-chart_line-chart_module_ts.js                                              | -             | 251.64 kB
client_1    | default-apps_client_src_app_components_portfolio-performance_portfolio-performance_module_ts--a7299c.js | -             | 203.16 kB
client_1    | apps_client_src_app_pages_home_home-page_module_ts.js                                                   | -             | 113.81 kB
client_1    | apps_client_src_app_pages_account_account-page_module_ts.js                                             | -             |  97.03 kB
client_1    | apps_client_src_app_pages_accounts_accounts-page_module_ts.js                                           | -             |  89.61 kB
client_1    | apps_client_src_app_pages_admin_admin-page_module_ts-node_modules_date-fns_esm__lib_assign_index_js.js  | -             |  72.99 kB
client_1    | default-apps_client_src_app_components_toggle_toggle_module_ts.js                                       | -             |  58.74 kB
client_1    | default-apps_client_src_app_components_symbol-icon_symbol-icon_module_ts-node_modules_angular-4cc55c.js | -             |  53.13 kB
client_1    | apps_client_src_app_pages_register_register-page_module_ts.js                                           | -             |  46.63 kB
client_1    | apps_client_src_app_pages_landing_landing-page_module_ts.js                                             | -             |  44.83 kB
client_1    | default-node_modules_angular_material_fesm2015_progress-spinner_js.js                                   | -             |  43.48 kB
client_1    | apps_client_src_app_pages_about_about-page_module_ts.js                                                 | -             |  42.45 kB
client_1    | default-apps_client_src_app_components_position_position_module_ts-libs_ui_src_lib_no-transac-38d8d8.js | -             |  39.37 kB
client_1    | apps_client_src_app_pages_pricing_pricing-page_module_ts.js                                             | -             |  37.90 kB
client_1    | default-apps_client_src_app_components_position_position-detail-dialog_position-detail-dialog-c1a511.js | -             |  35.86 kB
client_1    | apps_client_src_app_pages_portfolio_report_report-page_module_ts.js                                     | -             |  34.85 kB
client_1    | default-apps_client_src_app_core_auth_guard_ts-node_modules_angular_material_fesm2015_card_js.js        | -             |  33.67 kB
client_1    | apps_client_src_app_pages_blog_2021_07_hallo-ghostfolio_hallo-ghostfolio-page_module_ts.js              | -             |  33.11 kB
client_1    | apps_client_src_app_pages_zen_zen-page_module_ts.js                                                     | -             |  32.19 kB
client_1    | apps_client_src_app_pages_blog_2021_07_hello-ghostfolio_hello-ghostfolio-page_module_ts.js              | -             |  31.19 kB
client_1    | apps_client_src_app_pages_portfolio_analysis_analysis-page_module_ts.js                                 | -             |  27.62 kB
client_1    | apps_client_src_app_pages_portfolio_portfolio-page_module_ts.js                                         | -             |  24.18 kB
client_1    | default-libs_ui_src_lib_value_index_ts.js                                                               | -             |  22.86 kB
client_1    | apps_client_src_app_pages_resources_resources-page_module_ts.js                                         | -             |  17.73 kB
client_1    | apps_client_src_app_pages_webauthn_webauthn-page_module_ts.js                                           | -             |  16.20 kB
client_1    | apps_client_src_app_pages_auth_auth-page_module_ts.js                                                   | -             |   7.58 kB
client_1    | common.js                                                                                               | common        |   2.72 kB
client_1    |
client_1    | Build at: 2021-10-06T18:04:25.788Z - Hash: 3e44b00dbc12982c08a7 - Time: 121953ms
client_1    |
client_1    | Warning: /ghostfolio/apps/client/src/app/adapter/custom-date-adapter.ts depends on 'date-fns/locale/de/index'. CommonJS or AMD dependencies can cause optimization bailouts.
client_1    | For more info see: https://angular.io/guide/build#configuring-commonjs-dependencies
client_1    |
client_1    | Warning: /ghostfolio/apps/client/src/app/services/user/user.service.ts depends on '@codewithdan/observable-store'. CommonJS or AMD dependencies can cause optimization bailouts.
client_1    | For more info see: https://angular.io/guide/build#configuring-commonjs-dependencies
client_1    |
client_1    | Warning: /ghostfolio/libs/common/src/lib/config.ts depends on '@prisma/client'. CommonJS or AMD dependencies can cause optimization bailouts.
client_1    | For more info see: https://angular.io/guide/build#configuring-commonjs-dependencies
client_1    |
client_1    | Warning: /ghostfolio/libs/ui/src/lib/line-chart/line-chart.component.ts depends on '@ghostfolio/common/helper'. CommonJS or AMD dependencies can cause optimization bailouts.
client_1    | For more info see: https://angular.io/guide/build#configuring-commonjs-dependencies
client_1    |
client_1    | Warning: /ghostfolio/libs/ui/src/lib/portfolio-proportion-chart/portfolio-proportion-chart.component.ts depends on 'color'. CommonJS or AMD dependencies can cause optimization bailouts.
client_1    | For more info see: https://angular.io/guide/build#configuring-commonjs-dependencies
client_1    |
client_1    | Warning: /ghostfolio/node_modules/svgmap/dist/svgMap.min.js depends on 'svg-pan-zoom'. CommonJS or AMD dependencies can cause optimization bailouts.
client_1    | For more info see: https://angular.io/guide/build#configuring-commonjs-dependencies
client_1    |
client_1    |
client_1    |
client_1    | ** Angular Live Development Server is listening on 0.0.0.0:4200, open your browser on http://localhost:4200/ **
client_1    |
client_1    |
client_1    | ✔ Compiled successfully.
```
</details>

You can then follow the last steps from Ghostfolio setup:

 6. Login as _Admin_ with the following _Security Token_: `ae76872ae8f3419c6d6f64bf51888ecbcc703927a342d815fafe486acdb938da07d0cf44fca211a0be74a423238f535362d390a41e81e633a9ce668a6e31cdf9`

 7. Go to the _Admin Control Panel_ and click _Gather All Data_ to fetch historical data

 8. Click _Sign out_ and check out the _Live Demo_
 
 Enjoy and invest responsibly :)
