[org 0x7C00]

section .bss
	input_buffer resb 16
section .text
start:
	cli			; zákaz přerušení
	xor ax, ax 		; nastavení ax na 0
	mov ss, ax		; nastavení ss na 0
	mov sp, 0x7C00		; nastavení sp na adresu 0x7C00
	mov ds, ax		; nastavení ds na 0
	mov es, ax		; nastavení es na 0
	sti			; povolení přerušení
	mov [boot_drive], dl 	; uložení čísla disku se zavaděčem do paměti
	mov bp, 0x7C00
	mov si, start_message
	call print_string
	mov si, newline
	call print_string
	call load_kernel
	call enter_pm
	jmp $
%include "io.asm"

kernel equ 0x1000
load_kernel:
	mov ah, 0x2
	mov al, 0x1
	mov bx, kernel
	mov dl, [boot_drive]
	mov dh, 0x0
	mov cl, 0x2
	mov ch, 0x0
	int 0x13
	jc kernel_load_error
	jnc kernel_load_successful
	kernel_load_successful:
	mov si, kernel_loading_success
	call print_string
	mov si, newline
	call print_string
	ret
	kernel_load_error:
	mov si, kernel_loading_error
	call print_string
	ret
	
%include "gdt.asm"
;; enter protected mode
enter_pm:
	cli
	lgdt [gdt_descriptor]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:pmode_init


[bits 32]
pmode_init:
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ebp, 0x90000
	mov esp, ebp
	call pmode_start

%include "pm_io.asm"
pmode_start:
	mov ebx, pmode_message
	call print_string_pm
	jmp kernel	
	jmp $

boot_drive db 0
start_message db "Starting Bootsector", 0
prompt db "shell> ", 0
kernel_loading_error db "Kernel loading failed.", 0
kernel_loading_success db "Kernel loaded successfully.", 0	
pmode_message db "In protected mode...", 0	
newline db 10, 13, 0
times 510-($-$$) db 0
dw 0xAA55
