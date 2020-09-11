# CSE 220 Programming Project #3
# Xin Han Huang
# xinhahuang
# 111698543

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
initialize:
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp) 
    sw $s2, 8($sp)
    
    blez $a1, initialize.error #if row is less than or equal to 0, then return error
    blez $a2, initialize.error #if col is less than ro equal to 0, then return error 

    sb $a1, 0($a0) #store the row into the struct
    addi $a0, $a0, 1 #move on to the next pointer
    sb $a2, 0($a0) #store the column into the struct
    addi $a0, $a0, 1 #move on to the next pointer
    
    mult $a1, $a2 #First multiply the row and column 
    mflo $s0 #move the result of the multiplcation to $s0 
    li $s1, 0 #this is the counter for a loop 
    
    initialize.loop:
    beq $s1, $s0, initialize.return #once the counter reaches the result of the multiplication we stop
    lbu $s2, 0($a0) #load $a0 byte by byte
    sb $a3, 0($a0) #now store the byte of a3 into a0 
    addi $s1, $s1, 1 #counter++
    addi $a0, $a0, 1 #Pointer++ 
    j initialize.loop
    
    initialize.return:
    move $v0, $a1 #move the num rows to $v0
    move $v1, $a2 #move the num cols to v1 
    j initialize.finalize
    
    initialize.error:
    li $s0, -1
    move $v0, $s0 
    li $s0, -1
    move $v1, $s0 
    j initialize.finalize
    
    initialize.finalize:
    lw $s0, 0($sp)
    lw $s1, 4($sp) 
    lw $s2, 8($sp)
    addi $sp, $sp, 12
    jr $ra

load_game:
    addi $sp, $sp, -32
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)
    
    move $s0, $a0 #move state to $s0
    move $s1, $a1 #now move the fileName to $s1
    li $s2, 0 #this is the return value for the number of Os we come across
    li $s3, 0 #this is the return value for the number of invalids we come across
    
    move $a0, $s1 #move the file name to argument $a0
    li $a1, 0 #we set $a1 -> read only
    li $a2, 0 #mode -> ignore 
    li $v0, 13 #now we syscall for opening a file
    syscall
    
    bltz $v0, load_game.error #if less than 0 (-1), then we exit
    move $s1, $v0 #we set $s1 to the file descriptor
    
    move $a0, $s1 #move the file descriptor to argument a0 
    
    
    #li $t0, 0 #t0 to initialize the stack
    #sw $t0, 0($sp) #initialize the stack at 0
    

    move $a1, $s0
    li $a2, 1# 1 byte at a time at a time
    li $v0, 14 #syscall for reading a file
    syscall
    
    lbu $t0, 0($a1) #move the content of the read number to t0
    addi $t0, $t0, -48 #subtract 48 to convert from ascii to int 
    sb $t0, 0($a1) #now store that value back into the state 
    
    addi $a1, $a1, 1
    li $v0, 14
    syscall 
    
    lbu $t0, 0($a1) #now we load the next byte of character
    addi $t0, $t0, -48 #convert to int
    bltz $t0, load_game.storeColumn #if blank space then we ignore and go to the next line to store column
    lbu $t1, -1($a1) #if not, then we must retrieve the previous byte and multiply it by 10 as the 10th digit
    li $t2, 10 #now we load 10 into t2
    mult $t1, $t2 #multiply t1 and t2
    mflo $t1 #store the result into t1
    add $t1, $t1, $t0 #now add t1 and t0 
    sb $t1, -1($a1) #else we store the new byte onto the state
    #current index is still the second byte
    move $s4, $t1 #store the row in s4
    
    #read the line feed 
    li $v0, 14 
    syscall #read the line feed then continue on to read the next character 
    j load_game.startStoringColumn
    
    load_game.storeColumn:
    lbu $t1, -1($a1) #retrieve the previous number and then store it to s4
    move $s4, $t1 #we move t0 to s4 
    load_game.startStoringColumn:
    
    li $v0, 14 #syscall for reading a file
    syscall
    
    lbu $t0, 0($a1) #move the content of the read number to t0
    addi $t0, $t0, -48 #subtract 48 to convert from ascii to int 
    sb $t0, 0($a1) #now store that value back into the state 
    
    addi $a1, $a1, 1 #move on to the next pointer 
    li $v0, 14
    syscall 
    
    lbu $t0, 0($a1) #now we load the next byte of character
    addi $t0, $t0, -48 #convert to int
    bltz $t0, load_game.gameBoard #if blank space then we ignore and go to the next line to store column
    lbu $t1, -1($a1) #if not, then we must retrieve the previous byte and multiply it by 10 as the 10th digit
    li $t2, 10 #now we load 10 into t2
    mult $t1, $t2 #multiply t1 and t2
    mflo $t1 #store the result into t1
    add $t1, $t1, $t0 #now add t1 and t0 
    sb $t1, -1($a1) #else we store the new byte onto the state
    #current index is now on the third byte
    move $s5, $t1 #store the column in s5 
    
    #read the line feed 
    li $v0, 14 
    syscall #read the line feed then continue on to read the next character 
    j load_game.gameBoardStart
    
    load_game.gameBoard: #now we loop to load the gameboard in a row major 2D array fashion 
    lbu $t1, -1($a1) #retrieve the previous number and then store it to s4
    move $s5, $t1 #we move t0 to s5 
    load_game.gameBoardStart:
    
    li $s6, 0 #s4 will act as the big counter for the outer loop 
    load_game.outerLoop:
    beq $s6, $s4, load_game.return #return when we finish doing the loop row number of time
    li $s7, 0 #this is the counter for the inner loop 
    load_game.innerLoop: 
    beq $s7, $s5, load_game.backToOuterLoop #once we finish the loop column number of times, we go back to the outer loop
    li $v0, 14 #syscall for reading a file
    syscall #read the next byte
    lbu $t0, 0($a1) #now we load the next byte of character into t0
    li $t1, 46
    beq $t0, $t1, load_game.dotBranch #if equal to . branch
    li $t1, 79
    beq $t0, $t1, load_game.OBranch #if equal to O, branch
    li $t1, 46 #if not either, then its an invalid character and then we must load . into the proper state instead
    sb $t1, 0($a1) #store the . into the current address 
    addi $a1, $a1, 1 #move on to the next address of the state
    addi $s7, $s7, 1 #counter++ 
    addi $s3, $s3, 1 #invalid character count++
    j load_game.innerLoop #go back to the loop 
    
    load_game.dotBranch:
    addi $a1, $a1, 1 #move on to the next address of the state
    addi $s7, $s7, 1 #counter++
    j load_game.innerLoop #go back to the loop
    
    load_game.OBranch:
    addi $a1, $a1, 1 #move on to the next address of the state
    addi $s7, $s7, 1 #counter++
    addi $s2, $s2, 1 #O counter return ++ 
    j load_game.innerLoop #go back to the innerLoop
    
    load_game.backToOuterLoop:
    addi $s6, $s6, 1 #big counter++
    li $v0, 14 #syscall for reading a file, read the line buffer so the next one directly loads 
    syscall #read the next byte of line buffer 
    j load_game.outerLoop #now go back to the outerloop 
    
    load_game.error:
    li $v0, -1
    li $v1, -1 
    j load_game.jr
    
    load_game.return:
    #li $t0, 0 #null terminator
    #sb $t0, 0($a1) #store the null terminator at the end of the byte
    move $v0, $s2 #number of Os
    move $v1, $s3 #number of invalids
    
    load_game.jr:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $s7, 28($sp)
    addi $sp, $sp, 32
    jr $ra

