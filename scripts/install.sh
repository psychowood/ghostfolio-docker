#!/bin/sh
cd /ghostfolio
rm -rf tmp
mkdir tmp
cd tmp
curl -s https://api.github.com/repos/ghostfolio/ghostfolio/releases/latest | sed -n 's/.*"tarball_url": "\(.*\)",.*/\1/p' | xargs -n1 wget -O - -q | tar -xz --strip-components=1 --exclude='/*/.env'
mv .env .env.bak
(tar c .) | (cd .. && tar xf -)
cd ..
rm -rf tmp
yarn install
#yarn cache clean
