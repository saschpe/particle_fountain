# Particle Fountain
Originally i had to write this program to pass a lecture for my Computer
Sciences studies. So this program is mainly for educational purposes and
neither shows good programming style nor the best way to get things done.
Regardless, it just works for me. Nevertheless it can be useful because there
isn't much information available on the topic in the web.

# Prequisites
Install svgalib (called *libvga* on Debian or "svgalib.i686" on Fedora). Install 
NASM (the Netwide Assembler), i.e.:

    sudo dnf install svgalib.i686 svgalib-devel.i686 nasm

# Building
You can build the executable yourself by:

    $ nasm -f elf asm_effect.s
    $ gcc asm_effect.o -lvga -o asm_effect

Or simply run:

    $ make

You need to run the binary as root, i.e.:
   
    $ sudo ./particle_fountain
