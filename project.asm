.model small
.stack 100h

.data

file_error_message db "File error $"
file_handle dw 0
current_char db 0
current_index dw 0
new_key_index dw 0
key_array db 10000*16 dup(0)
temp_key_buffer db 16 dup(0)
temp_key_buffer_index dw 0
isWord db 1
value_array dw 10000 dup(0)
number_buffer db 16 dup(0)
number_buffer_index dw 0
quantity_array dw 3000 dup(0)

.code
main proc
    mov ax, @data
    mov ds, ax

    mov dx, offset input_filename
    mov ah, 03Dh
    mov al, 0
    int 21h

    jc error
        jmp cont
    error:
        mov ah, 09h
        mov dx, offset file_error_message
        int 21h
        jmp ending
    cont:
        mov [file_handle], ax

read_next:
    mov ah, 3Fh
    mov bx, [file_handle]
    mov cx, 1
    mov dx, offset current_char
    int 21h

    push ax
    push bx
    push cx
    push dx
    call procChar

;processing the characters
push dx
push cx
push bx
push ax
    or ax, ax
    jnz read_next

    mov si, offset number_buffer
    dec number_buffer_index
    add si, number_buffer_index
    mov [si], 0

    call trnInNum
    call calcAvr
    call sortArr
    call writeArrays

    mov ah, 09h
    mov dx, offset success_message
    int 21h

ending:
    main endp

procChar proc
    cmp current_char, 0Dh
    jnz notCR
    mov isWord, 1
    call trnInNum
    jmp endProc
notCR:
    cmp current_char, 0Ah
    jnz notLF
    mov isWord, 1
    jmp endProc
notLF:
    cmp current_char, 20h
    jnz notSpace
    mov isWord, 0
    call checkKey
    jmp endProc
notSpace:
    cmp isWord, 0
    jnz itsWord
    mov si, offset number_buffer
    mov bx, number_buffer_index
    add si, bx
    mov al, current_char
    mov [si], al
    inc number_buffer_index
    jmp endProc
itsWord:
    mov si, offset temp_key_buffer
    mov bx, temp_key_buffer_index
    add si, bx
    mov al, current_char
    mov [si], al
    inc temp_key_buffer_index
endProc:
    ret
procChar endp

trnInNum PROC
    xor bx, bx
    mov cx, 0

calcNum:
    mov si, offset number_buffer
    add si, number_buffer_index
    dec si
    sub si, cx
    xor ax, ax
    mov al, [si]

    cmp ax, 45
    jnz notMinus
    neg bx
    jmp afterCalc
notMinus:
    sub al, '0'

    push cx
    cmp cx, 0
    jnz notZer
    jmp endOFMul
notZer:
    mulByTen:
    mov dx, 10
    mul dx
    dec cx
    cmp cx, 0
    jnz mulByTen

endOFMul:
    pop cx
    add bx, ax

    inc cx
    cmp cx, number_buffer_index
    jnz calcNum

afterCalc:
    mov si, offset value_array
    mov ax, current_index
    shl ax, 1
    add si, ax
    add bx, [si]
    mov [si], bx
    mov number_buffer_index, 0
    mov cx, 0

    fillZeros:
        mov si, offset number_buffer
        add si, cx
        mov [si], 0
        inc cx
        cmp cx, 9
        jnz fillZeros

    ret
trnInNum endp

checkKey proc
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0

    cmp new_key_index, 0
    jnz findKey
    jmp addNewKey

findKey:
    mov dx, 0
; check for keys
    checkPresKey:
        mov si, offset key_array
        shl cx, 4
        add si, cx
        shr cx, 4
        add si, dx
        mov al, [si]
        mov di, offset temp_key_buffer
        add di, dx
        mov ah, [di]
        cmp al, ah
        jne notEqualChar
        mov bx, 1
        jmp contComp
    notEqualChar:
        mov bx, 0
        mov dx, 15
    contComp:
        inc dx
        cmp dx, 16
        jnz checkPresKey

    cmp bx, 0
    jnz keyPresent
    inc cx
    cmp cx, new_key_index
    jne findKey

    ;new key
    addNewKey:
        mov cx, 0

;adding key loop
        addNewKeyLoop:
            mov si, offset temp_key_buffer
            add si, cx
            mov di, offset key_array
            mov ax, new_key_index
            shl ax, 4
            add di, cx
            add di, ax
            mov al, [si]
            mov [di], al
            inc cx
            cmp cx, 16
            jnz addNewKeyLoop

        mov cx, new_key_index
        mov current_index, cx
        inc new_key_index

        mov si, offset quantity_array
        mov cx, current_index
        shl cx, 1
        add si, cx
        mov ax, 1
        mov [si], ax

        jmp endOfCheck

