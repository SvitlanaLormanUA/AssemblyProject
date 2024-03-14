.model small
.stack 100h

.data
    keyArray db 16000 dup(?)  ; 2 * 8000
    averageArray dw 16000 dup(?) ; 2 * 8000
    counter dw ?
    totalValues dd ?
    sum dw ?
    keyLength dw ?
    value dw ?
    key db 16 dup(?)
    CR db 13, 10, '$'
    fileName db "test.in", 0  ; Ім'я файлу
    successMessage db "Reading file completed successfully.", 0Dh, 0Ah, '$'

.code
main PROC
    mov ax, @data
    mov ds, ax

    call readInputFromFile
    call groupAndSort
    call printOutput

    mov ax, 4C00h
    int 21h
main ENDP

readInputFromFile PROC
    mov ah, 3Dh         ; відкриважм файл
    lea dx, fileName    ; Завантажити ім'я файлу
    int 21h
   jnc noReadError  ; Перевірити, чи не сталася помилка читання, якщо було безпечне читання
   jmp readError    ; Перейти до обробки помилки, якщо сталася помилка читання

    mov bx, ax          ; Зберегти дескриптор файлу

    mov cx, 10000       ; Максимальна кількість рядків для читання
    mov counter, 0
noReadError:

    ; Відобразити повідомлення про успішне завершення читання
    mov ah, 09h          ; Функція виведення рядка
    lea dx, successMessage  ; Завантаження адреси рядка successMessage
    int 21h              ; Виклик переривання DOS для виведення рядка


    ; Продовжити виконання програми
    ret

readLoop:
    mov ah, 3Fh         ; Читати з файлу
    mov bx, ax          ; Дескриптор файлу
    mov cx, 1           ; Читати один байт
    lea dx, key
    int 21h
    jc readError

    cmp al, 13          ; Перевірка на CR
    je processLine
    cmp al, 10          ; Перевірка на LF
    je processLine
    cmp al, ' '         ; Перевірка на пробіл
    je processLine

    ; Читати значення
    mov ah, 3Fh         ; Читати з файлу
    mov bx, ax          ; Дескриптор файлу
    mov cx, 1           ; Читати один байт
    lea dx, value
    int 21h
    jc readError

    sub al, '0'
    mov value, ax

    jmp readLoop

processLine:
    ; Розбір рядка, що складається з ключа та значення
    lea si, keyArray       ; Завантаження адреси масиву keyArray в SI
    mov cx, counter        ; Завантаження лічильника в CX
searchLoop:
    mov di, si             ; Зберігання поточної адреси keyArray в DI
    lodsw                  ; Завантаження ключової довжини в AX та значення у BX
    cmp ax, keyLength      ; Порівняння ключової довжини з поточною довжиною ключа
    jne notFound           ; Якщо довжини не співпадають, перейти до notFound
    mov dx, si             ; Зберегти поточну адресу в DX
    add si, ax             ; Перейти до значення в keyArray
    add si, 2              ; Перейти до наступного запису в keyArray
   cmp byte ptr [si], 0   ; Перевірка, чи наступний ключ є нульовим (закінченням масиву)
    je foundKey           ; Якщо наступний ключ є нульовим, значить поточний ключ є унікальним
    mov si, dx            ; Відновлення поточної адреси ключа у випадку ненадачі
    add si, ax            ; Перейти до наступного запису в keyArray
    add si, 2             ; Перейти до наступного запису в keyArray
    loop searchLoop       ; Продовжити пошук

notFound:
    ; Додавання нового ключа та його значення в масиви keyArray та averageArray
    stosw                  ; Зберегти довжину ключа в keyArray
    mov ax, value          ; Зберегти значення в AX
    stosw                  ; Зберегти значення в averageArray
    inc counter            ; Збільшити лічильник унікальних ключів
    jmp readLoop           ; Перейти до наступного рядка з файлу

foundKey:
    ; Обчислення середнього значення для поточного ключа
    mov ax, [si+2]         ; Завантажити попередню суму з averageArray в AX
    add ax, value          ; Додати нове значення до суми
    mov [si+2], ax         ; Зберегти нову суму в averageArray
    inc word ptr [si+4]   ; Збільшити лічильник значень для поточного ключа
    jmp readLoop           ; Перейти до наступного рядка з файлу


closeFile:
    mov ah, 3Eh         ; Закрити файл
    mov bx, ax          ; Дескриптор файлу
    int 21h
    ret

readError:
    ; Обробка помилки читання файлу
    mov ah, 09h           ; Вивід повідомлення
    lea dx, errorMessage  ; Адреса рядка errorMessage
    int 21h               ; Виклик переривання DOS для виводу рядка
    ret                   ; Повернення до головної програми

errorMessage db "Error reading file.", 0Dh, 0Ah, '$'

readInputFromFile ENDP

groupAndSort PROC
    lea si, averageArray
    mov cx, counter
groupAndSortLoop:
    mov ax, [si]
    test ax, ax
    jz nextGroupAndSortLoop

    mov bx, [si+2]  ; Кількість значень для цього ключа
    mov dx, ax
    cwd
    idiv bx  ; Розрахувати середнє
    mov [si], ax

nextGroupAndSortLoop:
    add si, 4  ; Розмір елемента averageArray
    loop groupAndSortLoop

    ; Сортування бульбашкою
    mov si, averageArray
    mov cx, counter
    dec cx
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
    add si, di  ; Скинути si на початок масиву
    loop outerLoop

    ret
groupAndSort ENDP

printOutput PROC
    mov si, averageArray
    mov cx, counter
printLoop:
    mov ax, [si]
    test ax, ax
    jz nextPrintLoop
    ; Перетворити середнє у рядок
    mov bx, 10
    xor dx, dx
    div bx
    add dl, '0'
    mov [key], dl
    mov dx, ax
    add dl, '0'
    mov [key+1], dl
    mov dx, offset key
    call printString
    mov dx, offset CR
    call printString

nextPrintLoop:
    add si, 4
    loop printLoop

    ret
printOutput ENDP

printString PROC
    mov ah, 09h   ; Функція виведення рядка
    int 21h       ; DOS переривання
    ret
printString ENDP

END main
