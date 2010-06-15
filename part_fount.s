# Particle Fountain
#
# (C) 2007 Sascha Peilicke <sasch.pe@gmx.de>
#
# This program is free software and is released under the
# terms of the GNU General Public License. Please visit
# http://www.gnu.org/licenses/gpl.txt for details.

.text                               ; Section
helptext:                           ; Message to be displayed, when the 
                                    ; program was started
.ascii    "Run as root, because svgalib needs direct screen access\n",
          "For more info on svgalib visit http://www.svgalib.org\n\n"
          "Press <Enter> to continue and <Any> key to exit...\0"


;.bss                               ; Section

.global _main                       ; tell the linker where our entry
_main:                              ; point is
    pushl   %ebp                    ; save EBP register
    mov     %esp, %ebp
    ; Display message and wait for keypress
    pushl   helptext
    call    puts                    ; libc function
    add     $4, %esp                ; faster than pop
    call    getchar                 ; libc function, awaits keypress
    add     $4, %esp
    mov     %ebp, %esp
    popl
    mov     $0, %eax
    ret
