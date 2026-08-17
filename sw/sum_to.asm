main:
    li x10, 98000 # n
    call sum_to

halt:
    j halt

sum_to:
    add x3, x10, x3
    addi x10, x10, -1
    bnez x10, sum_to
    ret

    
