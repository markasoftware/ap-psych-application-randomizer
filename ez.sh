#!/usr/bin/env bash

./templates-fill.pl "${1:-10}" | pdflatex >/dev/null && okular texput.pdf
