@       ARM Assembly Example
@       a function to find string length
@       Call it from main

        .text   @ instruction memory
        .global main
main:
        @ push (store) lr to the stack, allocate space for integer (scanf)

        sub     sp, sp, #4                      @ Stack to store the integer entered
        str     lr, [sp, #0]

        sub     sp, sp, #4                      @ A stack to store the integer entered

        @printf for int
        ldr     r0, =formati
        bl printf

        @scanf for int
        ldr     r0, = formatd
        mov     r1, sp
        bl      scanf

        @ Store the integer entered in r7
        ldr     r7, [sp, #0]
        mov     r6, #0                          @ r6 is used to count backwards the integer entered
        add     sp, sp, #4                      @ Release the stack created for the integer

        @ To check the scanf function's return value
        mov     r1, r0
        cmp     r1, #1
        bne     Exit                            @ If the return value is not 1, branch to Exit (For anything but an integer input)

        @ If the input is zero
        cmp     r7, #0
        beq     Exit

        @ output for negative inputs
        ldr     r0, =formate
        bllt    printf
        cmp     r7, #0
        blt     Exit

        @ Label call for iteration
        bl      next                            @ Rememeber this location's address to iterate the number of times entered by the user

        next:
                sub     sp, sp, #204                    @ Create space in the stack to store the string (200 characters max) entered
                str     lr, [sp, #200]                  @ Store the address of the branch next

                @printf for string
                ldr     r0, =formatr
                mov     r1, r6
                bl      printf

                @scanf for string
                ldr     r0, =formats
                mov     r1, sp
                bl      scanf                           @scanf("%*c%[^\n]",sp)

                @function call
                mov     r0, sp                          @ Store the base address of the string entered in r0
                sub     sp, sp, #200                    @ Create stack space to store the reverse of the word
                mov     r12, sp                         @ Store the base address of the new stack in r12
                mov     r5, r12                         @ Copy the base address into r5
                bl      stringLen                       @ Branch to stringlen to get the length of the string and return the reverse

                @print answer

                mov     r1, r6                          @ The value for %d in the output statement
                mov     r2, r5                          @ The base address holding the reverse string
                ldr     r0, =formatp
                bl      printf

                @ stack handling (pop lr from the stack) and return
                add     r6, r6, #1                      @ Increment r6. r6 will be in the output statements
                @mov    r0, #0                          @return 0
                add     sp, sp, #200                    @ Release the reverse string stack
                ldr     lr, [sp, #200]                  @ Load the link register of the address to brach "next"
                add     sp, sp, #204                    @ Release the stack storing the input string
                cmp     r6, r7                          @ Compare the output statement integer value and the user input integer
                beq     Exit                            @ If the two are equal, End the iteration
                mov     pc,lr                           @ Until r6 == r7, branch back to "next"
        Exit:
                ldr     lr, [sp, #0]                    @ Load the link register of the main
                add     sp, sp, #4                      @ Release the stack holding the main lr
                mov     pc, lr

        @******************************************************************END OF PROGRAM************************************************************************@

                @ string length function
        stringLen:
                sub     sp, sp, #4                      @ Create a stack to store the address of where the stringlength function was called
                str     lr, [sp, #0]
                mov     r1, #0                          @ length counter

        loop:
                ldrb    r2, [r0, #0]    @ Load each element from the string entered
                cmp     r2, #0          @ Compare the character with the terminating character to check for the end of the string
                subeq   r0, r0, #1      @ To calculate the address of the character before the terminating character
                moveq   r4, #0          @ To check the end of string copy
                beq     Reverse         @ After finding the length of the string, brach to reverse

                add     r1, r1, #1      @ count length
                add     r0, r0, #1      @ move to the next element in the char array
                b       loop

Reverse:
        ldrb    r2, [r0, #0]                    @ Load a character from the original string (In the reverse order)
        strb    r2, [r12, #0]                   @ Store the loaded character in the reverse string stack
        add     r4, r4, #1                      @ Increment r4.
        sub     r0, r0, #1
        add     r12, r12, #1
        cmp     r4, r1                          @ Compare r4 with r1 (string length)
        blt     Reverse

        mov     r2, #0                          @ Explicitly declare the null terminating character of the reverse string
        strb    r2, [r12, #0]

        @ Go back to where the stringlength function was called
        ldr     lr, [sp, #0]
        add     sp, sp, #4                      @ Release the stack that was holding the address of stringlen function call
        mov     pc, lr

        .data   @ data memory
formate: .asciz "Invalid Number\n"
formati: .asciz "Enter the number of strings : \n"
formatd: .asciz "%d"
formatr: .asciz "Enter the input string %d: \n"
formats: .asciz "%*c%[^\n]"
formatp: .asciz "Output string %d is : \n%s\n"
