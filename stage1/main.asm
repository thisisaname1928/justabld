bits 16
org 0x7c00

_start:
    call clrscr
    mov si, test
    call print16
    call switch2ProtectedMode
    hlt
    jmp $

; si as input
print16:
    pusha
    mov ah, 0xe
    mov bh, 0

    .loop:
        ; get str[i]
        mov al, [si]
        ; is end of string
        cmp al, 0
        je .end
        
        ; draw
        int 0x10
        ;inc des
        inc si
        jmp .loop
    .end:
    popa
    ret

test: db "A BOOTLOADER!", 0

clrscr:
    pusha
    mov ah, 0x0f
    int 0x10
    mov ah, 0
    int 0x10
    popa
    ret

switch2ProtectedMode:
    cli
    lgdt [GDT32R]

    mov eax, cr0 
    or al, 1
    mov cr0, eax

    jmp (GDT32.CODE - GDT32):PM

bits 32

PM:
    mov ax, GDT32.DATA - GDT32
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esi, test32
    call print32

    jmp $
    hlt

test32: db "WELCOME TO PM MODE!", 0

; esi as str
print32:
    pushad
    mov ebx, [.curPos]
    mov ah, 0x0f
    .loop:
        mov al, [esi]
        
        cmp al, 0
        je .end

        mov word [ebx], ax
        inc esi
        add ebx, 2
        jmp .loop
    .end:
    mov dword [.curPos], ebx
    popad
    ret
.curPos:
    dd 0xb8000

GDT32R:
    dw GDT32.END - GDT32 - 1
    dd GDT32

GDT32:
    .NULL:
        dq 0
    .CODE:
        dw 0xffff
        dw 0
        db 0
        db 0x9a
        db 0xcf
        db 0
    .DATA:
        dw 0xffff
        dw 0
        db 0
        db 0x92
        db 0xcf
        db 0
    .END:

times 510 - ($ - $$) db 0
dw 0xAA55  