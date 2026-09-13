#!/bin/sh
# Compile every standalone TikZ figure to a PDF (used by the LaTeX build) and
# an SVG (used by the web build). Both are committed, so `quarto render` never
# needs LaTeX for the figures and the HTML build stays fast.
#
# Run from this directory after editing any fig-*.tex or *.lua:
#     ./build.sh            all figures
#     ./build.sh fig-outage one figure
set -eu

cd "$(dirname "$0")"

targets=${*:-$(ls fig-*.tex | sed 's/\.tex$//')}

for b in $targets; do
  printf '%s ... ' "$b"
  lualatex -interaction=nonstopmode -halt-on-error "$b.tex" >"$b.build.log" 2>&1 || {
    echo "FAILED — see $b.build.log"
    exit 1
  }
  pdftocairo -svg "$b.pdf" "$b.svg"
  rm -f "$b.build.log"
  echo "ok"
done

rm -f ./*.aux ./*.log
