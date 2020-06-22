#!/bin/bash

echo $0
for a in $(ls ./docs/*html); do
  sed -i 's/_static/static/g' ./$a

done