get_slot:
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp) 
    sw $s3, 12($sp)
    
    lbu $s0, 0($a0) #loads the row ascii byte first and store it to $s0
    addi $a0, $a0, 1 #now pointer++ to the column byte
    lbu $s1, 0($a0) #loads the column ascii byte and then store it to $s1 
    addi $a0, $a0, 1 #now we have moved on to the board information
    bge $a1, $s0, get_slot.error #if the row inputted into the function is greater than actual, then error
    bge $a2, $s1, get_slot.error #if the column inputted into the function is greater than the actual, then error 
    
    mult $a1, $s1 #multiply the row input by the column specified by struct
    mflo $s3 #then we move the result into s3
    add $s3, $s3, $a2 #now add the result to the argument specified column to get the index
    add $a0, $a0, $s3 #now we add to the pointer the result of the index
    lbu $s3, 0($a0) #now we move the content at $a0 to $s3
    move $v0, $s3 #now move the result to v0
    j get_slot.return
    
    get_slot.error:
    li $v0, -1
    
    get_slot.return:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    addi $sp, $sp, 16 
    jr $ra

set_slot:
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp) 
    sw $s3, 12($sp)
    
    lbu $s0, 0($a0) #loads the row ascii byte first and store it to $s0
    addi $a0, $a0, 1 #now pointer++ to the column byte
    lbu $s1, 0($a0) #loads the column ascii byte and then store it to $s1 
    addi $a0, $a0, 1 #now we have moved on to the board information
    bge $a1, $s0, set_slot.error #if the row inputted into the function is greater than actual, then error
    bge $a2, $s1, set_slot.error #if the column inputted into the function is greater than the actual, then error 
    
    mult $a1, $s1 #multiply the row input by the column specified by struct
    mflo $s3 #then we move the result into s3
    add $s3, $s3, $a2 #now add the result to the argument specified column to get the index
    add $a0, $a0, $s3 #now we add to the pointer the result of the index
    #lbu $s3, 0($a0) #now we move the content at $a0 to $s3
    #move $v0, $s3 #now move the result to v0
    sb $a3, 0($a0) #now store $a3 into that memory address 
    move $v0, $a3 #now move the result to v0
    j set_slot.return
    
    set_slot.error:
    li $v0, -1
    
    set_slot.return:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    addi $sp, $sp, 16 
    
    jr $ra

