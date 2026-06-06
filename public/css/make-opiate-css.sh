#!/bin/sh


cat bootstrap.css bootstrap-icons.min.css style.css > opiate.css
java -jar ../../tools/yuicompressor-2.4.8.jar opiate.css > opiate.min.css
