test1_immediates:
    addi x1, x0, 2
    xori x2, x1, 3
    ori x3, x2, 1
    andi x4, x3, 3
    slli x5, x4, 2
    srli x6, x5, 2
    addi x6, x0, -5
    srai x7, x6, 2
    slti x8, x7, -3
    sltiu x9, x8, 5
test2_base:
    add x10, x9, x8
    sub x11, x10, x9
    xor x12, x11, 10
    or x13, x12, x11
    and x14, x13, x12
    sll x15, x14, x13
    srl x16, x15, x14
    addi x16, x0, -5
    sra x17, x16, x15
    slt x18, x17, x16
    sltu x19, x18, x17
test3_load_store:
    sb x1, 0(x0)
    sh x5, 4(x0)
    sw x9, 8(x0)
    lb x20, 0(x0)
    lh x21, 4(x0)
    lw x22, 8(x0)
test4_branching:
    beq x0, x0, 8   
    jal x1, end_trap
    addi x2, x0, 50

    bne x0, x2, 8
    jal x1, end_trap
    addi x3, x0, 40

    blt x3, x2, 8
    jal x1, end_trap
    addi x4, x0, 30
    
    bge x2, x3, 8
    jal x1, end_trap
    addi x5, x0, 20
    
    bltu x3, x2, 8
    jal x1, end_trap
    addi x6, x0, 10
    
    bgeu x2, x3, 8
    jal x1, end_trap
    addi x7, x0, 5

    bne x0, x0, 12
    addi x8, x0, 60
    jal x1, test5_various
    jal x1, end_trap


test5_various:
    lw x5, 0(x0)
    add x6, x5, x5
    addi x0, x0, 5
    jal x1, test6
test6:
    lui x15, 200

end_trap:
    jal x1, end_trap