rotate:
    addi $sp, $sp -28
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $ra, 24($sp)
    
    
    move $s0, $a0 #move piece to rotate eto s0
    move $s1, $a1 #move the rotation numbers to s1
    move $s2, $a2 #move the rotated piece address to s2
    
    bltz $s1, rotate.error #if the number of times to rotate is negative then we throw an error
    beqz $s1, rotate.zeroRotate #if the number of times to rotate is 0 then we handle accordingly
    
    li $t0, 4
    div $s1, $t0
    mfhi $s1 #divide by 4 and move the remainder to s1, this will still be the amount of time to rotate
    
    lbu $s3, 0($s0) #we load the row byte of the piece we need to rotate
    addi $s0, $s0, 1 #address++
    lbu $s4, 0($s0) #now we store the column byte of the piece we need to rotate
    addi $s0, $s0, -1 #reset the address to its original position
    mult $s3, $s4 #now we multiply s3 and s4
    mflo $t0 #move the result of the multiplication to t0 
    li $t1, 4 #we need to check if the piece is either an I piece or O piece, as those are special conditions
    beq $t0, $t1, rotate.IorOPiece #if the result is 4, then the pieces are either I or 0
    #if not, then we continue with the rotation
    
    li $t1, 2 #we need to check if the row is 2 or 3, if 2 then branch, if not then it must be 3
    beq $s3, $t1, rotate.RowIs2 #if the row  byte is 2, then we branch and deal with row is 2 rotation
    #else we continue and deal with the situation with if row is 3
    li $t9, 0 #t9 to row
    li $t8, 0 #t8 to col 
    move $a0, $s0 #move the piece to rotate address to a0
    move $a1, $t9 #move the row to argument 1
    move $a2, $t8 #move the column to argument 2
    jal get_slot #call get slot
    move $t0, $v0 #now move the result of get slot to t0 
    
    li $t9, 0 #t9 to row
    li $t8, 1 #t8 to one
    move $a0, $s0 
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t1, $v0 #move the result to t1
    
    li $t9, 1
    li $t8, 0
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t2, $v0 #move the result to t2
    
    li $t9, 1
    li $t8, 1
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t3, $v0 
    
    li $t9, 2
    li $t8, 0
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t4, $v0
    
    li $t9, 2
    li $t8, 1
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t5, $v0 
    
    #now the results are in $t0 - $t5 respectively this is for row 3, column 2
    move $a0, $s2 #move the rotated piece address into s0 and initialize that
    li $t9, 2 #rows
    li $t8, 3 #columns
    li $t7, 46 #initialize the new state with all .s 
    move $a1, $t9 #set a1 to row
    move $a2, $t8 #set a2 to column
    move $a3, $t7 #set a3 to . 
    jal initialize #now we call initialize 
    
    move $a0, $s2 #move the rotated piece address back into a0 for the set function
    li $t9, 0 #row to 0
    li $t8, 0 #col to 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t4 #set t4 to argument 3 
    jal set_slot #now set the slot 
    
    move $a0, $s2 
    li $t9, 0
    li $t8, 1
    move $a1, $t9
    move $a2, $t8
    move $a3, $t2 #set t2 to argument 3
    jal set_slot #now set the slot
    
    move $a0, $s2 
    li $t9, 0
    li $t8, 2
    move $a1, $t9
    move $a2, $t8
    move $a3, $t0 #set t0 to argument 3
    jal set_slot #now set the slot 
    
    move $a0, $s2
    li $t9, 1
    li $t8, 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t5 
    jal set_slot 
    
    move $a0, $s2
    li $t9, 1
    li $t8, 1
    move $a1, $t9
    move $a2, $t8
    move $a3, $t3
    jal set_slot
    
    move $a0, $s2
    li $t9, 1
    li $t8, 2
    move $a1, $t9
    move $a2, $t8
    move $a3, $t1
    jal set_slot 
    
    addi $s1, $s1, -1 #decrement the number of times to rotate 
    #now we finish setting all the slots 
    j rotate.nextStep #jump to the next step 
    
    rotate.RowIs2: #this is for when row is 2 
    
    li $t9, 0 #t9 to row
    li $t8, 0 #t8 to col 
    move $a0, $s0 #move the piece to rotate address to a0
    move $a1, $t9 #move the row to argument 1
    move $a2, $t8 #move the column to argument 2
    jal get_slot #call get slot
    move $t0, $v0 #now move the result of get slot to t0 
    
    li $t9, 0 
    li $t8, 1
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t1, $v0
    
    li $t9, 0
    li $t8, 2
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t2, $v0
    
    li $t9, 1
    li $t8, 0
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t3, $v0
    
    li $t9, 1
    li $t8, 1
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t4, $v0
    
    li $t9, 1
    li $t8, 2
    move $a0, $s0
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t5, $v0 
    
    #now the results are in $t0 - $t5 respectively this is for row2, column 3
    move $a0, $s2 #move the rotated piece address into s0 and initialize that
    li $t9, 3 #rows
    li $t8, 2 #columns
    li $t7, 46 #initialize the new state with all .s 
    move $a1, $t9 #set a1 to row
    move $a2, $t8 #set a2 to column
    move $a3, $t7 #set a3 to . 
    jal initialize #now we call initialize     

    move $a0, $s2 #move the rotated piece address back into a0 for the set function
    li $t9, 0 #row to 0
    li $t8, 0 #col to 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t3 #set t3 to argument 3 
    jal set_slot #now set the slot     
    
    move $a0, $s2
    li $t9, 0
    li $t8, 1 
    move $a1, $t9
    move $a2, $t8
    move $a3, $t0
    jal set_slot
    
    move $a0, $s2
    li $t9, 1
    li $t8, 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t4
    jal set_slot
    
    move $a0, $s2
    li $t9, 1
    li $t8, 1
    move $a1, $t9
    move $a2, $t8
    move $a3, $t1
    jal set_slot
    
    move $a0, $s2
    li $t9, 2
    li $t8, 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t5
    jal set_slot
    
    move $a0, $s2
    li $t9, 2
    li $t8, 1
    move $a1, $t9
    move $a2, $t8
    move $a3, $t2
    jal set_slot 
    
    addi $s1, $s1, -1 #decrement the number of times to rotate 
    #now we finish setting all the slots 
    
    rotate.nextStep:
    beqz $s1, rotate.return #if s1 is now 0, then we just finished rotating and we can return now 
    #otherwise we keep going in a loop 
    #$s1 contains the number of times we have to loop before we return 
    #now we need something to keep track of the loop counter 
    #s5 will be used as the counter for this next loop we are executing 
    
    li $s5, 0 #initialize the counter for the loop we are going to execute 
    rotate.loop: 
    beq $s5, $s1, rotate.return #we return once we finish executing all the loops 
    lbu $t0, 0($s2) #we load the row of $s2 to check how to rotate 
    li $t1, 2 #if we need check whether or not the row is equal to 2 
    beq $t0, $t1, rotate.Rowis2Two #if row is 2, then do the loop for row as 2, otherwise continue as row is 3
    
    li $t9, 0 #t9 to row
    li $t8, 0 #t8 to col 
    move $a0, $s2 #move the piece to rotate address to a0
    move $a1, $t9 #move the row to argument 1
    move $a2, $t8 #move the column to argument 2
    jal get_slot #call get slot
    move $t0, $v0 #now move the result of get slot to t0 
    
    li $t9, 0 #t9 to row
    li $t8, 1 #t8 to one
    move $a0, $s2 
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t1, $v0 #move the result to t1
    
    li $t9, 1
    li $t8, 0
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t2, $v0 #move the result to t2
    
    li $t9, 1
    li $t8, 1
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t3, $v0 
    
    li $t9, 2
    li $t8, 0
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t4, $v0
    
    li $t9, 2
    li $t8, 1
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t5, $v0 
    
    #now the results are in $t0 - $t5 respectively this is for row 3, column 2
    move $a0, $s2 #move the rotated piece address into s0 and initialize that
    li $t9, 2 #rows
    li $t8, 3 #columns
    li $t7, 46 #initialize the new state with all .s 
    move $a1, $t9 #set a1 to row
    move $a2, $t8 #set a2 to column
    move $a3, $t7 #set a3 to . 
    jal initialize #now we call initialize 
    
    move $a0, $s2 #move the rotated piece address back into a0 for the set function
    li $t9, 0 #row to 0
    li $t8, 0 #col to 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t4 #set t4 to argument 3 
    jal set_slot #now set the slot 
    
    move $a0, $s2 
    li $t9, 0
    li $t8, 1
    move $a1, $t9
    move $a2, $t8
    move $a3, $t2 #set t2 to argument 3
    jal set_slot #now set the slot
    
    move $a0, $s2 
    li $t9, 0
    li $t8, 2
    move $a1, $t9
    move $a2, $t8
    move $a3, $t0 #set t0 to argument 3
    jal set_slot #now set the slot 
    
    move $a0, $s2
    li $t9, 1
    li $t8, 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t5 
    jal set_slot 
    
    move $a0, $s2
    li $t9, 1
    li $t8, 1
    move $a1, $t9
    move $a2, $t8
    move $a3, $t3
    jal set_slot
    
    move $a0, $s2
    li $t9, 1
    li $t8, 2
    move $a1, $t9
    move $a2, $t8
    move $a3, $t1
    jal set_slot 
    
    addi $s5, $s5, 1 #counter++ 
    #now we finish setting all the slots 
    j rotate.loop #go back to the loop 
    
   
    rotate.Rowis2Two:
    li $t9, 0 #t9 to row
    li $t8, 0 #t8 to col 
    move $a0, $s2 #move the piece to rotate address to a0
    move $a1, $t9 #move the row to argument 1
    move $a2, $t8 #move the column to argument 2
    jal get_slot #call get slot
    move $t0, $v0 #now move the result of get slot to t0 
    
    li $t9, 0 
    li $t8, 1
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t1, $v0
    
    li $t9, 0
    li $t8, 2
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t2, $v0
    
    li $t9, 1
    li $t8, 0
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t3, $v0
    
    li $t9, 1
    li $t8, 1
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t4, $v0
    
    li $t9, 1
    li $t8, 2
    move $a0, $s2
    move $a1, $t9
    move $a2, $t8
    jal get_slot
    move $t5, $v0 
    
    #now the results are in $t0 - $t5 respectively this is for row2, column 3
    move $a0, $s2 #move the rotated piece address into s0 and initialize that
    li $t9, 3 #rows
    li $t8, 2 #columns
    li $t7, 46 #initialize the new state with all .s 
    move $a1, $t9 #set a1 to row
    move $a2, $t8 #set a2 to column
    move $a3, $t7 #set a3 to . 
    jal initialize #now we call initialize     

    move $a0, $s2 #move the rotated piece address back into a0 for the set function
    li $t9, 0 #row to 0
    li $t8, 0 #col to 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t3 #set t3 to argument 3 
    jal set_slot #now set the slot     
    
    move $a0, $s2
    li $t9, 0
    li $t8, 1 
    move $a1, $t9
    move $a2, $t8
    move $a3, $t0
    jal set_slot
    
    move $a0, $s2
    li $t9, 1
    li $t8, 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t4
    jal set_slot
    
    move $a0, $s2
    li $t9, 1
    li $t8, 1
    move $a1, $t9
    move $a2, $t8
    move $a3, $t1
    jal set_slot
    
    move $a0, $s2
    li $t9, 2
    li $t8, 0
    move $a1, $t9
    move $a2, $t8
    move $a3, $t5
    jal set_slot
    
    move $a0, $s2
    li $t9, 2
    li $t8, 1
    move $a1, $t9
    move $a2, $t8
    move $a3, $t2
    jal set_slot 
    
    addi $s5, $s5, 1 #counter++
    j rotate.loop #go back to the loop 
    
    
    rotate.IorOPiece:
    #if O piece, then all we have to do is copy store the bytes, and then return the number of times to rotate
    lbu $s3, 0($s0) #we load the row byte of the piece we need to rotate
    li $t9, 2 #see if it is 2, if not 2, then it is an I piece
    beq $s3, $t9, rotate.OPiece #if it is 2, then it must be an O piece
    #else we code the I piece here...
    #for the I piece we only have to worry about switching the rows and columns 

    
    #li $t1, 1 #we need to check if the row is 1 or 4, if 1 then branch, if 4 then we continue 
    #beq $s3, $t1, rotate.RowIs1 #if the row  byte is 1, then we branch and deal with row is 1 rotation
    #else we continue with the row is 4 rotation, if row is 4, then we initialize rotated with 1,4
    
    lbu $t0, 1($s0) #load the first byte of the piece to rotate
    #sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    #addi $s2, $s2, 1 #pointer++ 
    
    lbu $t1, -1($s0) #load the first byte of the piece to rotate
    #sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    #addi $s2, $s2, 1 #pointer++ 
    
    sb $t0, 0($s2)
    sb $t1, 1($s2)
    
    addi $s2, $s2, 1
    addi $s2, $s2, 1
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1
    addi $s2, $s2, 1 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, -7
    addi $s2, $s2, -7
    
    addi $s1, $s1, -1 #decrement rotation 
    
    beqz $s1, rotate.return #if once is the only time we have to rotate, then return, else continue
    
    #s1 is the amount of time we have to loop
    li $s5, 0 #s5 is the counter for the loop we are about to execute
    
    rotate.ILoop:
    beq $s5, $s1, rotate.return #return once we have finished this loop rotation number of times 
    
    lbu $t0, 1($s2) #load the first byte of the piece to rotate
    lbu $t1, 0($s2) 
    sb $t0, 0($s2) #now copy and store that byte 
    sb $t1, 1($s2)
    
    addi $s5, $s5, 1 #counter++
    j rotate.ILoop #go back to the original loop
    
    rotate.OPiece:
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1
    addi $s2, $s2, 1 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 

    move $v0, $s1 #return the number of times we technically rotated 
    j rotate.jr #return
    
    rotate.error:
    li $v0, -1 #we return -1 if there is an error and leave the contents unchanged 
    j rotate.jr 
    
    rotate.zeroRotate:
    #if rotated zero times, all we need to do is copy the information in piece to rotated piece, returning rotation is 0 
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1
    addi $s2, $s2, 1 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 
    addi $s0, $s0, 1 #pointer++
    addi $s2, $s2, 1 #pointer++ 
    
    lbu $t0, 0($s0) #load the first byte of the piece to rotate
    sb $t0, 0($s2) #now copy and store that byte 


    li $v0, 0 #we rotated 0 times
    j rotate.jr #return
    
    
    rotate.return:
    addi $s1, $s1, 1 #we add s1 back to where it originally was before
    move $v0, $s1 #move s1 to v0 and then we return it 

    rotate.jr:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp 28
    
    jr $ra

