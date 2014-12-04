TITLE Program_6     (Program_6.asm)

; Author: Kevin To
; Course / Project ID: CS271/Program_6                 Date: 11/30/2014
; Description: The purpose of this program is to
;			   The problem definition (as given):
;				1. Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
;				2. Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input from
;				    the user, and WriteString to display output.
;					2a. getString should display a prompt, then get the user’s keyboard input into a memory location
;					2b. displayString should the string stored in a specified memory location.
;					2c. readVal should invoke the getString macro to get the user’s string of digits. It should then convert the
;						digit string to numeric, while validating the user’s input.
;					2d. writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to
;						produce the output.
;				3. Write a small test program that gets 10 valid integers from the user and stores the numeric values in an
;				    array. The program then displays the integers, their sum, and their average.


INCLUDE Irvine32.inc

; MACRO Definitions
; ---------------------------------------------------------
; Macro to display a string
; receives: displayStringAddr - the offset to the string to display
; returns: n/a 
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
displayString MACRO displayStringAddr
	push 	edx
	mov 	edx, displayStringAddr
	call 	writestring
	pop 	edx
endm

; ---------------------------------------------------------
; Macro to get user string input 
; receives: promptMsg - the offset to the input message to display to the 
;						user
;			addrToPutString - the variable to store user input
; returns: n/a 
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
getString MACRO promptMsg, addrToPutString
	push	edx
	push 	ecx
	push	eax

	mov		edx, promptMsg
	call	WriteString ; Output the user input message

	mov 	edx, addrToPutString ; Specifies where to put the user input in memory
	mov 	ecx, MAX_STRING_INPUT ; Specifies how many characters will be read from the user input
	call 	ReadString ; Get user input

	pop		eax
	pop 	ecx
	pop		edx
endm

; Constant Definitions
MAX_STRING_INPUT = 100 ; Represents the max size of string to be entered
NUM_OF_INPUTS = 10 ; Number of integers the user needs to input 0

.data
intro_1					BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0
intro_2					BYTE	"Written by: Kevin To", 0
instruct_msg1			BYTE	"Please provide 10 unsigned decimal integers.", 0
instruct_msg2			BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instruct_msg3			BYTE	"After you have finished inputting the raw numbers I will display a list", 0
instruct_msg4			BYTE	"of the integers, their sum, and their average value.", 0
input_msg				BYTE	"Please enter an unsigned number: ", 0
retry_input_msg			BYTE	"Please try again: ", 0
array_display_delimiter	BYTE 	", ", 0 ; Comma delimiter that goes between different array elements 
array_display_msg		BYTE	"You entered the following numbers: ", 0
median_display_msg		BYTE	"The median is ", 0
period_msg				BYTE	".", 0
half_num_string			BYTE	".5", 0
right_paren_display		BYTE	")", 0
left_paren_display		BYTE	"(", 0
exit_msg				BYTE	"Thanks for playing!", 0
invalid_input_msg		BYTE	"ERROR: You did not enter an unsigned number or your number was too big.", 0

unsorted_array			DWORD	NUM_OF_INPUTS DUP(0)
input_before_validate	BYTE 	MAX_STRING_INPUT+1 DUP(?) ; Variable to hold user input before validation
input_after_validate	BYTE 	MAX_STRING_INPUT+1 DUP(?) ; Variable to hold user input after validation
input_length			DWORD	LENGTHOF input_before_validate
input_type_size			DWORD	TYPE input_before_validate
integer_result			DWORD	0 ; Holds the integer value after conversion from a string
recursive_val_holder	BYTE 	2 DUP(?) ; Variable to hold the single character to be displayed

 .code
