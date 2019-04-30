.data
	infix: .space 2048
	reverseInfix: .space 2048
	postfix: .space 2048
	reversePostfix: .space 2048
	prefix: .space 2048
	stack: .space 2048
	result: .space 2048
	tmp: .space 100
	newLine: .asciiz "\r\n"
	inputFile: .asciiz "D:/Assembly/input.txt"
	postfixFile: .asciiz "D:/Assembly/postfix.txt"
	prefixFile: .asciiz "D:/Assembly/prefix.txt"
	resultFile: .asciiz "D:/Assembly/result.txt"

.text
	
main:
	Step_1: # load data from input file 
		li $a3, -1 # index counter in infix - global variable
		li $t7, -1 # counter of postfix - global variable
		li $k0, -1  # counter of result for calculation - global variable
		li $k1, 0 # counter of result for output - global variable
		li $v1, 0 # if ($v1 == 0) convert from infix to postfix;  else convert from Infix to prefix 	
		j Get_data_from_input_file
		
	Step_2: # convert data from infix to postfix
		beq $a3, -1, convert_to_postfix
		
		lb $t9, infix($a3)  
		beq $t9, '\0', Step_3
		
		j convert_to_postfix
			
	Step_3: # print postfix and result
		jal print_postfix
		j print_result
	
	Step_4: # convert data from infix to prefix
		li $v1, 1
		j reverse_infix
		
		init_before_convert_to_prefix:
			li $a3, -1 # index counter in infix - global variable
			li $t7, -1 # counter of postfix - global variable
		
		convert_to_prefix:
			beq $a3, -1, convert_to_postfix
		
			lb $t9, infix($a3)  
			beq $t9, '\0', Step_5
		
			j convert_to_postfix
	
	Step_5: # print prefix
		j print_prefix
		
	End_Program:			
		li $v0, 10
		syscall

############################################################	
Get_data_from_input_file:
	# Open file in reading mode
	li $v0, 13
	la $a0, inputFile
	li $a1, 0
	syscall
	move $s0, $v0
		
	# Read file
	li $v0, 14
	move $a0, $s0
	la $a1, infix
	la $a2, 2048
	syscall
	
	# print to test
	li $v0, 4
	la $a0, infix
	syscall
		
	# Close file
	li $v0, 16
	move $a0, $s0
	syscall
		
	j Step_2
	

###############################################
convert_to_postfix:
	li $s7, -1 # Scounter


while:
        la $s1, infix  #buffer = $s1
        la $t5, postfix #postfix = $t5
        la $t6, stack #stack = $t6
        li $s2, '+'
        li $s3, '-'
        li $s4, '*'
        li $s5, '/'
	addi $a3, $a3, 1  # index ++
	
	# get buffer[counter]
	add $s1, $s1, $a3
	lb $t1, 0($s1)	# t1 = value of buffer[counter]
	
							
	beq $t1, $s2, isOperator # '+'
	nop
	beq $t1, $s3, isOperator # '-'
	nop
	beq $t1, $s4, isOperator # '*'
	nop
	beq $t1, $s5, isOperator # '/'
	nop
	beq $t1, 40, pushToStack # '('
	nop
	beq $t1, 41, isOperator # ')'
	nop
	beq $t1, 32, n_operator # ' '
	nop
	#beq $t1, 13, n_operator # '\r'
	#nop
	beq $t1, 10, endWhile  # '\n'
	nop
	beq $t1, $zero, endWhile
	nop
	
	# push number to postfix
	addi $t7, $t7, 1
	add $t5, $t5, $t7	
	sb $t1, 0($t5)
				
	lb $a0, 1($s1)	 # character to check
	jal check_number # ìf(0 <= $a0 && $ $a0 <= 9) $v0 = 1; else $v0 = 0
	beq $v0, 1, n_operator
	nop
##############################################	
add_space:
	add $t1, $zero, 32
	sb $t1, 1($t5)
	addi $t7, $t7, 1	
	j n_operator
	nop