count_overlaps: 
    addi $sp, $sp, -36
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)
    sw $ra, 32($sp)
    


    move $s0, $a0 #move the state to s0
    move $s1, $a1 #move the rows to s1
    move $s2, $a2 #move the columns to s2
    move $s3, $a3 #move the piece state to s3
    
    bltz $s1, count_overlaps.error #if row is negative, then we throw an error
    bltz $s2, count_overlaps.error #if column is negative, then we throw an error 
    lbu $t0, 0($s3) #store the row of the game piece into t0
    addi $s3, $s3, 1 #pointer++
    lbu $t1, 0($s3) #store the column of the game piece into t1
    addi $s3, $s3, -1 #pointer reset 
    add $t0, $t0, $s1 #set t0 to the total of the row of the game piece + position of the left most row 
    add $t1, $t1, $s2 #set t1 to the total of the column of the game piece + position of the left most column
    
    lbu $t2, 0($s0) #load the row of the game state into t2 
    addi $s0, $s0, 1 #Pointer++
    lbu $t3, 0($s0) #load the column of the game state into t3
    addi $s0, $s0, -1 #reset the pointer 
    
    blt $t2, $t0, count_overlaps.error #if the game piece total row < the left most row index + number of rows the piece has in total, throw error
    blt $t3, $t1, count_overlaps.error #if the game piece total column < the left most column index + number of columns of the piece has in total, throw error
    #otherwise, once we have checked all these conditions, we assume that the rest of this board is valid 
    li $t0, 0 #t0 will be the counter to count how many overlapping pieces there are. THIS IS ALSO THE RETURN VALUE 
    #set up a double for loop to check for errors
    lbu $s4, 0($s3) #store the row of the game piece into s4
    addi $s3, $s3, 1 #pointer++
    lbu $s5, 0($s3) #store the column of the game piece into s5
    addi $s3, $s3, 1 #pointer next
    li $s6, 0 #this is the ROW counter for the outer for loop
    count_overlaps.rowLoop: 
    beq $s6, $s4, count_overlaps.return #we return once we have finished with the outer loop
    li $s7, 0 #this is the COLUMN counter for the inner for loop 
    count_overlaps.columnLoop:
    beq $s7, $s5, count_overlaps.returnToRowLoop #once the column counter is finished we return to the row loop 
    lbu $t1, 0($s3) #loads the byte of the piece data into $t1
    li $t2, 79 #loads O into t2
    bne $t1, $t2, count_overlaps.ignore #if the game piece is not an O but a ., then we ignore and go back to the loop
    add $t1, $s6, $s1 #set t1 to the sum of the current row count + the upper left row given 
    add $t2, $s7, $s2 #set t7 to the sum of the current column count + the upper column given
    move $a0, $s0 #move game state into a0 
    move $a1, $t1 #move the sum row to a1 
    move $a2, $t2 #move the sum column to a2
    jal get_slot #call get slot to get that byte of the game board state 
    move $t1, $v0 #move the result of the return value into t1
    li $t2, 79 #loads O into t2
    bne $t1, $t2, count_overlaps.ignore #if the game board state is not an O, then there is no overlap and we go back to the row loop
    addi $t0, $t0, 1 #else main return counter++ signifying an overlap 
    addi $s3, $s3, 1 #pointer of the game piece++ 
    addi $s7, $s7, 1 #COLUMN counter++
    j count_overlaps.columnLoop #go back to the loop
    
    count_overlaps.ignore:
    addi $s3, $s3, 1 #pointer of the game piece++
    addi $s7, $s7, 1 #COLUMN counter++ 
    j count_overlaps.columnLoop #go back to the loop 
    
    count_overlaps.returnToRowLoop:
    addi $s6, $s6, 1 #ROW counter++
    j count_overlaps.rowLoop #return to the outer row loop 
    
    count_overlaps.error:
    li $t0, -1
    move $v0, $t0
    j count_overlaps.jr 
    
    count_overlaps.return:
    move $v0, $t0 #move the counter into v0
    
    
    count_overlaps.jr:
    
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $s7, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
    
    jr $ra