keyPresent:
;if key is in array
    mov current_index, cx

    mov si, offset quantity_array
    mov cx, current_index
    shl cx, 1
    add si, cx
    mov ax, [si]
    inc ax
    mov [si], ax

endOfCheck:
    mov temp_key_buffer_index, 0
    mov cx, 0

    fillZeroskey:
        mov si, offset temp_key_buffer
        add si, cx
        mov [si], 0
        inc cx
        cmp cx, 15
        jnz fillZeroskey

    ret
checkKey endp

calcAvr proc
    mov cx, 0

calcAv:
    mov si, offset value_array
    shl cx, 1
    add si, cx
    mov di, offset quantity_array
    add di, cx
    shr cx, 1
    mov ax, [si]
    mov bx, [di]
    mov dx, 0
    div bx
    mov [si], ax

    inc cx
    cmp cx, new_key_index
    jnz calcAv

    ret
calcAvr endp

writeArrays proc
    mov cx, 0

makeString:
    mov ax, 0
    mov current_index, ax
    mov dx, 0
    push cx

    mov di, offset quantity_array
    shl cx, 1
    add di, cx
    mov cx, [di]

writeKey:
    mov si, offset key_array
    mov ax, cx
    shl ax, 4
    add si, ax
    add si, current_index

    mov ah, 02h
    mov bx, dx
    mov dl, [si]
    cmp dl, 0
    jne notEndOfKey
    jmp gotoNumbPrint

notEndOfKey:
    int 21h
    mov dx, bx
    inc current_index
    inc dx
    cmp dx, 16
    jnz writeKey

gotoNumbPrint:
    mov ah, 02h
    mov dl, ' '
    int 21h

    push cx
    call turnInChar
    pop cx

    call addMinus
    mov dx, 0

writeNumb:
    mov si, offset number_buffer
    add si, dx
    mov bl, [si]

    mov ah, 02h
    push dx
    mov dl, bl
    int 21h
    pop dx

    inc dx
    cmp dx, number_buffer_index
    jnz writeNumb

    mov ah, 02h
    mov dl, 0dh
    int 21h

    mov ah, 02h
    mov dl, 0ah
    int 21h

    pop cx
    inc cx
    cmp cx, new_key_index
    jnz makeString

    ret
writeArrays endp

turnInChar proc
    pop dx
    pop bx
    shl bx, 1
    mov ax, [value_array + bx]
    cmp ax, 10000
    jc positiveVal
    neg ax

positiveVal:
    shr bx, 1
    push bx
    push dx

    mov cx, 15

makeChar:
    mov dx, 0
    mov bx, 10
    div bx
    mov si, offset temp_key_buffer
    add si, cx
    add dx, '0'
    mov [si], dl
    cmp ax, 0
    jnz contSetNumb
    mov bx, 16
    mov number_buffer_index, bx
    sub number_buffer_index, cx
    jmp reverse_number

contSetNumb:
    dec cx
    cmp cx, -1
    jne makeChar

reverse_number:
    mov cx, 16
    sub cx, number_buffer_index
    mov dx, 0

reverse:
    mov si, offset temp_key_buffer
    add si, cx
    mov di, offset number_buffer
    add di, dx
    mov al, [si]
    mov [di], al
    inc dx
    inc cx
    cmp cx, 16
    jnz reverse

    ret
turnInChar endp

addMinus proc
    mov bx, cx
    shl bx, 1
    mov ax, [value_array + bx]
    cmp ax, 10000
    jc positiveVal
    mov ah, 02h
    mov dl, '-'
    int 21h


addMinus endp

sortArr proc
    pop dx

    mov cx, 0

fillArrayOfPoint:
    mov di, offset quantity_array
    shl cx, 1
    add di, cx
    shr cx, 1
    mov [di], cx
    inc cx
    cmp cx, new_key_index
    jnz fillArrayOfPoint

    mov cx, word ptr new_key_index
    dec cx

outerLoop:
    push cx
    lea si, quantity_array

innerLoop:
    mov ax, [si]
    push ax
    shl ax, 1
    add ax, offset value_array
    mov di, ax
    mov ax, [di]
    mov bx, [si + 2]
    push bx
    shl bx, 1
    add bx, offset value_array
    mov di, bx
    mov bx, [di]
    cmp ax, bx
    pop bx
    pop ax
    jl nextStep
    xchg bx, ax
    mov [si], ax
    mov [si + 2], bx

nextStep:
    add si, 2
    loop innerLoop
    pop cx
    loop outerLoop

    push dx
    ret
sortArr endp
end main
