#!/bin/sh


cat bootstrap.bundle.min.js jquery-latest.min.js noty.js script.js > opiate.js
../../tools/UglifyJS/bin/uglifyjs opiate.js > opiate.min.js
