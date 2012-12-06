#!/bin/bash
#
# Randomly split data into 70% training and 30% test.
#

cd train-full

for i in *.csv; do
  tail -n+2 $i | gshuf | split -a 1 -l $(expr $(cat $i | wc -l) \* 7 / 10) - "$i" &&
  cat header "${i}a" > ../train/$i &&
  cat header "${i}b" > ../test/$i &&
  rm "${i}a" "${i}b"
done

cd ..
