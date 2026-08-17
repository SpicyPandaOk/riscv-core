main:
    li x10, 30
    li x5, 0
    
    call fib

halt:
    j halt


fib:
    li x5, 0
    li x11, 0
    li x12, 1
    j fib_loop
    fib_label:
    ret


fib_loop:
    beqz x10, end


    beq x5, x10, end

    addi x5, x5, 1

    add x13, x11, x12
    mv x11, x12
    mv x12, x13

    j fib_loop

end:
    mv x3, x11
    j fib_label
