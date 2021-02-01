#!/bin/bash
for i in `seq 31 90`
do
    echo ${i}
    mkdir ./aaaa${i}
    touch ./aaaa${i}/sample${i}.txt
done