main PROC
	; ------------Program Introduction Section----------
	push 	OFFSET intro_1 ; Parameter that holds the first part of the introduction
	push 	OFFSET intro_2 ; Parameter that holds the second part of the introduction
	call	introduceProgram ; Introduce the program

	push 	OFFSET instruct_msg1 ; Parameter that holds the first part of the instructions 
	push 	OFFSET instruct_msg2 ; Parameter that holds the second part of the instructions 
	push 	OFFSET instruct_msg3 ; Parameter that holds the third part of the instructions 
	push 	OFFSET instruct_msg4 ; Parameter that holds the fourth part of then instructions 
	call	displayInstructions ; Display the instructions

	; ------------Get User Data Section-----------------
	push	NUM_OF_INPUTS
	push 	OFFSET unsorted_array
	call	getUserNumberInputArray

	; TODO 
	; 2. write the writeVal function
	;	--- -COMMENT display array !!!!
	; ------- comment writeval also!!!
	; 3. write test program to get 10 int from user
	;	3a. Store each int in an array
	;	3b. Display each integer
	;	3c. Diplay their sum
	;	3d. Diplay their average

	; ------------Calculate and Display Median section--------------------
	; Note: Displaying the median requires that the array be sorted first.
	;push	num_to_generate
	;push 	OFFSET unsorted_array
	;call DisplayMedian



	; ------------Display Array section--------------------
	call 	CrLf
	displayString OFFSET array_display_msg ; Display "show array" starting message
	call 	CrLf
	push	NUM_OF_INPUTS
	push 	OFFSET unsorted_array
	call 	displayArray ; Display the sorted array

	; ------------Farwell Section-----------------------
	; NEED TO TEST THIS
	push 	OFFSET exit_msg
	call	farewell

	exit	; exit to operating system
main ENDP

; ---------------------------------------------------------
; Procedure to display program title and
; programmer's name.
; receives: Parameters on the system stack. The top most parameter
; 			is the second part of the intro. The next
;			parameter is the first part of the intro
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
introduceProgram PROC
	pushad
	mov 	ebp, esp

	; Display title
	displayString [ebp+40]
	call	CrLf

	; Display programmer name
	displayString [ebp+36]
	call	CrLf

	popad
	ret 8
introduceProgram ENDP

; ---------------------------------------------------------
; Procedure to display program instructions
; receives: Parameters on the system stack. The top most parameter
; 			is the fourth part of the instructions. The next
;			parameter is the third part of the instructions. The next
;			parameter is the second part of the instructions. 
;			The last parameter is the first part of the instructions.
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
displayInstructions PROC
	pushad
	mov		ebp, esp
	
	; Display program instructions
	call	CrLf
	displayString [ebp+48] ; Display first part
	call	CrLf
	displayString [ebp+44] ; Display second part
	call	CrLf
	displayString [ebp+40] ; Display third part
	call	CrLf
	displayString [ebp+36] ; Display fourth part
	call	CrLf
	call	CrLf
	call	CrLf

	popad
	ret 16
displayInstructions ENDP

; ---------------------------------------------------------
; Procedure to get user number input
; receives: n/a
; returns: Modifies num_primes_toDisplay
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
getUserNumberInputArray PROC
	pushad
	mov 	ebp, esp
	mov 	ecx, [ebp+40] ; Save number of elements in the array
	mov 	esi, [ebp+36] ; Save the address of the array

	StartUserNumInput:
		; DESIGN NOTE: I decided to pass in values from the .data segment
		;   		   into the readVal method directly because. The 
		;			   getUserNumberInputArray method is only supposed to
		;  			   test readVal. It would be unwieldly to have to pass 
		; 			   in 7 parameters. 

		; Get number from user
		push 	OFFSET input_msg ; Param: input message
		push 	OFFSET retry_input_msg ; Param: retry input message
		push 	OFFSET invalid_input_msg ; Param: invalid input message
		push 	input_length ; Param: the input array length
		push 	input_type_size	; Param: the input array element size
		push	OFFSET input_before_validate ; Param: the address to the source array 
		push	OFFSET input_after_validate ; Param: the address to the destination array 
		push	OFFSET integer_result ; Param; the address to the final integer result
		call	readVal

		; Save 10 unsigned int into the passed in array
		mov 	ebx, integer_result
		mov 	[esi], ebx
		add 	esi, 4

		; Clear the result variable
		mov		eax, 0
		mov		integer_result, eax

		loop StartUserNumInput

		popad
		ret		8
getUserNumberInputArray ENDP

