start:

    li x3, 202222222
    la x4, return
    call test_loop

test_loop:
    li x10, 123
    jalr x1, x4, 0

return:
    j return
