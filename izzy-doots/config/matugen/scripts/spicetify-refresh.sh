#!/bin/bash

echo "$(date): Matugen Spicetify hook fired" >> /tmp/matugen-spicetify.log

/home/surfarch/.spicetify/spicetify refresh >> /tmp/matugen-spicetify.log 2>&1
