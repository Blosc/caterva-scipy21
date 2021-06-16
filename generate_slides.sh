#!/bin/bash

echo "Converting from myst to ipynb..."
jupytext --to ipynb caterva_workshop.md

echo "Generating slides from ipynb..."
jupyter nbconvert --to slides --output-dir html caterva_workshop.ipynb;

echo "Cleaning up..."
rm *.ipynb

mv html/caterva_workshop.slides.html html/index.html

echo "Done!";
