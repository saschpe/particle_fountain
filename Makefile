#
# Makefile for asm_effect
#

srcname = asm_effect
target  = particle_fountain

all: 
	nasm -f elf ${srcname}.s
	gcc -v ${srcname}.o -lvga -o ${target}

clean:
	rm ${target} ${srcname}.o
