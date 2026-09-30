#!/usr/bin/env bash

dir="$HOME/.config/rofi/launchers/type-4"
theme='style-6'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
