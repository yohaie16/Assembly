.data
array1: .word 0:9
array:  .word  -14,89,-8,-10,-90,120,-1,-19,90,10 
title: .asciiz "The product of adjacent numbers in the array:\n"
output1: .asciiz "\nThe sum of all products is: "
output2: .asciiz "\nThe sum of the differences of products is: "
newline: .asciiz "\n" 
.text
.globl main
 main:
 	la $t0,array
 	la $t1, array+4
 	la $t2,array1
 	la $t3, array+40
 	add $t5,$zero,$zero
 	add $t6,$zero,$zero
 loop:
 	beq $t1,$t3,end
 	lw $s0, 0($t0)
 	lw $s1, 0($t1) 
 	mult $s0, $s1
 	mflo $s2
 	sw  $s2,0($t2)
 	add $t5,$t5,$s2
 
 	addu $t9,$s1,$s2
 	addu $t7,$t7,$t9
 	addi $t0,$t0,4
 	addi $t1,$t1,4
 	addi $t2,$t2,4
 	j loop
 	  
 	
 end:
 	la $a0, title
	li $v0, 4
	syscall
	la $t0, array1
	li $t1, 9            
	li $t2, 0 

main2:
	la $t0,array1
	addi $t1, $t0, 4
	li $t7,0
	li $t6,0
	li $t8, 9
	
diffrencesloop:
	li $t9, 8 
	beq $t7,$t9,restore
	lw $s2,0($t0)
	lw $s3,0($t1)
	sub $t4, $s2, $s3
	add $t6, $t6, $t4
	addi $t0, $t0, 4
    	addi $t1, $t1, 4
    	addi $t7, $t7, 1
	j diffrencesloop
	
restore:
	la $t0, array1    
	li $t2, 0         
	li $t8, 9   
	
print_loop:
	beq $t2, $t8, print_sums

	lw $a0, 0($t0)
	li $v0, 1
	syscall

	la $a0, newline
	li $v0, 4
	syscall

	addi $t0, $t0, 4
	addi $t2, $t2, 1
	j print_loop
print_sums:
	
	la $a0, output1
	li $v0, 4
	syscall

	move $a0, $t5
	li $v0, 1
	syscall

	
	la $a0, output2
	li $v0, 4
	syscall

	move $a0, $t6
	li $v0, 1
	syscall

	
	li $v0, 10
	syscall