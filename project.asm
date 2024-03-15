.model small
.stack 100h

.data
    keyArray db 16000 dup(?)      ; 2 * 8000
    averageArray dw 16000 dup(?)  ; 2 * 8000
    counter dw ?
    keyLength dw ?
    value dw ?
    key db 16 dup(?)
    oneChar db ?
    CR db 13, 10, '$'
    successMessage db "Reading input completed successfully.", 13, 10, '$'
    maxRows equ 10000          ; Максимальна кількість рядків

.code
main PROC
    mov ax, @data
    mov ds, ax

    call read_next
    call groupAndSort
    call printString          ; Вивід результатів

    mov ax, 4C00h
    int 21h
main ENDP

read_next:
      mov ah, 3Fh
    mov bx, 0h  ; stdin handle
    mov cx, 1   ; 1 byte to read
    mov dx, offset oneChar   ; read to ds:dx 
    int 21h   ;  ax = number of bytes read
    or ax,ax
    jnz read_next

endReading:
    ; Display success message
    mov ah, 02h         ; Print string function
    lea dx, successMessage
    int 21h

    ret


processInput:
    ; Separate key and value
    mov si, offset key + 2       ; SI points to the beginning of the input string
    mov di, offset keyArray      ; DI points to keyArray
    mov cx, 16                   ; Maximum length of key
    xor ax, ax                   ; Clear AX

getChar:
    lodsb                        ; Load character from SI into AL, increment SI
    cmp al, ' '                  ; Check if space is found
    je processValue              ; If space, process the value
    cmp al, 13                   ; Check for CR
    je saveKey                   ; If CR, save the key
    stosb                        ; Store character into keyArray
    loop getChar                 ; Loop until 16 characters are read
    jmp endProcessInput          ; Jump to the end if key exceeds 16 characters

processValue:
    ; Convert string to integer
    mov si, offset key + 2       ; SI points to the beginning of the value
    call str2int                ; Convert string to integer
    mov value, ax               ; Store the integer value

    ; Process the key-value pair
    call processKeyValuePair
    jmp endProcessInput

saveKey:
    mov bx, offset key + 2       ; BX points to the beginning of the key
    sub si, bx                   ; Calculate the length of the key
    mov keyLength, si            ; Store the length of the key
    jmp endProcessInput

endProcessInput:
    ret

str2int PROC
    ; Convert ASCII string to integer
    xor ax, ax                   ; Clear AX
    xor cx, cx                   ; Clear CX
nextDigit:
    lodsb                        ; Load character into AL, increment SI
    cmp al, 0                    ; Check for end of string
    je done                      ; If end of string, done
    sub al, '0'                  ; Convert ASCII character to number
    mov bx, 10                   ; Multiply AX by 10
    mul bx                       ; AX = AX * 10
    add ax, cx                   ; Add CX to AX
    mov cx, ax                   ; Store AX in CX
    jmp nextDigit                ; Process next character
done:
    mov ax, cx                   ; Move result to AX
    ret
str2int ENDP

processKeyValuePair:
    ; Process the key-value pair
    lea si, keyArray             ; SI points to keyArray
    mov cx, counter              ; Load counter into CX

searchLoop:
    mov di, si                   ; Save current address of keyArray in DI
    lodsw                        ; Load key length into AX and value into BX
    cmp ax, keyLength            ; Compare key length with current key's length
    jne notFound                 ; If lengths don't match, move to next key
    mov dx, si                   ; Save current address of keyArray in DX
    add si, ax                   ; Move SI to the value of the current key
    add si, 2                    ; Move SI to the next entry in keyArray
    cmp byte ptr [si], 0         ; Check if the next key is null
    je foundKey                  ; If next key is null, current key is unique
    mov si, dx                   ; Restore SI to current key's address
    add si, ax                   ; Move SI to the next entry in keyArray
    add si, 2                    ; Move SI to the next entry in keyArray
    loop searchLoop              ; Repeat search loop until all keys are checked

notFound:
    ; If key is not found, add it to keyArray
    stosw                        ; Store key length in keyArray
    mov ax, value                ; Store value in AX
    stosw                        ; Store value in averageArray
    inc counter                  ; Increment counter for unique keys
    ret

foundKey:
    ; If key is found, update average value
    mov ax, [si+2]               ; Load previous sum from averageArray to AX
    add ax, value                ; Add new value to sum
    mov [si+2], ax               ; Store updated sum in averageArray
    inc word ptr [si+4]          ; Increment count of values for this key
    ret

groupAndSort PROC
    ; Group and calculate averages
    lea si, averageArray
    mov cx, counter

groupAndSortLoop:
    mov ax, [si]
    test ax, ax
    jz nextGroupAndSortLoop

    mov bx, [si+2]               ; Count of values for this key
    mov dx, ax
    cwd
    idiv bx                      ; Calculate average
    mov [si], ax

nextGroupAndSortLoop:
    add si, 4                    ; Move to next entry in averageArray
    loop groupAndSortLoop

    ; Bubble sort
    mov si, averageArray
    mov cx, counter
    dec cx                        ; Counter-based loop needs one decrement

outerLoop:
    mov di, si
    mov si, averageArray

innerLoop:
    mov ax, [si]
    cmp ax, [si+4]
    jge noSwap
    xchg ax, [si+4]
    mov [si], ax

noSwap:
    add si, 4
    loop innerLoop

    add si, di                     ; Reset SI to the beginning of the array
    loop outerLoop

    ret
groupAndSort ENDP

printString PROC
    mov ah, 02h     ; Функція 02h DOS - виведення символа
    mov si, dx      ; Завантаження адреси рядка в SI
    printLoop:
        lodsb        ; Завантаження символу у AL та інкрементування SI
        test al, al  ; Перевірка, чи досягли кінця рядка (але не нуль-термінатор)
        jz endPrint  ; Якщо символ дорівнює нулю, завершити друк
        int 21h      ; Виведення символа, що зберігається в AL
        jmp printLoop ; Повторити для наступного символу
    endPrint:
    ret
printString ENDP

END main
