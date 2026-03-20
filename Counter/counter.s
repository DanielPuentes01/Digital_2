# a2 : Data_in
# a3 : Data
# t0 : aux
# t1: Counter
# s1: Result

main:           
    lw   a3,  0(a2)            
    addi t1, x0, 0  

loop:
    andi t0,  a3, 1             
    bne  t0,  x0, one          
    jal x0, shift                  

one:
    addi t1, t1, 1            

shift:
    srli a3,  a3, 1            
    bne  a3,  x0, loop         

done:
    andi s1, t1, 1            
    sw   s1, 0(a2)            

