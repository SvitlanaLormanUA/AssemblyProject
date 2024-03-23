.model small
.stack 100h

.data
oneChar db ?
numbersCount dw 0
numbersArray dw 100 dup(?) ; Assuming a maximum of 100 numbers
median dw ?
average dw ?

.code
main:
    mov ax, @data
    mov ds, ax
<<<<<<< HEAD
    jmp read_next

    jc error                    ; Call routine to handle errors

    mov [handle], ax            ; Save file handle for later

; Read file and put characters into buffer
read_next:
    mov ah, 3Fh                 ; DOS Read File function number
    mov bx, 0           ; File handle
    mov cx, 1                   ; 1 byte to read
    mov dx, offset oneChar      ; Read to ds:dx 
    int 21h                     ; AX = number of bytes read

    push ax                     ; Preserve ax
    call procChar               ; Process the read character
    pop ax                      ; Restore ax

    or ax, ax                   ; Check if ax is zero (end of file)
    jnz read_next               ; If not zero, continue reading

    ; Clean values last number
    mov si, offset values
    mov bx, valInd
    dec bx
    add si, bx
    mov al, 0
    mov [si], al

 
    ; Convert values to hexadecimal
    jmp convert_values_to_hex
=======

    call read_next
    call parseNumbers
    call sort
    call calculateAverage
    call calculateMedian

    mov ah, 4Ch
    int 21h

read_next:
    mov ah, 3Fh
    mov bx, 0h 
    mov cx, 1  
    mov dx, offset oneChar  
    int 21h 
>>>>>>> a6397c15f7cf871268d38e48ece85503e565c963

    ; do something with [oneChar]
    cmp oneChar, ' '    
    je saveNumber        
    cmp oneChar, 0Dh     
    je saveNumber        
    cmp oneChar, 0Ah     
    je saveNumber       

    or ax, ax            
    jnz read_next       
    ret

saveNumber:
    push ax
     push bx ; Save bx if you're using it elsewhere
    mov bx, numbersCount ; bx will be our index to calculate the effective address
mov si, numbersArray
mov bx, numbersCount
shl bx, 1 ; Multiply bx by 2 to account for 2-byte numbers
add si, bx ; Calculate the offset
mov [si], ax ; Store the value in the array
inc numbersCount ; Increment count;
;Multiply bx by 2 because each number is 2 bytes
    inc numbersCount
    pop bx ; Restore bx if it was used elsewhere

    inc numbersCount    
    ret

print_numbers:
    mov cx, numbersCount              

print_loop:
    pop ax                
    mov dl, al             
    mov ah, 02h           
    int 21h               
    loop print_loop        

    ret

parseNumbers:
    ; No need for implementation since numbers are already saved during input.
    ret

sort:
    ; Bubble sort implementation
    mov bx, numbersCount
    dec bx

outer_loop:
    mov si, 0
inner_loop:
    mov ax, [numbersArray + si]
    cmp ax, [numbersArray + si + 2]
    jg swap
    inc si
    loop inner_loop

    dec bx
    jnz outer_loop

    ret

swap:
    mov dx, [numbersArray + si]
  mov dx, [numbersArray + si + 2] ; Move the value at (numbersArray + si + 2) into dx
mov [numbersArray + si], dx ; Store the value in dx at (numbersArray + si)

    mov [numbersArray + si + 2], dx
    ret

calculateAverage:
    mov ax, 0
    mov cx, numbersCount
    mov si, 0
average_loop:
    add ax, [numbersArray + si]
    add si, 2
    loop average_loop
    mov average, ax
    mov dx, 0
    div cx
    mov average, ax
    ret

calculateMedian:
    mov ax, numbersCount
    shr ax, 1 ; Divide by 2
    mov bx, ax
    shl ax, 1 ; Multiply by 2 (effectively dividing by 2 and rounding down to even if necessary)

   mov bx, ax ; Move the value of ax into bx
shl bx, 1 ; Multiply bx by 2 to account for 2-byte numbers
mov dx, [numbersArray + bx] ; Load the value from the calculated offset into dx

    mov median, dx

    ret
  
end main
