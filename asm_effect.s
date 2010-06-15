section .data
msgIntro    db  "############################################################",10,
            db  "# Particle_Fountain                                        #",10,
            db  "#   written by Sascha Peilicke @2006                       #",10,
            db  "#   mailto: sasch.pe@gmx.de  www: http://saschashideout.de #",10,
            db  "#                                                          #",10,
            db  "# This program is free software and is released under the  #",10,
            db  "# terms of the GNU General Public License. Please visit    #",10,
            db  "# http://www.gnu.org/licenses/gpl.txt for details.         #",10,
            db  "############################################################",10,10,
            db  "For more information on svgalib visit http://www.svgalib.org",10,
            db  "Run as root, because svgalib needs direct screen access",10,10,
            db  "Press <Enter> to continue and <Any> key to exit...",0

; Some constants for the preprocessor
%define     PART_COUNT 300           ; number of particles
%define     MAX_VX 9                 ; maximum x axis velocity
%define     MAX_VY 32                ; maximum y axis velocity
%define     GRAV_Y -1                ; pull down
%define     DRAW_COLOR 50            ; color for particles, must be smaller than 256

section .bss
; Particle data structure organised as linear arrays for easy access
part_X      times PART_COUNT    resd 1
part_Y      times PART_COUNT    resd 1
part_VX     times PART_COUNT    resd 1
part_VY     times PART_COUNT    resd 1

; Declare some symbols from external libraries which will be linked in later
extern rand,puts,getchar
extern vga_init,vga_setmode,vga_getkey,vga_drawpixel
extern vga_setcolor,vga_clear,vga_waitretrace

section .text
    global  main                    ; needed for the linker
main:                               ; same like "int main(int argc,char** argv)
    pusha                           ; save all registers
    mov     ebp,esp
; Display message and wait for keypress
    push    dword msgIntro
    call    puts                    ; libc function
    add     esp,4                   ; faster than pop
    call    getchar                 ; libc function
    add     esp,4
; Init video mode
    call    vga_init                ; svgalib function, will also drop root rights
    push    dword 11                ; set mode 11 = 800x600x256
    call    vga_setmode             ; svgalib function
    add     esp,4                   ; faster than popping function parameter of the stack

; Initialise particle data with color and position values
    mov     ecx,PART_COUNT       
initParticles:                      ; run over the buffer and init every particle
    push    ecx                     ; save counter, so we can use ecx register
    call    initPart    
    pop     ecx                     ; restore counter
    loop    initParticles           ; if ecx != 0 do loop

videoloop:                          ; loop for displaying eyecandy and watching keypresses
    call    vga_clear               ; svgalib function - clear screen
    mov     ecx,PART_COUNT
drawParticles:                      ; this loop draws all particles
    push    ecx                     ; save counter, maybe changed accidentialy
    call    updatePart 
    call    drawPart              
    pop     ecx                     ; restore counter for loop check
    loop    drawParticles
    call    vga_getkey              ; svgalib function, return value resides in eax
    cmp     eax,0                   ; if zero than no key pressed
    jz      videoloop

; Deinitialisation of everything
    push    dword 0                 ; setmode to 0 = textmode
    call    vga_setmode             ; svgalib function 
    add     esp,4                   ; same as popping the param of the stack
    mov     esp,ebp
    popa                            ; restore all registers
    mov     eax,0                   ; return value 0 - all fine
    ret                             ; back to the caller


 
; Function inits a particle
section .text
initPart:                           ; parameter "particle number" must be in ecx
    mov     eax,400                 ; emit them all of the same position      
    mov     [part_X+ecx*4],eax      
    mov     eax,600                 ; so that we get a fountain
    mov     [part_Y+ecx*4],eax
    push    ecx
    call    badRandom               ; update random value
    mov     eax,[ranVal]            ; get random value
    mov     ebx,MAX_VX*2            ; get divisor
    xor     edx,edx
    div     ebx                     ; edx:eax / ebx
    sub     edx,MAX_VX              ; interval [-VX,VX]
    pop     ecx
    mov     [part_VX+ecx*4],edx     ; apply new velocity

    push    ecx
    call    badRandom               ; update random value
    mov     eax,[ranVal]            ; get random value
    xor     edx,edx                 ; mov edx, 0 
    mov     ebx,MAX_VY              ; get divisor
    div     ebx                     ; edx:eax / ebx
    pop     ecx
    mov     [part_VY+ecx*4],edx
    ret                             ; and return

; Function updates a particle
section .text
updatePart:                         ; param "particle number" must be in ecx
    mov     eax,[part_Y+ecx*4]      ;
    cmp     eax,600                 ; see if particle has fallen out of the screen
    jle     noReinit                ; if y < 600  then not init 
    call    initPart                ; else reinit particle
noReinit:         
    mov     eax,[part_VX+ecx*4]     ; get particle x velocity     
    add     [part_X+ecx*4],eax      ; add x velocity to x position
    mov     eax,[part_VY+ecx*4]     ; get particle y velocity
    sub     [part_Y+ecx*4],eax      ; add y velocity to y position
    mov     eax,GRAV_Y
    add     [part_VY+ecx*4],eax     ; damp y velocity    
    ret                             ; and return

; Function draws a particle
section .text
drawPart:                           ; param "part_number" must be in ecx
    push    dword DRAW_COLOR        ; push particle color on stack
    call    vga_setcolor            ; svgalib function
    add     esp,4                   ; faster than pop
    push    dword [part_Y+ecx*4]    ; push particle y coordinate
    push    dword [part_X+ecx*4]    ; push particle x coordinate
    call    vga_drawpixel           ; svgalib function
    add     esp,8                   ; pop 2 dwords of stack
    ret                             ; and return

; This rather odd function encapsulates libc rand()
; For some odd reason i don't know it messes up several registers
section .text
badRandom:                      
    pusha                           ; to avoid headaches save all
    call    rand                    ; call stupid function
    mov     [ranVal],eax            ; save random value elsewhere
    popa                            ; TODO: Fix this
    ret
section .bss
ranVal      resd 1                  ; this is a random value, updated by badRandom
