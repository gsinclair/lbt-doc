#!/bin/zsh

# Usage:              build.sh Enrichment
# More likely usage:  ../Common/build.sh Enrichment

project=$1

errors() {
  tail -40 $project.log |
    grep \.lua: |
    grep -v /vendor/ |
    sed 's/^.*\/luatex\/lbt/  lbt/' |
    sed 's/ in /\n                             in /'
}

(cd ../../lbt && make install)
max_print_line=10000 \
  lualatex --file-line-error --shell-escape --halt-on-error \
  $project.tex

if [[ $? -eq 1 ]]; then
  echo
  echo '= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = ='
  echo
  errors
fi