drop_piece:
    #lw $s4, 0($sp) #load the address of the rotated piece to $s4 first 
    
    addi $sp, $sp, -36
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)
    sw $ra, 32($sp)
    
    addi $sp, $sp, 36
    lw $s4, 0($sp)
    addi $sp, $sp, -36
    
    move $s0, $a0 #move the gamestate to s0
    move $s1, $a1 #move the COL number to s1
    move $s2, $a2, #move the PIECE STATE to s2
    move $s3, $a3, #move the rotation number to s3 
    
    bltz $s3, drop_piece.error2 #if the rotation number is less than 0, branch error and return -2
    bltz $s1, drop_piece.error2 #if column is negative, branch error and return -2 
    addi $s0, $s0, 1 #move on the the next pointer to get the column address of the game state
    lbu $t0, 0($s0) #store the column of the game state into t0
    addi $s0, $s0, -1 #reset the pointer 
    bge $s1, $t0, drop_piece.error2 #if column is greater than or equal to the number of columns in the state, branch error and return -2
    
    move $a0, $s2 #move the piece state to s2 
    move $a1, $s3 #move the rotation number to a1
    move $a2, $s4 #move the rotated piece to a1 
    jal rotate #and then we call rotate 
    #now $s4 should have the rotated piece ready 
    addi $s4, $s4, 1 #move on the the next pointer to get the column address of the game state
    lbu $t0, 0($s4) #store the column of the piece state into t0
    addi $s4, $s4, -1 #reset the pointer     
    add $t0, $t0, $s1 #set t0 to the sum of the game piece column and argument column
    addi $s0, $s0, 1
    lbu $t1, 0($s0) #store the column of the game state into t1
    addi $s0, $s0, -1 #reset the pointer
    bgt $t0, $t1, drop_piece.error3 #if the game piece column + argument column is greater than the game state column, branch error return -3 
    #now attempt to see if the game piece can even fit into the 0th row 
    li $t0, 0 #load 0 into t0
    move $a0, $s0 #move the game state to s0 
    move $a1, $t0 #now load the value 0 for 0th row into a1 
    move $a2, $s1 #move the column argument to a2
    move $a3, $s4 #move the rotated piece into a3 
    jal count_overlaps #now count to see if there are any overlaps 
    move $t0, $v0 #move the result into t0 
    bgtz $t0, drop_piece.error1 #if the return value is anything that is greater than 0 (meaning overlap), we return error -1 because the piece cannot be dropped
    #else we start to do the loop 
    #use t9 to hold the upper limit of the loop
    lbu $t9, 0($s0) #move the ROW_count of the state to t9, this will be the counter 
    li $s5, 1 #holds the counter for the ROW that WE ARE CURRENTLY ON. use 1 because we technically already iterated the loop once 
    drop_piece.iterativeLoop:
    beq $s5, $t9, drop_piece.writeToBoard #once the counter reaches the number of rows, we then start writing to the board.
    move $a0, $s0 #move the game state to a0 
    move $a1, $s5 #move the current ROW Counter that we are on to argument 1
    move $a2, $s1 #move the argument Column to argument 2
    move $a3, $s4 #move the rotated piece to the final argument
    jal count_overlaps
    move $t0, $v0 #move the return result to t0
    bgtz $t0, drop_piece.writeToBoard #if there are any overlaps, then we can exit out of the loop and start writing to the game board
    bltz $t0, drop_piece.writeToBoard #if error, then we also do the same 
    addi $s5, $s5, 1 #counter++
    j drop_piece.iterativeLoop #go back to the loop 
    
    
    drop_piece.writeToBoard:
    addi $s5, $s5, -1 #decrement the s5 counter because if there is an overlap, that means we must place the piece to the previous row
    #now to get the rotated piece's row and column arguments 
    lbu $s6, 0($s4) #load the rotated piece's ROW to s6
    addi $s4, $s4, 1 #pointer++
    lbu $s7, 0($s4) #load the rotate piece's COLUMN to s7
    addi $s4, $s4, -1 #pointer reset
    
    li $t9, 0 #this is the row counter for the double for loop we are about to execute
    drop_piece.rowLoop:
    beq $t9, $s6, drop_piece.return #we return one we have finished executing all the loop 
    li $t8, 0 #this is the column counter for the double loop 
    drop_piece.columnLoop:
    beq $t8, $s7, drop_piece.returnToRowLoop #return to the row loop once the column loop finishes executing
    move $a0, $s4 #move the rotated piece to argument 0
    move $a1, $t9 #move the row counter to argument 1
    move $a2, $t8 #move the argumenet counter to argument 2
    jal get_slot
    move $t0, $v0 #move the result to t0
    #if the slot is a . , then we can just skip back to the original loop 
    li $t1, 46 #loads the . into t1
    beq $t0, $t1, drop_piece.ignore #we ignore and go back to the loop
    add $t1, $s5, $t9 #set t1 to the sum of the row counter and big ROW counter
    add $t2, $s1, $t8 #set t2 to the sum of the column counter and column input argument
    move $a0, $s0 #move the game board to argument 0
    move $a1, $t1 #move t1 to argument 1
    move $a2, $t2 #move t2 to argument 2
    move $a3, $t0 #move the result to argument 0 
    jal set_slot #set the slot for the board
    addi $t8, $t8, 1 #counter++
    j drop_piece.columnLoop #return to the column loop 
   
    drop_piece.ignore:
    addi $t8, $t8, 1 #counter++
    j drop_piece.columnLoop 
    
    drop_piece.returnToRowLoop:
    addi $t9, $t9, 1 #row counter++
    j drop_piece.rowLoop
    
    drop_piece.error1:
    li $v0, -1 #load -1 and return
    j drop_piece.jr
    
    drop_piece.error3:
    li $v0, -3 #load -3 and return
    j drop_piece.jr
    
    drop_piece.error2:
    li $v0, -2 #load -2 and return
    j drop_piece.jr
    
    drop_piece.return: 
    move $v0, $s5 #move the return value to v0 and then return
    
    drop_piece.jr:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $s7, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
    jr $ra

