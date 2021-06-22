#!/bin/bash

echo "Converting from myst to ipynb..."
jupytext --to ipynb caterva_workshop.md
jupyter nbconvert --to notebook --execute caterva_workshop.ipynb

echo "Generating slides from ipynb..."
jupyter nbconvert --to slides --output-dir html caterva_workshop.nbconvert.ipynb;

echo "Cleaning up..."
rm *.ipynb

mv html/caterva_workshop.nbconvert.slides.html html/index.html
cp -r static html

echo "Done!";