##############################################
isOperator:
	# add to stack ...
				
	# if (S_Stack.isEmpTy()) pushToSack();		
	beq $s7, -1, pushToStack 
	nop
			
	la $t6, stack
	add $t6, $t6, $s7
	lb $t2, 0($t6) # t2 = value of S_Stack[scounter]
	
	beq $t1, 41, isCloseBracket 
	
	# check t1 precedence
	beq $t1, $s2, Set_1_for_$t3
	nop
	beq $t1, $s3, Set_1_for_$t3
	nop
	
	li $t3, 2
	
	j check_t2
	nop

##############################################
isCloseBracket:
	# pop $t2 from top of $t6(S_Stack)
	sb $zero, 0($t6)
	addi $s7, $s7, -1  # scounter --
	addi $t6, $t6, -1
	
	beq $t2, 40, n_operator
	nop
	
	# push $t2 to postfix(P_Stack) 
	la $t5, postfix  
	addi $t7, $t7, 1 # pcounter ++
	add $t5, $t5, $t7	
	sb $t2, 0($t5)
				
	# add space
	addi $t7, $t7, 1
	add $t5, $t5, 1
	li $t8, 32
	sb $t8, 0($t5)
		
	lb $t2, 0($t6) # t2 = value of S_Stack[scounter]
	
	j isCloseBracket
	
##############################################	
Set_1_for_$t3:
	li $t3, 1

##############################################		
# check t2 precedence
check_t2:
	
	beq $t2, $s2, Set_1_for_$t4
	nop
	beq $t2, $s3, Set_1_for_$t4
	nop
	beq $t2, 40, Set_0_for_$t4
	nop
	
	li $t4, 2	
	
	j compare_precedence
	nop
	
##############################################	
Set_1_for_$t4:
	li $t4, 1	
	j compare_precedence
	
##############################################	
Set_0_for_$t4:
	li $t4, -1	
	
##############################################
compare_precedence:	
	beq $t3, $t4, equal_precedence
	nop
	slt $s1, $t3, $t4
	beqz $s1, t3_greater_t4
	nop

	jal t3_lesser_t4
	
	# Repeat until t3 > t4
	j isOperator
	nop
	
##############################################
t3_greater_t4:
	# push t1 to stack
	j pushToStack
	nop

##############################################
t3_lesser_t4:
    # pop $t2 from top of $t6(S_Stack)
	sb $zero, 0($t6)
	addi $s7, $s7, -1  # scounter --
	addi $t6, $t6, -1
	
    # push $t2 to postfix(P_Stack) 
	la $t5, postfix  
	
	# push $t2
	addi $t7, $t7, 1 # pcounter ++
	add $t5, $t5, $t7	
	sb $t2, 0($t5)
			
	# add space
	addi $t7, $t7, 1
	add $t5, $t5, 1
	li $t8, 32
	sb $t8, 0($t5)
	
	jr $ra
	
##############################################
equal_precedence:
	beq $v1, 1, S # infix to prefix: push $t1 into stack even if $t1 and $t2 have equal precedence

	# pop $t2 from top of $t6(S_Stack)
	sb $zero, 0($t6)
	addi $s7, $s7, -1  # scounter --
	addi $t6, $t6, -1
	
	# push $t2 to postfix(P_Stack) 
	la $t5, postfix  

	addi $t7, $t7, 1 # pcounter ++
	add $t5, $t5, $t7	
	sb $t2, 0($t5)
	
	addi $t7, $t7, 1
	add $t5, $t5, 1
	li $t8, 32
	sb $t8, 0($t5)
	
	
	S:
		j pushToStack  # push $t1 to $t6(stack)
		nop
	
##############################################
pushToStack:
	la $t6, stack # S_stack = $t6
	addi $s7, $s7, 1  # scounter ++
	add $t6, $t6, $s7
	sb $t1, 0($t6)	
	
##############################################
n_operator:	
	j while	
	nop
	
##############################################
endWhile:	
	la $t6, stack
	add $t6, $t6, $s7

##############################################	
popAllStack:
	lb $t2, 0($t6) # t2 = value of stack[counter]
	addi $s7, $s7, -1
	
	beq $t2, '\0', add_endline
		
	sb $zero, 0($t6)
	add $t6, $t6, -1
	
	la $t5, postfix
	add $t5, $t5, $t7
	lb $a0, 0($t5)
	jal Check_blank
	beqz $v0, addSpace_1
	
	insert_into_postfix:
		add $t7, $t7, 1
		sb $t2, 1($t5)
		
	j popAllStack
	nop
	
	add_endline:
		la $t5, postfix
		add $t7, $t7, 1
		add $t5, $t5, $t7
		li $t9, '\n'
		sb $t9, 0($t5)
		
		beqz $v1, Calculate_Postfix
		j convert_to_prefix