; ---------------------------------------------------------
; Procedure to get user string input and convert to a number
; receives: 5 Parameters on the system stack
;			Here is the list from the top of the stack to the bottom:
;			1. The offset to hold the final integer result.
;			2. The offset to hold the destination array. This array
;			   holds the result after number validation.
;			3. The offset to the the source array. This array holds
;			   the user entered string.
; 			4. The value that represents the size of each array element
;			   for both arrays passed in above.
;			5. The value that represents the number of elements in both
;			   the arrays passed in.
;			6. The offset to the invalid input message
;			7. The offset to the retry input message
;			8. The offset to the input message
; returns: Modifies num_primes_toDisplay
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
readVal PROC
	; Save registers
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esp
	push	esi
	push	edi
	push	ebp

	mov		ebp, esp
	sub 	esp, 8 ; Save space for 2 local variables. 

	; Save the length of string array in to a local variable
	mov		eax, [ebp+52]
	mov		DWORD PTR [ebp-8], eax ; Save to local var
 	mov		eax, 0 ; Clear eax

	getString [ebp+64], [ebp+44] ; Get user string
	jmp		beginNormalRead

	; Error handling section:
	invalidNumEnteredAskUserAgain:
		; Reset all registers that will be used
		mov 	ecx, 0
		mov		edx, 0
		mov		eax, 0
		mov		ebx, 0

		; Make a call to clear source array
		push 	[ebp+48] ; Size of each element
		push 	[ebp-8] ; Number elements in the source array
		push 	[ebp+44] ; The source array address
		call 	clearAllElementsInArray ; Clear source array
		
		; Make a call to clear destination array
		push 	[ebp+48] ; Size of each element
		push 	[ebp-8] ; Number elements in the destination array
		push 	[ebp+40] ; The destination array address
		call 	clearAllElementsInArray ; Clear destination array

		; Display error message and ask for the string again
		displayString [ebp+56] ; Display error message
		call	CrLf
		getString [ebp+60], [ebp+44]  ; Ask for user input again

	; Normal workflow section
	beginNormalRead:
	 	mov 	esi, [ebp+44] ; source before validation
	 	mov 	edi, [ebp+40] ; destination after validation 
	 	mov 	ecx, [ebp+52] ; Keep track of how many elements to loop through
	 	mov 	edx, 0 ; Clear edx, so it can keep track of how many digits added

	; Validate each string number in the source array
 	cld
 	readValLoop: LODSB ; Moves byte at [esi] into the AL 

		; Stop loading if we hit a null terminating character, 0
		cmp		al, 0
		je		readValLoopDone ; If we hit a null character, then exit loop

 		; Check to see if character entered is valid
		sub 	al, 48 ; Subtract the ascii byte by 48 to get the integer
		cmp		al, 0 ; Compare integer entered to 0
		jl		invalidNumEnteredAskUserAgain ; If AL is less then 0, then it is not a valid number, ask user to enter number again
		cmp		al, 9 ; Compare integer entered to 0
		jg		invalidNumEnteredAskUserAgain ; If AL is greater then 9, then it is not a valid number, ask user to enter number again

		; Digit conversion was successful
		inc 	edx ; Increment edx to keep track of how many digits were added
		STOSB ; Moves byte in the AL register to memory at [edi]

 		loop 	readValLoop ; Read next digit in string array

 	readValLoopDone:
 		cmp 	edx, 0
 		je 		invalidNumEnteredAskUserAgain ; If loop is done but no digits were added then there is an error

 		; Reading string value is successful, do cleanup of ecx
		mov 	ecx, 0

	; Convert string array into an interger:
	; NOTE: This the conversion algorithm for converting a string array 
	;       holding digits into an integer. For example, a string array
	;		that holds <"1", "2", "3"> will be converted to 123, which
	;		is an integer. 
	;			1. Store number of elements to convert into a variable
	;			2. Starting at element position 0 of the string array
	;			   to the last element position. 
	;				2a. Multiply element by (10 ^ (numberOfElementsToConvert - 1))
	;				2b. Add element to integer result variable
	;				2c. Decrement numberOfElementsToConvert
	dec 	edx ; Decrement number of elements to convert by 1
	mov		DWORD PTR [ebp-4], edx; save edx or number of elements into a local variable
	mov 	esi, [ebp+40] ; esi holds the string array
	mov 	edi, [ebp+36] ; edi holds the integer result variable 
	mov		eax, 0 ; clear eax, so we can load a number into it
	cld
	convertStringIntArrayToInt: LODSB
		mov 	ebx, 10 ; Multiplication factor	
		mov 	ecx, edx ; Set ecx to the exponent of 10 

		mov		DWORD PTR [ebp-4], edx; save edx or number of elements into a local variable

		; Exit if on the ones digit
		cmp		ecx, 0
		je		storeNewDigit ; If we are on the ones digit, then go to the save section

		multiplyByTen:
			mul 	ebx ; Multiply the current digit by its 10's decimal place
			jo		invalidNumEnteredAskUserAgain ; Jump to error section if overflow occurred
			loop 	multiplyByTen

		storeNewDigit:

			mov		ebx, [edi]
			add		eax, ebx
			mov		[edi], eax

			jc		invalidNumEnteredAskUserAgain ; Jump to error section if overflow occurred

			mov 	edx, [ebp-4] ; restore the Number of elements to convert

			; If saved the last digit, exit the routine
			cmp		edx, 0 
			je		exitReadVal

			dec		edx ; decrement the Number of elements to convert
			mov		eax, 0 ; Clear eax 
			loop 	convertStringIntArrayToInt

	exitReadVal:

	; Restore registers
	mov		esp, ebp 
	pop 	ebp
	pop	 	edi
	pop 	esi
	pop 	esp
	pop 	edx
	pop 	ecx
	pop 	ebx
	pop 	eax
	ret 32 
