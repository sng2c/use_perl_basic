#!/bin/sh
pandoc -t revealjs  --template=template.html  --no-highlight --variable transition="linear" -s usePerl_basic_1of2.md -o usePerl_basic_1of2.html
pandoc -t revealjs  --template=template.html  --no-highlight --variable transition="linear" -s usePerl_basic_2of2.md -o usePerl_basic_2of2.html
perl -p -i -e 's/<li>/<li class="fragment roll-in">/g' usePerl_basic_1of2.html usePerl_basic_2of2.html