##########################################################################
Check_blank:
	beq $a0, 32, Set_1_for_$v0
	
	li $v0, 0
	jr $ra

##########################################################################
Set_1_for_$v0:
	li $v0, 1
	jr $ra

###########################################################################
addSpace_1:
	addi $s1, $zero, 32
	la $t5, postfix
	add $t7, $t7, 1
	add $t5, $t5, $t7 	
	sb $s1, 0($t5) # $s1 == ' '	
	j insert_into_postfix

###############################################################################
print_postfix:
	# Open file in writting mode
	li $v0, 13
	la $a0, postfixFile
	li $a1, 1
	syscall
	move $s0, $v0
		
	# Write file
	li $v0, 15
	move $a0, $s0
	la $a1, postfix
	la $a2, 2048
	syscall
		
	# Close file
	li $v0, 16
	move $a0, $s0
	syscall
	
	jr $ra
		
##########################################################

#-----------------------------------------# 
#					  #	
#	    Calculate Postfix 		  #
#					  #	
#-----------------------------------------#

Calculate_Postfix:
	add $k0, $k0, 1 # counter
	la $s2, stack #stack = $s2


# postfix to stack
while_p_s:
	lb $t1, postfix($k0)	
	
	# if null
	beqz $t1 end_while_p_s
	nop
	
	beq $t1, 10, end_while_p_s
	nop
	
	
	# if (&t1 == ' ')
	beq $t1, 32, continue
	
	add $a0, $zero, $t1
	jal check_number
	nop
	
	beqz $v0, is_operator
	nop
	
	jal add_number_to_stack
	nop
	
	j continue
	nop
	
##########################################################################	
is_operator:
	
	jal pop
	nop	
	
	add $a1, $zero, $v0 # b
	
	jal pop
	nop	
	
	add $a0, $zero, $v0 # a
		
	add $a2, $zero, $t1 # op
	
	jal caculate
	
###################################################################	
continue:
	add $k0, $k0, 1 # counter++	
	j while_p_s
	nop

#-----------------------------------------------------------------
#Procedure caculate
# @brief caculate the number ("a op b")
# @param[int] a0 : (int) a
# @param[int] a1 : (int) b
# @param[int] a2 : operator(op) as character
#-----------------------------------------------------------------
caculate:
	sw $ra, 0($sp)
	li $v0, 0
		
	#add $a0, $a0, -48
	#add $a1, $a1, -48
	
	beq $t1, '*', cal_case_mul
	nop
	beq $t1, '/', cal_case_div
	nop
	beq $t1, '+', cal_case_plus
	nop
	beq $t1, '-', cal_case_sub
	
	cal_case_mul:
		mul $v0, $a0, $a1
		j cal_push
	cal_case_div:
		div $a0, $a1
		mflo $v0
		j cal_push
	cal_case_plus:
		add $v0, $a0, $a1
		j cal_push
	cal_case_sub:
		sub $v0, $a0, $a1
		j cal_push
		
	cal_push:
		add $a0, $v0, $zero
		jal push
		nop
		lw $ra, 0($sp) 
		jr $ra
		nop
	


