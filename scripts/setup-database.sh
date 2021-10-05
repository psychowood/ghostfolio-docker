#!/bin/sh
cd /ghostfolio

while ! curl http://postgres:5432/ 2>&1 | grep '52'
do
  sleep 1
done

yarn setup:database
echo 'Login as Admin with the following Security Token: ae76872ae8f3419c6d6f64bf51888ecbcc703927a342d815fafe486acdb938da07d0cf44fca211a0be74a423238f535362d390a41e81e633a9ce668a6e31cdf9'
echo 'Go to the Admin Control Panel and click Gather All Data to fetch historical data'
echo 'Click Sign out and check out the Live Demo'
echo 'Enjoy!'