readVal ENDP

; ---------------------------------------------------------
; Procedure clears array by filling it with null terminating characters. 
; receives: 3 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is number of elements
;			in the array. The third parameter is the type size of the element.
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
clearAllElementsInArray PROC
	pushad
	mov 	ebp, esp
	mov 	esi, [ebp+36]; Get offset of the array
	mov 	ecx, [ebp+40] ; Get the number of elements in the array
	mov 	ebx, [ebp+44] ; Get the size of each array element
	mov 	eax, 0 ; Null terminating character to put into each element position

	; Protect against ecx = 0
	cmp		ecx, 0
	jle		endArrayClearLoop

	startArrayClearLoop:
		mov 	[esi], eax ; Replace current element with zero
		add 	esi, ebx ; Increment to next element
		loop 	startArrayClearLoop 

	endArrayClearLoop:

	popad
	ret 12 
clearAllElementsInArray ENDP 

; ---------------------------------------------------------
; Procedure displays the given array
; receives: 2 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is number of elements
;			in the array
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
displayArray PROC
	pushad

	mov 	ebp, esp
	mov 	ecx, [ebp+40] ; Save number of elements in the array for looping
	mov 	esi, [ebp+36] ; Save the address of the array

	displayNextElement:

	;	mov 	eax, [esi]
	;	call 	writedec ; Write out the current element
		;push 	OFFSET recursive_val_holder ; Param: Address to hold the recursive value 
		push 	OFFSET recursive_val_holder ; Param: Address to hold the recursive value 
		push 	[esi] ; Param: the int to display
		call 	writeVal ; Output the numerical value

		add 	esi, 4 ; Increment to next element

		; Check if we are at the last element to Display
		;	If we are at the last element, then do not add a delimiter at the end
		mov 	ebx, 1
		cmp 	ebx, ecx
		je 		skipLastDelimiterAdd ; If we are at the last element, skip to the end

		mov		edx, OFFSET array_display_delimiter 
		call 	writestring ; Add three spaces after the displayed number

	skipLastDelimiterAdd:
		loop 	displayNextElement

		call	CrLf
		call	CrLf

	popad
	ret 8
displayArray ENDP

; ---------------------------------------------------------
; Procedure displays the given integer
; receives: 1 parameter on the stack. The topmost parameter is 
;			the integer
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
writeVal PROC
	pushad
	mov 	ebp, esp

	mov 	eax, [ebp+36] ; Get the int value
	mov 	ebx, 10 ; Save the divisor


	; example 123 -- 
	; need to get first digit, then second digit, then third digit
	; divide eax / ebx
	;If eax == 0
	;{
	;	write edx
	;	return
	;}
	;else
	;{
	;	push 	eax ; Param: the int to display 
	;	call 	writeVal
	;	write 	edx
	;}
	cdq
	div 	ebx
	cmp 	eax, 0
	jne 	recurseDeeper
	jmp		endRecurse

	recurseDeeper:
		push	[ebp+40]
		push 	eax
		call 	writeVal
	endRecurse:
		add		dl, 48 ; Add 48 to get the ascii integer value
		mov		edi, [ebp+40] 
		mov 	[edi], dl ; Save integer character to destination address
		displayString [ebp+40]	
	popad
	ret 8 
writeVal ENDP 