#-----------------------------------------------------------------
#Procedure add_number_to_stack
# @brief get the number and add number to stack at $s2
# @param[in] s3 : counter for postfix string
# @param[in] s1 : postfix string
# @param[in] t1 : current value
#-----------------------------------------------------------------
add_number_to_stack:
	# save $ra
	sw $ra, 0($sp)
	li $v0, 0
	
	while_ants:
		beq $t1, '0', ants_case_0
		nop
		beq $t1, '1', ants_case_1
		nop
		beq $t1, '2', ants_case_2
		nop
		beq $t1, '3', ants_case_3
		nop
		beq $t1, '4', ants_case_4
		nop
		beq $t1, '5', ants_case_5
		nop
		beq $t1, '6', ants_case_6
		nop
		beq $t1, '7', ants_case_7
		nop
		beq $t1, '8', ants_case_8
		nop
		beq $t1, '9', ants_case_9
		nop
		
		ants_case_0:
			j ants_end_sw_c
		ants_case_1:
			addi $v0, $v0, 1	
			j ants_end_sw_c
			nop
		ants_case_2:
			addi $v0, $v0, 2
			j ants_end_sw_c
			nop
		ants_case_3:
			addi $v0, $v0, 3
			j ants_end_sw_c
			nop
		ants_case_4:
			addi $v0, $v0, 4
			j ants_end_sw_c
			nop
		ants_case_5:
			addi $v0, $v0, 5
			j ants_end_sw_c
			nop
		ants_case_6:
			addi $v0, $v0, 6
			j ants_end_sw_c
			nop
		ants_case_7:
			addi $v0, $v0, 7
			j ants_end_sw_c
			nop
		ants_case_8:
			addi $v0, $v0, 8
			j ants_end_sw_c
			nop
		ants_case_9:
			addi $v0, $v0, 9
			j ants_end_sw_c
			nop
		ants_end_sw_c:	
			add $k0, $k0, 1		
			lb $t1, postfix($k0)
		
			beq $t1, $zero, end_while_ants
			beq $t1, ' ', end_while_ants
			
			mul $v0, $v0, 10
			
			j while_ants
			
###################################################################			
end_while_ants:
	add $a0, $zero, $v0
	jal push
	# get $ra
	lw $ra, 0($sp) 
	jr $ra
	nop
		
		
#-----------------------------------------------------------------
#Procedure check_number
# @brief check character is number or not 
# @param[int] a0 : character to check
# @param[out] v0 : 1 = true; 0 = false
#-----------------------------------------------------------------
check_number:      
	li $t8, '0'
	li $t9, '9'
	
	beq $t8, $a0, check_number_true
	beq $t9, $a0, check_number_true
	
	slt $v0, $t8, $a0
	beqz $v0, check_number_false
	
	slt $v0, $a0, $t9
	beqz $v0, check_number_false
	
	
	check_number_true:	
	li $v0, 1
	jr $ra
	nop
	
	check_number_false:	
	li $v0, 0	
	jr $ra
	nop


#-----------------------------------------------------------------
#Procedure pop
# @brief pop from stack at $s2
# @param[out] v0 : value to popped
#-----------------------------------------------------------------
pop:
	lw $v0, -4($s2)
	sw $zero, -4($s2)
	add $s2, $s2, -4
	jr $ra
	nop

#-----------------------------------------------------------------
#Procedure push
# @brief push to stack at $s2
# @param[in] a0 : value to push
#-----------------------------------------------------------------
push:
	#add $a0, $a0, 48
	sw $a0, 0($s2)
	add $s2, $s2, 4
	jr $ra
	nop
	
###################################################################
Convert_num_to_tmpString:	
	# get the last digit of $t8
	li $s6, -1 # counter of tmp
	li $s7, 10
	
	li $t9, 0
	slt $v0, $t8, $t9
	
	beq $v0, 1, convert_for_negative_number
	
	#li $v1, 0 # assigns that $t8 is a positive number
	
	convert_for_positive_number:
		div $t8, $s7
		mfhi $t9
		
		# store last digit($t9) in string tmp
		add $s6, $s6, 1
		add $t9, $t9, 48
		sb $t9, tmp($s6) 
	
		# reduce $t8
		sub $t9, $t9, 48
		sub $t8, $t8, $t9
		div $t8, $s7
		mflo $t8
	
		beqz $t8, Convert_num_to_resultString
	
		j convert_for_positive_number
		
		
	convert_for_negative_number:
		mul $t8, $t8, -1
		#li $v1, 1 # assigns that $t8 is a negative number
		
		j convert_for_positive_number
	
###################################################################
Convert_num_to_resultString:	
	beq $v0, 0, loop
	
	add $s6, $s6, 1
	li $t9, '-'
	sb $t9, tmp($s6)
	
	loop:
		beq $s6, -1, add_endline_to_result
			
		lb $t9, tmp($s6)
		li $t8, '\0'
		sb $t8, tmp($s6)
		add $s6, $s6, -1
				
		sb $t9, result($k1)	
		add $k1, $k1, 1
		
		j loop
		
		add_endline_to_result:
			li $t9, '\n'
			sb $t9, result($k1)
			add $k1, $k1, 1
			j Step_2
	
	
