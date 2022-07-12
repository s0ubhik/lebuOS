[ORG 0x7C00]
[BITS 16]
mov [DISK_NUM], dl

call cls

mov bx, welcome
call printb

SECTORS_READ equ 1

;mov ax, 0
;mov es, ax
mov ah, 2
mov al, SECTORS_READ
mov ch, 0
mov cl, 2
mov dh, 0
mov dl, [DISK_NUM]
mov bx, 0x1000
int 0x13

jc disk_read_err
cmp al, SECTORS_READ
je after_disk_read
disk_read_err:
  mov bx, eror_disk_read
  call printb
  jmp end

after_disk_read:
call loadGDT
mov bx, eror_gdt
call printb
jmp end

; FUNCTIONS
loadGDT:
  call cls
  cli
  lgdt [gdt_desc]

  mov eax, cr0
  or eax, 1
  mov cr0, eax

  mov ax, DATA_SEG
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  jmp CODE_SEG:protectedMode
  ret

printb:
  mov ah, 0x0e
  mov al, [bx]
  cmp al, 0
  jne printb_p
  ret
  printb_p:
  int 0x10
  inc bx
  jmp printb

cls:
  mov ax, 0003h
  int 10h
  ret

welcome:
  db "Lebu Bootloader",0xa,0xd,0

eror_disk_read:
  db "Canot read Disk :(",0xa,0xd,0

eror_gdt:
  db "Cannot Enter Protected Mode :(",0xa,0xd,0

DISK_NUM:
  db 0

gdt:
gdt_null:
    dd 0
    dd 0
gdt_cs:
    dw 0xffff
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0
gdt_ds:
    dw 0xffff
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0
gdt_end:

gdt_desc:
    dw gdt_end - gdt - 1
    dd gdt

CODE_SEG equ gdt_cs - gdt
DATA_SEG equ gdt_ds - gdt

end:
  jmp $

[BITS 32]
protectedMode:
  call 0x1000
  ret

times 510 - ($-$$) db 0
dw 0xAA55