check_row_clear:
    addi $sp, $sp, -28
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $ra, 24($sp) 


    move $s0, $a0 #move the state of the board to s0
    move $s1, $a1 #move the row we want to check to s1 
    lbu $t0, 0($s0) #load the total rows of the state into t0 
    bge $s1, $t0, check_row_clear.error #if the row that we want to check is equal or greater than the total number of rows, then invalid input 
    bltz $s1, check_row_clear.error #if the row is negative, then the input is invalid
    
    addi $s0, $s0, 1 #address pointer++
    lbu $t0, 0($s0) #load the total COLUMN of the state 
    addi $s0, $s0, -1 #address pointer reset 
    
    li $t1, 0 #this is the counter for the loop we'll execute
    check_row_clear.checkingLoop:
    beq $t0, $t1, check_row_clear.replaceProceed#if the counter reaches the number of total columns, then we proceed to replace the board
    move $a0, $s0 #move the game state to argument -
    move $a1, $a1 #move the given row arg into argument 1
    move $a2, $t1 #move the current column counter into a2 
    jal get_slot 
    move $t2, $v0 #move the result into t2
    li $t3, 46 #load a . 
    beq $t2, $t3, check_row_clear.quit #if we see a ., that means the row cannot be cleared, so we return 0 and quit
    addi $t1, $t1, 1 #counter++
    j check_row_clear.checkingLoop #jump back into the loop
    
    check_row_clear.replaceProceed:
    move $s2, $s1 #move the row argument into s2
    addi $s2, $s2, -1 #now we decrement s2 so that we can get the previous row's information
    li $s3, 0 #this is the counter for the outerloop 
    addi $s0, $s0, 1 #address pointer++
    lbu $s5, 0($s0) #load the total COLUMN of the state 
    addi $s0, $s0, -1 #address pointer reset 
    check_row_clear.outerLoop:
    beq $s3, $s1, check_row_clear.fillTopRow #once we complete the outer loop row number of times, we return 
    li $s4, 0 #this is the column counter for the inner loop
    check_row_clear.innerLoop:
    beq $s4, $s5, check_row_clear.returnToOuterLoop #we return to the outer loop once we repeat the inner loop column number of times
    move $a0, $s0 #move the state to argument 0 
    move $a1, $s2 #move the previous row's information into a1
    move $a2, $s4 #move the column counter into argument 3
    jal get_slot #now get that slot
    move $t0, $v0 #move the return result into t0 
    addi $s2, $s2, 1 #now get the current row's information 
    move $a0, $s0 #remove the state to a0
    move $a1, $s2 #move the current row's information into a1
    move $a2, $s4 #move the column counter into a2
    move $a3, $t0 #move t0 into the final argument
    jal set_slot #now set the slot
    addi $s2, $s2, -1 #reset the current row's information to that of the previous row
    addi $s4, $s4, 1 #counter++ 
    j check_row_clear.innerLoop #go back into the inner loop 
    
    check_row_clear.returnToOuterLoop:
    addi $s3, $s3, 1 #outerloop counter++
    addi $s2, $s2, -1 #the argument row number information -- to decrement the row 
    j check_row_clear.outerLoop #go back to the outerloop
    
    check_row_clear.fillTopRow:
    li $t0, 46 #load some .s 
    addi $s0, $s0, 1 #address pointer++
    lbu $t1, 0($s0) #load the total COLUMN of the state 
    addi $s0, $s0, -1 #address pointer reset  
    li $t2, 0 #this is the counter for the final loop to execute
    check_row_clear.fillTopRowLoop:
    beq $t2, $t1, check_row_clear.return #we return once the loop has finished executing column number of times
    move $a0, $s0 #move the game piece to argument 0
    li $t3, 0 #load the 0th row
    move $a1, $t3 #we only need the 0th row
    move $a2, $t2 #column is the counter
    move $a3, $t0 #we need to fill with .s 
    jal set_slot 
    addi $t2, $t2, 1 #counter++ 
    j check_row_clear.fillTopRowLoop #jump back to the loop 
    
    
    check_row_clear.quit:
    li $v0, 0 #we return 0 if not all are .s and we cannot clear stuff
    j check_row_clear.jr
    
    
    check_row_clear.error:
    li $v0, -1 #we return -1 when there is an ereror
    j check_row_clear.jr
    
    check_row_clear.return:
    li $v0, 1 #we return 1 when we can clear rows
    
    check_row_clear.jr:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $ra, 24($sp) 
    addi $sp, $sp, 28
    jr $ra

