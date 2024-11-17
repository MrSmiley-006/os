%ifndef IO
%define IO
VIDEO_MEMORY equ 0xb8000	
print_char:
	mov ah, 0x0E
	int 0x10
	ret

print_string:
	loop:
	lodsb
	call print_char
	cmp al, 0
	jne loop
	ret

read_char:
	mov ah, 0x00
	int 0x16
	ret

read_string:
	loop2:
	call read_char
	mov dl, al
	call print_char
	mov al, dl
	cmp al, 0xD
	je done
	stosb
	jmp loop2
	done:
	mov byte [di], 0
	ret

	global print_char
	global print_string
	global read_char
	global read_string
%endif
