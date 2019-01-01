#!/bin/bash
powerpc64-linux-gnu-as -o loop.o -mregnames -mcell -be loop.s
powerpc64-linux-gnu-ld --oformat=binary -o loop.bin loop.o
rm loop.o