simulate_game:

    addi $sp, $sp, -36
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)
    sw $ra, 32($sp)
    addi $sp, $sp, 36
    lw $s2, 0($sp) #move the number of pieces to drop into s2
    lw $s3, 4($sp) #move the pieces array into s3 
    addi $sp, $sp, -36
    move $s0, $a2 #move the moves string into s0
    move $s1, $a3 #move the rotated piece buffer into s1
    
    move $t6, $a0 #move a0 to t6
    #now we call load_game to initialize our game, and since a0 and a1 already contains the correct arguments, we can justcall
    jal load_game #now we load the game 
    bltz $v1, simulate_game.error #if v1 is less than 0, that means the file paths are invalid and we return 0, 0
    li $s4, 0 #S4 stores the number of successful drops
    li $s5, 0 #s5 stores the number of pieces we have attempted to drop so far 
    #s2 stores moves_length, or the number of pieces to drop 
    li $s6, 0 #game over is false, which is 0. If true, then s6 will be 1
    li $s7, 0 #s6 keeps track of the score so far 
    
    move $a0, $s0 #move the moves string into s0 to calculate the length
    jal strlen
    move $t5, $v0 #now $t5 will have the moves length
    li $t4, 4 #load t4 into 4
    div $t5, $t4
    mflo $t5 #now move the result to t5
    
    simulate_game.retrieveLoop:
    beq $s4, $s2, simulate_game.return #if number of successful drops == pieces to drop, next step
    beq $s5, $t5, simulate_game.return #next step if number of moves == number of moves 
    li $t4, 1
    beq $s6, $t4, simulate_game.return #next step if game over
    lbu $t0, 0($s0) #t0 contains the piece type of the string
    addi $s0, $s0, 1 #s0 pointer++
    lbu $t1, 0($s0) #t1 contains the number of times to rotate
    addi $t1, $t1, -48 #convert from ascii to int 
    addi $s0, $s0, 1 #s0 pointer++
    lbu $t2, 0($s0) #now load the 3rd byte, note this is may be a 0 
    addi $t2, $t2, -48 #convert from ascii to int 
    addi $s0, $s0, 1 #s0 pointer++
    lbu $t3, 0($s0) #now load the final byte. This is always the 1's digit 
    addi $t3, $t3, -48 #convert from ascii to int 
    addi $s0, $s0, 1 #now s0 pointer++ again
    li $t4, 10 #load immediate t4 by 10 
    mult $t2, $t4 #now multiply t2 by 10 
    mflo $t2 #store the result back into t2
    add $t2, $t2, $t3 #now add the 10's digit + 1's digit, t2 now contains the column
    #t0 contains piece type, t1 contains times to rotate, t2 contains column 
    li $t3, 0 #t3 now keeps track of INVALID, 0 is set to false at the moment 
    li $t4, 84 #load T 
    beq $t0, $t4, simulate_game.loadT
    li $t4, 74 #load J
    beq $t0, $t4, simulate_game.loadJ
    li $t4, 90 #load Z
    beq $t0, $t4, simulate_game.loadZ
    li $t4, 79 #;pad P
    beq $t0, $t4, simulate_game.loadO
    li $t4, 83 #load S
    beq $t0, $t4, simulate_game.loadS
    li $t4, 76 #load L
    beq $t0, $t4, simulate_game.loadL
    li $t4, 73 #load I
    beq $t0, $t4, simulate_game.loadI 
    
    simulate_game.loadT:
    lbu $t0, 0($s3) 
    sb $t0, 0($s1)
    lbu $t0, 1($s3)
    sb $t0, 1($s1)
    lbu $t0, 2($s3)
    sb $t0, 2($s1)
    lbu $t0, 3($s3)
    sb $t0, 3($s1)
    lbu $t0, 4($s3)
    sb $t0, 4($s1)
    lbu $t0, 5($s3)
    sb $t0, 5($s1)
    lbu $t0, 6($s3)
    sb $t0, 6($s1)
    lbu $t0, 7($s3)
    sb $t0, 7($s1)
    j simulate_game.attemptDrop
    
    simulate_game.loadJ:
    lbu $t0, 8($s3) 
    sb $t0, 0($s1)
    lbu $t0, 9($s3)
    sb $t0, 1($s1)
    lbu $t0, 10($s3)
    sb $t0, 2($s1)
    lbu $t0, 11($s3)
    sb $t0, 3($s1)
    lbu $t0, 12($s3)
    sb $t0, 4($s1)
    lbu $t0, 13($s3)
    sb $t0, 5($s1)
    lbu $t0, 14($s3)
    sb $t0, 6($s1)
    lbu $t0, 15($s3)
    sb $t0, 7($s1)
    j simulate_game.attemptDrop
    
    simulate_game.loadZ:
    lbu $t0, 16($s3) 
    sb $t0, 0($s1)
    lbu $t0, 17($s3)
    sb $t0, 1($s1)
    lbu $t0, 18($s3)
    sb $t0, 2($s1)
    lbu $t0, 19($s3)
    sb $t0, 3($s1)
    lbu $t0, 20($s3)
    sb $t0, 4($s1)
    lbu $t0, 21($s3)
    sb $t0, 5($s1)
    lbu $t0, 22($s3)
    sb $t0, 6($s1)
    lbu $t0, 23($s3)
    sb $t0, 7($s1)
    j simulate_game.attemptDrop
    
    simulate_game.loadO:
    lbu $t0, 24($s3) 
    sb $t0, 0($s1)
    lbu $t0, 25($s3)
    sb $t0, 1($s1)
    lbu $t0, 26($s3)
    sb $t0, 2($s1)
    lbu $t0, 27($s3)
    sb $t0, 3($s1)
    lbu $t0, 28($s3)
    sb $t0, 4($s1)
    lbu $t0, 29($s3)
    sb $t0, 5($s1)
    lbu $t0, 30($s3)
    sb $t0, 6($s1)
    lbu $t0, 31($s3)
    sb $t0, 7($s1)
    j simulate_game.attemptDrop
    
    simulate_game.loadS:
    lbu $t0, 32($s3) 
    sb $t0, 0($s1)
    lbu $t0, 33($s3)
    sb $t0, 1($s1)
    lbu $t0, 34($s3)
    sb $t0, 2($s1)
    lbu $t0, 35($s3)
    sb $t0, 3($s1)
    lbu $t0, 36($s3)
    sb $t0, 4($s1)
    lbu $t0, 37($s3)
    sb $t0, 5($s1)
    lbu $t0, 38($s3)
    sb $t0, 6($s1)
    lbu $t0, 39($s3)
    sb $t0, 7($s1)
    j simulate_game.attemptDrop
    
    simulate_game.loadL:
    lbu $t0, 40($s3) 
    sb $t0, 0($s1)
    lbu $t0, 41($s3)
    sb $t0, 1($s1)
    lbu $t0, 42($s3)
    sb $t0, 2($s1)
    lbu $t0, 43($s3)
    sb $t0, 3($s1)
    lbu $t0, 44($s3)
    sb $t0, 4($s1)
    lbu $t0, 45($s3)
    sb $t0, 5($s1)
    lbu $t0, 46($s3)
    sb $t0, 6($s1)
    lbu $t0, 47($s3)
    sb $t0, 7($s1)
    j simulate_game.attemptDrop
    
    simulate_game.loadI:
    lbu $t0, 48($s3) 
    sb $t0, 0($s1)
    lbu $t0, 49($s3)
    sb $t0, 1($s1)
    lbu $t0, 50($s3)
    sb $t0, 2($s1)
    lbu $t0, 51($s3)
    sb $t0, 3($s1)
    lbu $t0, 52($s3)
    sb $t0, 4($s1)
    lbu $t0, 53($s3)
    sb $t0, 5($s1)
    lbu $t0, 54($s3)
    sb $t0, 6($s1)
    lbu $t0, 55($s3)
    sb $t0, 7($s1)
    j simulate_game.attemptDrop
    
    simulate_game.attemptDrop:
    #now t0 stores the game piece struct, t1 stores rotation, t2 stores column, t3 stores invalid
    addi $sp, $sp, -20
    sw $t6, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t5, 16($sp)
    #a0 should already contain the game state
    move $a0, $t6
    move $a1, $t2 #move the column to a1
    move $a2, $s1 #move the piece to a2
    move $a3, $t1 #move the rotation to a3
    addi $sp, $sp, -4
    sw $s1, 0($sp) #store rotated piece into the stack to pass
    jal drop_piece 
    addi $sp, $sp, 4 #reset the stack pointer
    #v0 now has the result
    lw $t6, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t5, 16($sp)
    addi $sp, $sp, 20 #reset the stack pointer
    li $t4, -2
    beq $v0, $t4, simulate_game.invalidate 
    li $t4, -3
    beq $v0, $t4, simulate_game.invalidate
    li $t4, -1
    beq $v0, $t4, simulate_game.gameOver
    j simulate_game.nextStep #go to the next step if none of the above is true 
    
    simulate_game.invalidate: 
    li $t3, 1 #now t3 will be 1, invalid is true 
    j simulate_game.nextStep
    
    simulate_game.gameOver:
    li $t3, 1 #invalid is true
    li $s6, 1 #game over, so gameOver is 1, or true 
    j simulate_game.nextStep
    
    simulate_game.nextStep: 
    li $t4, 1 #1 for true
    beq $t3, $t4, simulate_game.continueIteration #if invalid is true, skip and continue
    j simulate_game.resume
    
    simulate_game.continueIteration:
    addi $s5, $s5, 1 #move number++ 
    j simulate_game.retrieveLoop #go back to the while loop
     
    simulate_game.resume:
    
    li $t9, 0 #t9 is the count = 0 
    lbu $t8, 0($t6) #state is still in a0 i think and this loads the row from it 
    addi $t8, $t8, -1 #decrement the state.num_rows by 1 
    li $t7, 0 #loads another 0 because we need like so many of those 
    simulate_game.rowClearLoop:
    beq $t8, $t7, simulate_game.updateScore#when r reaches 0 we finally branch out of this hell
    move $a0, $t6 
    move $a1, $t8 #move r to argument 2 
    addi $sp, $sp, -20
    sw $t9, 0($sp)
    sw $t8, 4($sp)
    sw $t7, 8($sp) 
    sw $t6, 12($sp)
    sw $t5, 16($sp)
    jal check_row_clear
    lw $t9, 0($sp)
    lw $t8, 4($sp)
    lw $t7, 8($sp)
    lw $t6, 12($sp)
    lw $t5, 16($sp)
    addi $sp, $sp, 20
    li $t4, 1
    beq $v0, $t4, simulate_game.IncrementCount
    addi $t8, $t8, -1 #r-- 
    j simulate_game.rowClearLoop #go back to the loop 
    
    simulate_game.IncrementCount:
    addi $t9, $t9, 1 #increment t9
    j simulate_game.rowClearLoop #go back too the loop
    
    simulate_game.updateScore:
    li $t4, 0
    beq $t9, $t4, simulate_game.scoreAdd0
    li $t4, 1
    beq $t9, $t4, simulate_game.scoreAdd40
    li $t4, 2
    beq $t9, $t4, simulate_game.scoreAdd100
    li $t4, 3
    beq $t9, $t4, simulate_game.scoreAdd300
    li $t4, 4
    beq $t9, $t4, simulate_game.scoreAdd1200
    
    simulate_game.scoreAdd0:
    addi $s4, $s4, 1
    addi $s5, $s5, 1
    j simulate_game.retrieveLoop 
    
    simulate_game.scoreAdd40:
    addi $s7, $s7, 40
    addi $s4, $s4, 1
    addi $s5, $s5, 1 #increment both move number and successful drops 
    j simulate_game.retrieveLoop #go back to the original loop
    
    simulate_game.scoreAdd100:
    addi $s7, $s7, 100
    addi $s4, $s4, 1
    addi $s5, $s5, 1 #increment both move number and successful drops 
    j simulate_game.retrieveLoop #go back to the original loop
    
    simulate_game.scoreAdd300:
    addi $s7, $s7, 300
    addi $s4, $s4, 1
    addi $s5, $s5, 1 #increment both move number and successful drops 
    j simulate_game.retrieveLoop #go back to the original loop
    
    simulate_game.scoreAdd1200:
    addi $s7, $s7, 1200
    addi $s4, $s4, 1
    addi $s5, $s5, 1 #increment both move number and successful drops 
    j simulate_game.retrieveLoop #go back to the original loop
    
    simulate_game.error:
    li $v0, 0 
    li $v1, 0 
    j simulate_game.jr #jump simulate_game.jr if error 
    
    simulate_game.return:
    move $v0, $s4 
    move $v1, $s7 #score to v1 
    
    simulate_game.jr:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $s7, 28($sp)
    lw $ra, 32($sp)   
    addi $sp, $sp, 36
    jr $ra
    
    
    strlen:

    li $t1, 0 #this is the string counter
    strlen.loop:
    lbu $t0, 0($a0) #loads each byte from argument a0
    beqz $t0, strlen.return #if null terminated, then return the value
    addi $t1, $t1, 1 #counter++
    addi $a0, $a0, 1 #next byte or character
    j strlen.loop #go back to the loop
    
    strlen.return:
    move $v0, $t1 #move the result of t1 to v0
    jr $ra


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
