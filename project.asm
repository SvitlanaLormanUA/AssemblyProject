.model small
.stack 100h

.data
    buffer      db 128 dup(?)    ; Buffer for storing input
    keyBuffer   db 16 dup(?)     ; Buffer for storing the key
    sortedKeys  db 16 dup(?)     ; Buffer for storing sorted keys
    sortedCount dw ?             ; Number of sorted keys

.code
main proc
                      mov  ax, @data                    ; Load data segment address
                      mov  ds, ax                       ; Initialize data segment

                      mov  ah, 3Fh                      ; DOS function for opening a file
                      mov  bx, 0                        ; File handle (0 = standard input)
                      lea  dx, buffer                   ; Pointer to buffer
                      mov  cx, 128                      ; Number of bytes to read
                      int  21h                          ; DOS interrupt

                      cmp  ax, cx                       ; Compare bytes read with buffer size
                      jae  checking_eof                 ; If end of file reached, proceed to checking EOF
                      mov  cx, ax                       ; Update the count of characters read

                      jmp  ascii_hex                    ; Jump to convert ASCII to hex

    checking_eof:     
    ; Check end of file
                      mov  ah, 3Eh                      ; DOS function for checking EOF
                      mov  bx, 0                        ; File handle (0 = standard input)
                      int  21h                          ; DOS interrupt

    ; If EOF pointer is not equal to 128 (0x80), file has ended
                      cmp  ax, 80h
                      je   ascii_hex                    ; If not EOF, convert ASCII to hex
                      jmp  exit_program                 ; Otherwise, exit the program

    ascii_hex:        
                      mov  si, offset buffer            ; Set SI to the beginning of the buffer
                      mov  di, offset keyBuffer         ; Set DI to the beginning of the key buffer
                      mov  cx, 16                       ; Initialize CX with the length of the buffer

    convert_loop:     
                      xor  al,al
                      mov  al, [si]                     ; Load the character
                      sub  al, '0'                      ; Convert ASCII to binary
                      cmp  al, 9                        ; Check if the character is a digit
                      jbe  store_hex                    ; If less than or equal to 9, store directly
                      sub  al, 7                        ; Otherwise, adjust for A-F

    store_hex:        
                      mov  [di], al                     ; Store the character in the key buffer
                      inc  di                           ; Move to the next position in the key buffer
                      inc  si                           ; Move to the next character
                      loop convert_loop                 ; Repeat until CX != 0

                      jmp  calculate_average            ; After converting to hex, calculate average

calculate_average:
  ; Initialize sum and count variables
  mov ax, 0  ; Clear AX (sum)
  mov cx, 0  ; Clear CX (count)
  mov si, offset keyBuffer  ; Set SI to the beginning of the key buffer

sum_loop:
  xor al, al  ; Clear AL (accumulator) before loading new value
  mov al, [si]  ; Load value from key buffer
  sub al, '0'  ; Convert ASCII to binary
 mov al, byte ptr al  ; Load the byte value from memory address a into the AL register
add ax, ax          ; Add the byte value in AL to the AX register
 
  add cx, 1    ; Increment count
  inc si       ; Move to next value in buffer
  cmp si, offset keyBuffer + 16  ; Check end of buffer
  jb sum_loop  ; If not end, continue loop

  ; Calculate average
  div cx  ; Divide sum by count

    ; Now sort the keys based on their average values
    mov  si, offset keyBuffer       ; Set SI to the beginning of the key buffer
    mov  cx, 8                      ; Number of keys to process (16 bytes / 2 bytes per key)
    dec  cx                         ; Set to count - 1 for loop control
outerLoop:
    push cx                         ; Preserve outer loop counter

    lea  si, keyBuffer              ; Set SI to the beginning of the key buffer
innerLoop:
    mov  ax, [si]                   ; Load current key
    cmp  ax, [si+2]                 ; Compare current key with the next key
    jl   nextStep                   ; If less, proceed to the next step

    xchg [si+2], ax                 ; Swap keys
    mov  [si], ax
nextStep:
    add  si, 2                      ; Move to the next key
    loop innerLoop                  ; Repeat until inner loop counter is zero

    pop  cx                         ; Restore outer loop counter
    loop outerLoop                  ; Repeat until outer loop counter is zero

    ; Store the number of sorted keys
   ; Now output the sorted keys
mov si, offset keyBuffer  ; Set SI to the beginning of sorted keys (in keyBuffer)
mov cx, 8                  ; Number of keys to output (assuming 8 keys)

output_loop:
  mov dl, [keyBuffer]  ; Load key for output from keyBuffer
  add dl, '0'  ; Convert back to ASCII
  mov ah, 02h  ; DOS function for displaying character
  int 21h     ; Display character

  ; Debugging output to verify the content of the sortedKeys buffer (optional)
   mov dl, ','  ; Delimiter for debugging output
   int 21h     ; Display delimiter

  inc si        ; Move to next key in keyBuffer
  dec cx        ; Decrement the count of keys to output
  jnz output_loop  ; Repeat until all keys are printed

exit_program:     
    ; Terminate program
    mov  ax, 4c00h
    int  21h

main endp
end main


main endp
end main
