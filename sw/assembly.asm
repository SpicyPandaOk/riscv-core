start:

    addi x1, x0, 10
    beq x0, x0, halt
    addi x1, x0, 20
    j start

halt:
    j halt