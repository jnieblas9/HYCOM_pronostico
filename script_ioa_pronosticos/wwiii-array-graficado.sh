#!/bin/bash

index=0
for i in 1 2 3
do
        for j in 120h_periodo.ncl 120h_altura.ncl 120h_altura_marejada.ncl  120h_periodo_marejada.ncl
        do
                array_scripts[$index]=$j
                index=$((index+1))
        done
done

index=0
for i in wo gom pom
do
        for j in 1 2 3 4
        do
                array_dominios[$index]=$i
                index=$((index+1))
        done
done

echo ${array_scripts[@]}
echo ${array_dominios[@]}

