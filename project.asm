.model small
.stack 100h

.data
  filename db 'test.in', 0
  buffer_size equ 64
  buffer db buffer_size dup(?)

.code
main proc
  ; Open file for reading
  mov ah, 3Dh               ; DOS function for opening file
  lea dx, filename         ; Address of filename string
  int 21h                   ; Call DOS service

  ; Error handling (add appropriate actions):
  jc file_error

  mov bx, ax                ; Store file descriptor in bx

  ; Read data from file into stack
read_loop:
  mov ah, 3Fh               ; DOS function for reading
  mov cx, buffer_size       ; Buffer size
  lea dx, buffer             ; Address of buffer
  int 21h                   ; Call DOS service

  ; Check for end of file (EOF)
  jz end_reading

  ; Push buffer contents onto stack
  push dx

  ; Loop until EOF is reached
  jmp read_loop

end_reading:
  ; Close file
  mov ah, 3Eh               ; DOS function for closing file
  int 21h                   ; Call DOS service

  ; Symbol sorting in stack
  mov si, sp                 ; Address of stack pointer
  mov di, sp                 ; Copy stack pointer for comparison

sort_loop:
  mov cx, buffer_size        ; Size of stack (or number of symbols to sort)
  mov ax, di                 ; Start comparison from the first element
  add ax, 2                  ; Compare with the next element

inner_loop:
  mov bx, ax                 ; Get the address of current element
  mov dl, [bx]               ; Load the symbol at current element
  cmp dl, [bx-2]              ; Compare with the previous element
  jae not_swap               ; If current >= previous, skip swap

  ; Swap symbols if the current symbol is less than the previous
  mov al, [bx]               ; Load the current symbol
  xchg al, [bx-2]             ; Exchange current and previous symbols
  mov [bx], al               ; Store the swapped symbol at current element

not_swap:
  sub ax, 2                  ; Move to the previous element for comparison
  cmp ax, si                 ; Check if all elements have been compared
  jne inner_loop             ; If not all compared, continue inner loop

  sub di, 2                  ; Move to the previous element for next iteration
  cmp di, si                 ; Check if all elements have been sorted
  jne sort_loop              ; If not all sorted, continue outer loop

  ; Print the sorted symbols from the stack
print_loop:
  mov ah, 02h               ; DOS function for displaying character
  pop dx                     ; Pop symbol from the stack
  int 21h                   ; Call DOS service to display
  cmp sp, si                 ; Check if stack is empty
  jnz print_loop            ; If not empty, continue printing

  ; Exit program
  mov ah, 4Ch               ; DOS function for program termination
  int 21h                   ; Call DOS service

file_error:
  ; Handle file opening error (e.g., display error message)
  mov ah, 9                ; DOS function for displaying string
  lea dx, error_message     ; Address of error message string
  int 21h                   ; Call DOS service
  jmp exit_program          ; Jump to program termination

exit_program:
  ; Additional actions before program terminates (if needed)

error_message db 'Помилка при відкритті файлу!', 0

end main