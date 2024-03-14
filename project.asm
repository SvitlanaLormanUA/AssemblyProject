.model small
.stack 100h

.data
  filename db 'test.in', 0
  buffer_size equ 64
  buffer db buffer_size dup(?)
  sorted_buffer db buffer_size dup(?)

.code
main proc
  ; Open the file for reading
  mov ah, 3Dh            ; DOS function for opening a file
  lea dx, filename       ; Address of the filename string
  int 21h                ; Call DOS service

  ; Check for errors while opening the file
  jc file_error

  mov bx, ax             ; Store the file descriptor in bx

  ; Read data from the file into the buffer
read_loop:  
  mov ah, 3Fh            ; DOS function for reading from a file
  mov cx, buffer_size    ; Buffer size
  lea dx, buffer         ; Address of the buffer
  int 21h                ; Call DOS service

  ; Check for end of file (EOF)
  jz end_reading

  ; Sort the buffer
  call sort_buffer

  ; Print the sorted data
  call print_buffer

  ; Move to the next block of data in the file
  jmp read_loop

end_reading:
  ; Close the file
  mov ah, 3Eh            ; DOS function for closing a file
  int 21h                ; Call DOS service

  ; Exit the program
  mov ah, 4Ch            ; DOS function for terminating a program
  int 21h                ; Call DOS service

file_error: 
  ; Handle file opening error
  ; Add appropriate actions here

sort_buffer proc
  ; Sorting buffer code
  ; Bubble Sort Algorithm
  mov si, offset buffer       ; Point SI to the start of buffer
  mov cx, buffer_size - 1     ; Set counter for outer loop
outer_loop:
  mov di, si                  ; Set DI to the start of buffer for each pass
  mov dx, cx                  ; Reset counter for inner loop
inner_loop:
  mov al, [di]                ; Load current character
  cmp al, [di+1]              ; Compare with next character
  jbe no_swap                  ; If not greater, don't swap
  mov ah, [di+1]              ; Else, exchange characters
  mov [di+1], al
  mov [di], ah
no_swap:
  inc di                      ; Move to next character
  dec dx                      ; Decrement counter
  jnz inner_loop              ; Continue until inner loop counter is not zero
  dec cx                      ; Decrement outer loop counter
  jnz outer_loop              ; Continue until outer loop counter is not zero
sort_buffer endp

print_buffer proc
  ; Printing buffer content code
  mov si, offset buffer       ; Point SI to the start of buffer
  mov cx, buffer_size         ; Set counter
print_loop:
  mov dl, [si]                ; Load character
  mov ah, 02h                 ; Function for displaying character
  int 21h                     ; Call DOS service
  inc si                      ; Move to next character
  loop print_loop             ; Continue until all characters are printed
print_buffer endp

main endp
end main
