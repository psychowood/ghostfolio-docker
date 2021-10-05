#!/bin/sh
cd /ghostfolio
rm -rf tmp
mkdir tmp
cd tmp
curl -s https://api.github.com/repos/ghostfolio/ghostfolio/releases/latest | sed -n 's/.*"tarball_url": "\(.*\)",.*/\1/p' | xargs -n1 wget -O - | tar -xz --strip-components=1 --exclude='/*/.env'
mv .env .env.bak
(tar c .) | (cd .. && tar xf -)
cd ..
rm -rf tmp

mv apps/client/proxy.conf.json apps/client/proxy.conf.json.bak
sed -e 's/localhost:3333/server:3333/' apps/client/proxy.conf.json.bak > apps/client/proxy.conf.json

mv package.json package.json.bak
cat package.json.bak | sed -e 's/"start:client".*$/"start:client": "ng serve client --disable-host-check --host 0.0.0.0",/' | sed -e 's/"start:server".*$/"start:server": "nx serve api",/' > package.json

yarn install
#yarn cache clean
