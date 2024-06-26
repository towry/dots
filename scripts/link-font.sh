#!/usr/bin/env bash

echo "> Removing if exists"
rm -rf $HOME/Library/fonts/BerkeleyMonoNerdFont

echo "> Copy fonts"
cp -R $HOME/Library/Mobile\ Documents/com~apple~CloudDocs/BerkeleyMonoNerdFont $HOME/Library/fonts/BerkeleyMonoNerdFont

echo "> Done"
