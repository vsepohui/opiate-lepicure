#!/bin/sh


cat bootstrap.bundle.min.js jquery-latest.min.js notify.js script.js > opiate.js
../../tools/UglifyJS/bin/uglifyjs opiate.js > opiate.min.js
