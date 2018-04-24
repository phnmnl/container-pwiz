#!/bin/sh

xauth list | cut -d" " -f 3- | xargs xauth add :0 
XAUTHORITY=/root/.Xauthority-n wine MSconvertGUI