###################################################################
end_while_p_s:	
	# Store result from number type to string type to print into file
	jal pop
	add $t8, $zero, $v0 
	#sw $t8, result
	j Convert_num_to_tmpString

		
print_result: # print postfix to file
	#add $t8, $t8, 1
	#li $t9, '\r'
	#sb $t9, result($t8)
	
	#add $t8, $t8, 1
	#li $t9, '\n'
	#sb $t9, result($t8)
	
	# Open file in writting mode
	li $v0, 13
	la $a0, resultFile
	li $a1, 1
	syscall
	move $s0, $v0
	
	li $v0, 15
	move $a0, $s0
	la $a1, result
	la $a2, 2048
	syscall

	#li $v0, 15
	#move $a0, $s0
	#la $a1, newLine
	#la $a2, 2
	#syscall
		
	# Close file
	li $v0, 16
	move $a0, $s0
	syscall
		
	j Step_4

		
################################################################

#-----------------------------------------# 
#					  #	
#	  Convert to prefix		  #
#					  #	
#-----------------------------------------#

reverse_infix:
	add $a3, $a3, -1  # index counter in infix - global variable
	li $k0, -1 # index counter in reverseInfix
	li $k1, -1 # index counter of tmp
	li $t7, -1 # counter of prefix - global variable

	reverse_loop:								
		lb $s1, infix($a3)  
		beq $s1, '\0', push_reverseInfix
							
		add $a0, $zero, $s1 # character to check
		jal check_number # ìf(0 <= $a0 && $ $a0 <= 9) $v0 = 1; else $v0 = 0
		
		beqz $v0, push_reverseInfix
		
		push_tmp:
			add $k1, $k1, 1
			sb $s1, tmp($k1)
			
			add $a3, $a3, -1
			j reverse_loop
								
		push_reverseInfix:
			beq $s1, '(', set_closeBracket
			beq $s1, ')', set_openBracket
			
			check:
				li $t8, -1
				slt $v0, $t8, $k1
				beq $v0, 1, push_reverseInfix_from_tmp 
			
			continue_reverse:
				add $k0, $k0, 1
				sb $s1, reverseInfix($k0)
				
				# if ($s1 == '\0'), we push it to reverseInfix but not using it. So, we need to decrease$ $k0 again.
				beq $s1, '\0', decrease_k1 
				
				L:
					add $a3, $a3, -1
				
					li $t8, -1
					slt $v0, $t8, $a3
					beqz $v0, move_reverseInfix_backto_Infix
				
					j reverse_loop	
		
		push_reverseInfix_from_tmp:
				beq $k1, -1, continue_reverse
				
				lb $t8, tmp($k1)
				li $v0, '\0'
				sb $v0, tmp($k1)
				add $k1, $k1, -1
				
				add $k0, $k0, 1
				sb $t8, reverseInfix($k0)
				
				j push_reverseInfix_from_tmp
				
			
		set_openBracket:
			li $s1, '('
			j check
		
		set_closeBracket:
			li $s1, ')'
			j check
		
		decrease_k1: 
			add $k0, $k0, -1
			j L


####################################################

# Now, we can get prefix by converting reverseInfix to postfix and then reversing that postfix again. However, we wanna reuse 
# code of converting postfix part and that part requires infix to convert. So, the only way is moving reverseInfix to Infix again.

move_reverseInfix_backto_Infix:	
	li $k1, -1 # index counter of tmp
	li $a3, -1
	li $v0, 0 # reverseInfix is not empty
	
	push_into_tmp:
		beq $k0, -1, reverseInfix_is_empty
		
		lb $t9, reverseInfix($k0)
		li $t8, '\0'
		sb $t8, reverseInfix($k0)
		add $k0, $k0, -1
		
		beq $t9, '\n', push_infix
	
		add $k1, $k1, 1
		sb $t9, tmp($k1)
		
		j push_into_tmp
		
	reverseInfix_is_empty:
		li $v0, 1
		li $t9, '\0'
		
	push_infix:		
		add $t0, $a3, $k1
		add $t0 $t0, 2
		sb $t9, infix($t0)
				
		push_infix_loop:
			jal check_condition_stop_k1				
			
			lb $t9, tmp($k1)
			li $t8, '\0'
			sb $t8, tmp($k1)
			add $k1, $k1, -1
		
			add $a3, $a3, 1
			sb $t9, infix($a3)
		
			j push_infix_loop
		
	check_condition_stop_k1:
		beq $k1, -1, check_condition_stop_v0
		jr $ra
	
	check_condition_stop_v0:
		beq $v0, 1, init_before_convert_to_prefix
		add $a3, $a3, 1
		j push_into_tmp

