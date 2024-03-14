.model small
.stack 100h

.data
  filename db 'test.in', 0
  buffer_size equ 64
  buffer db buffer_size dup(?)   
  symbols db 64 dup(?)           ; Assuming maximum of 64 symbols

.code
main proc
  ; Open file for reading
  mov ah, 3Dh               ; DOS function for opening file
  lea dx, filename          ; Address of filename string
  int 21h                   ; Call DOS service

  ; Error handling (add appropriate actions):
  jc file_error

  mov bx, ax                ; Store file descriptor in bx

  ; Read data from file into buffer
  mov ah, 3Fh               ; DOS function for reading
  mov cx, buffer_size       ; Buffer size
  lea dx, buffer            ; Address of buffer
  int 21h                   ; Call DOS service

  ; Store symbols from buffer into memory
  mov si, offset buffer     ; Point to the beginning of the buffer
  mov di, offset symbols    ; Point to the beginning of the symbols array
  mov cx, buffer_size       ; Number of symbols to read
  rep movsb                 ; Copy symbols from buffer to memory

  mov ah, 3Eh               ; DOS function for closing file
  int 21h                   ; Call DOS service

  ; Sort symbols in memory
  mov cx, buffer_size       ; Number of symbols to sort
  dec cx                    ; Start sorting from the second symbol
outer_loop:
  mov si, offset symbols    ; Point to the beginning of the symbols array
inner_loop:
  mov al, [si]        ; Load current symbol
  mov ah, [si+1]      ; Load next symbol
  cmp al, ah          ; Compare current symbol with next symbol
  jbe no_swap           ; **Changed from jbe to jg for ascending sort**
  mov [si], ah        ; Swap symbols
  mov [si+1], al
no_swap:
  add si, 1                 ; Move to next pair of symbols
  loop inner_loop           ; Continue inner loop until all pairs are compared
  loop outer_loop           ; Continue outer loop until all symbols are sorted

  ; Print the sorted symbols from memory
  mov si, offset symbols    ; Point to the beginning of the symbols array
print_loop:
  mov ah, 02h               ; DOS function for displaying character
  mov dl, [si]              ; Load symbol from memory
  int 21h                   ; Call DOS service to display
  inc si                    ; Move to the next symbol
  loop print_loop           ; Continue printing until all symbols are printed

  ; Exit program
  mov ah, 4Ch               ; DOS function for program termination
  int 21h                   ; Call DOS service

file_error:
  ; Handle file opening error (e.g., display error message)
  mov ah, 9                 ; DOS function for displaying string
  lea dx, error_message     ; Address of error message string
  int 21h                   ; Call DOS service
  jmp exit_program          ; Jump to program termination

exit_program:
  ; Additional actions before program terminates (if needed)

error_message db 'Помилка при відкритті файлу!', 0
end main ;close file

