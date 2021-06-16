#!/bin/bash

echo "Converting from myst to ipynb..."
jupytext --to ipynb caterva_workshop.md

echo "Generating slides from ipynb..."
jupyter nbconvert --to slides --output-dir html *.ipynb;

echo "Cleaning up..."
rm *.ipynb

echo "Done!";