########################################################
print_prefix:
	j reverse_postfix	
	
	print:
		# Open file in writting mode
		li $v0, 13
		la $a0, prefixFile
		li $a1, 1
		syscall
		move $s0, $v0
		
		# Write file
		li $v0, 15
		move $a0, $s0
		la $a1, prefix
		la $a2, 2048
		syscall
		
		# Close file
		li $v0, 16
		move $a0, $s0
		syscall
	
		j End_Program


########################################################
reverse_postfix:
	li $k0, -1 # index counter in reversePostfix
	li $k1, -1 # index counter of tmp

	reverse_postfix_loop:								
		lb $s1, postfix($t7)  
		beq $s1, '\0', push_reversePostfix
							
		add $a0, $zero, $s1 # character to check
		jal check_number # ìf(0 <= $a0 && $ $a0 <= 9) $v0 = 1; else $v0 = 0
		
		beqz $v0, push_reversePostfix
		
		push_number_to_tmp:
			add $k1, $k1, 1
			sb $s1, tmp($k1)
			
			add $t7, $t7, -1
			j reverse_postfix_loop
								
		push_reversePostfix:			
			check_1:
				li $t8, -1
				slt $v0, $t8, $k1
				beq $v0, 1, push_reversePostfix_from_tmp 
			
			continue_reverse_1:
				add $k0, $k0, 1
				sb $s1, reversePostfix($k0)
				
				# if ($s1 == '\0'), we push it to prefix but not using it. So, we need to decrease$ $k0 again.
				beq $s1, '\0', dec_k1 
				
				G:
					add $t7, $t7, -1
				
					li $t8, -1
					slt $v0, $t8, $t7
					beqz $v0, move_reversePostfix_to_prefix
				
					j reverse_postfix_loop	
		
		push_reversePostfix_from_tmp:
				beq $k1, -1, continue_reverse_1
				
				lb $t8, tmp($k1)
				li $v0, '\0'
				sb $v0, tmp($k1)
				add $k1, $k1, -1
				
				add $k0, $k0, 1
				sb $t8, reversePostfix($k0)
				
				j push_reversePostfix_from_tmp			
		
		dec_k1: 
			add $k0, $k0, -1
			j G


###################################################################
move_reversePostfix_to_prefix:
	li $k1, -1 # index counter of tmp
	li $t7, -1 # index counter of prefix
	li $v0, 0 # reversePostfix is not empty
	
	push_into_tmp_3:
		beq $k0, -1, reversePostfix_is_empty
		
		lb $t9, reversePostfix($k0)
		li $t8, '\0'
		sb $t8, reversePostfix($k0)
		add $k0, $k0, -1
		
		beq $k0, -1, reversePostfix_is_empty
		beq $t9, '\n', push_prefix
	
		add $k1, $k1, 1
		sb $t9, tmp($k1)
		
		j push_into_tmp_3
		
	reversePostfix_is_empty:
		li $v0, 1
		li $t9, '\0'
		
	push_prefix:		
		add $t0, $t7, $k1
		add $t0 $t0, 2
		sb $t9, prefix($t0)
				
		push_prefix_loop:
			jal check_condition_stop_k1_3				
			
			lb $t9, tmp($k1)
			li $t8, '\0'
			sb $t8, tmp($k1)
			add $k1, $k1, -1
		
			add $t7, $t7, 1
			sb $t9, prefix($t7)
		
			j push_prefix_loop
		
	check_condition_stop_k1_3:
		beq $k1, -1, check_condition_stop_v0_3
		jr $ra
	
	check_condition_stop_v0_3:
		beq $v0, 1, print
		add $t7, $t7, 1
		j push_into_tmp_3