; ---------------------------------------------------------
; Procedure Displays the median number of a sorted array.
; receives: 2 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is number of elements
;			in the array
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
DisplayMedian PROC
	pushad

	mov 	ebp, esp
	mov 	ecx, [ebp+40] ; Save number of elements in the array
	mov 	esi, [ebp+36] ; Save the address of the array

	; Display the median message
	mov 	edx, OFFSET median_display_msg
	call 	writestring ; Displays the median message

	; Display the left parenthesis
	mov		edx, OFFSET left_paren_display
	call 	writestring	; Displays "("

	; if odd number of elements find the middle number
	mov		eax, ecx ; move the number of elements in the array into eax
	cdq
	mov		ebx, 2
	div 	ebx
	cmp 	edx, 1
	je 		DisplayMedOddArray ; If edx is 1, then that means there is an odd number elements in the array.
							   ; This means we should display the middle number

	; if an even number of elements, display the average of the two middle numbers
	push 	eax ; push the position of the middle number onto the stack
	push 	esi ; push array address onto the stack
	call 	DisplayMedianOfEvenArray
	jmp 	ExitDisplayMedian

	DisplayMedOddArray:
		push 	eax ; push the position of the right middle number onto the stack
		push 	esi ; push array address onto the stack
		call 	DisplayMedianOfOddArray



	ExitDisplayMedian:
		; Display the right parenthesis
		mov		edx, OFFSET right_paren_display
		call 	writestring ; Displays ")"

		mov 	edx, OFFSET period_msg
		call 	writestring ; Displays the period at the end of the message

	call CrLf
	call CrLf
	popad
	ret 8
DisplayMedian ENDP

; ---------------------------------------------------------
; Procedure Displays the average of the two numbers in the middle of an even array. (the median)
; receives: 2 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is the position of the median
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
DisplayMedianOfEvenArray PROC
	pushad

	mov 	ebp,esp
	mov 	ecx, [ebp+40] ; save position of right middle number of array into ecx
	mov 	esi, [ebp+36] ; save sorted array address

	; Put the left middle position into ebx
	mov 	ebx, ecx
	dec 	ebx

	; Get the value at the position of the right middle number
	mov 	eax, TYPE esi
	mul 	ecx ; multiply size of the elements by the element position to get the real offset of the right middle number
	mov 	ecx, [esi+eax] ; Get the right middle number and put into ecx

	; Get the value at the position of the left middle number
	mov 	eax, TYPE esi
	mul 	ebx ; multiply size of the elements by the element position to get the real offset of the left middle number
	mov 	eax, [esi+eax] ; Get the left middle number and put into edx

	; Find the average of the two middle numbers
	add 	eax, ecx ; add the two middle numbers and store in eax
	mov 	ebx, 2
	cdq
	div 	ebx ; divide eax by ebx. eax now contains the approx average
	cmp 	edx, 1
	je 		DisplayAverageWithDecimal ; This means we need to display a ".5" after the average because the average is not a whole number
	call 	writedec ; else we can just display eax because it is a whole number
	jmp 	ExitDisplayMedEvenArray

	DisplayAverageWithDecimal:
		call 	writedec ; Display the whole number
		mov 	edx, OFFSET half_num_string ; Display the half number to complete the median
		call 	writestring

	ExitDisplayMedEvenArray:

	popad
	ret 8
DisplayMedianOfEvenArray ENDP

; ---------------------------------------------------------
; Procedure Displays the number at the center of an odd array. (the median)
; receives: 2 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is the position of the median
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
DisplayMedianOfOddArray PROC
	pushad

	mov 	ebp,esp
	mov 	ecx, [ebp+40] ; save position of middle number of array into ecx
	mov 	esi, [ebp+36] ; save sorted array address

	mov 	eax, TYPE esi
	mul 	ecx ; multiply size of the elements by the element position to get the real offset of the median
	mov 	eax, [esi+eax] ; Get the median
	call	writedec ; display the median

	popad
	ret 8
DisplayMedianOfOddArray ENDP

; ---------------------------------------------------------
; Procedure outputs the end of program messages
; receives: A param on the system stack. The top param is the 
;			exit message 
; returns: n/a
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
farewell PROC
	pushad
	mov 	ebp, esp
	; Outputs the exit messages
	call	CrLf
	call	CrLf
	displayString [ebp+36] 
	call	CrLf

	popad
	ret 4
farewell ENDP
END main
