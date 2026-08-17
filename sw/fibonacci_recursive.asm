main:
    li x10, 25 # n
    li x2,  1020 #sp
    call fib

halt:
    j halt

fib:
    beqz x10, base_case

    li x15, 1
    beq x10, x15, base_case


    addi x2, x2, -16

    sw x10, 4(x2) # save n
    sw x1, 0(x2) # save sp

    addi x10, x10, -1

    call fib
    sw x4, 8(x2) # f(n-1)

    lw x10, 4(x2)
    addi x10, x10, -2

    call fib
    sw x4, 12(x2)

    lw x11, 8(x2) #load f(n-1)
    lw x12, 12(x2) #load f(n-2)
    
    add x4, x11, x12
        
        
    lw x1, 0(x2)

    addi x2, x2, 16
    ret

base_case:
    mv x4, x10
    ret