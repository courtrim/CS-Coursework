TITLE Program_6a     (Program_6a.asm)

; Author: Kevin To
; Course / Project ID: CS271/Program_6a                 Date: 12/04/2014
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
exit_msg				BYTE	"Thanks for playing!", 0
invalid_input_msg		BYTE	"ERROR: You did not enter an unsigned number or your number was too big.", 0
sum_arr_msg				BYTE	"The sum of these numbers is: ", 0
avg_arr_msg				BYTE	"The average is: ", 0

unsorted_array			DWORD	NUM_OF_INPUTS DUP(0)
input_before_validate	BYTE 	MAX_STRING_INPUT+1 DUP(?) ; Variable to hold user input before validation
input_after_validate	BYTE 	MAX_STRING_INPUT+1 DUP(?) ; Variable to hold user input after validation
input_length			DWORD	LENGTHOF input_before_validate
input_type_size			DWORD	TYPE input_before_validate
integer_result			DWORD	0 ; Holds the integer value after conversion from a string
recursive_val_holder	BYTE 	2 DUP(?) ; Variable to hold the single character to be displayed
sum_unsorted_array		DWORD 	0 ; Holds the sum of all the integers in an integer array

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
	push	OFFSET integer_result ; Parameter that holds the the address to the final integer result
	push	OFFSET input_after_validate ; Parameter that holds the the address to the destination array 
	push	OFFSET input_before_validate ; Parameter that holds the the address to the source array 
	push	input_type_size ; Parameter that holds the the input array element size
	push	input_length ; Parameter that holds the the input array length
	push	OFFSET invalid_input_msg ; Parameter that holds the invalid input message
	push	OFFSET retry_input_msg ; Parameter that holds the retry input message
	push	OFFSET input_msg ; Parameter that holds the input message
	push	NUM_OF_INPUTS ; Parameter that holds the number of elements allowed to be entered into the result array
	push 	OFFSET unsorted_array ; Parameter that holds the array to fill with user entered integers
	call	getUserNumberInputArray

	; ------------Display Array section--------------------
	call 	CrLf
	displayString OFFSET array_display_msg ; Display "show array" starting message
	call 	CrLf

	push	OFFSET recursive_val_holder ; Parameter that holds the address of the string array used for display
	push	NUM_OF_INPUTS; Parameter that holds the constant for number of inputs
	push 	OFFSET unsorted_array; Parameter that holds the address of the array holding all the user entered variables
	call 	displayArray ; Display the sorted array

	; ------------Calculate and Display Sum of Int Array section--------------------
	push	OFFSET sum_arr_msg ; Parameter that holds the address of the sum output message
	push	OFFSET recursive_val_holder ; Parameter that holds the address of the string array used for display
	push	OFFSET sum_unsorted_array; Parameter that holds the address to the sum of the integer array
	push	NUM_OF_INPUTS; Parameter that holds the constant for number of inputs
	push 	OFFSET unsorted_array; Parameter that holds the address of the array holding all the user entered variables
	call 	displayArraySum ; Display the sorted array

	; ------------Calculate and Display Average of Int Array section--------------------
	push	OFFSET avg_arr_msg ; Parameter that holds the address of the sum output message
	push	OFFSET recursive_val_holder ; Parameter that holds the address of the string array used for display
	push	sum_unsorted_array; Parameter that holds the sum of the integer array
	push	NUM_OF_INPUTS; Parameter that holds the constant for number of inputs
	call 	displayArrayAverage ; Display the sorted array

	; ------------Farwell Section-----------------------
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
; receives: 10 Parameters on the system stack
;			Here is the list from the top of the stack to the bottom:
;			1. Address of the array populate with user values 
;			2. The number of elements in the array to displayed
;			3. The offset to the input message
;			4. The offset to the retry input message
;			5. The offset to the invalid input message
;			6. The value that represents the number of elements in both
;			   the arrays passed in.
; 			7. The value that represents the size of each array element
;			   for both arrays passed in above.
;			8. The offset to the the source array. This array holds
;			   the user entered string.
;			9. The offset to hold the destination array. This array
;			   holds the result after number validation.
;			10. The offset to hold the final integer result.
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
		; Get number from user
		push 	[ebp+44] ; Param: input message
		push 	[ebp+48] ; Param: retry input message
		push 	[ebp+52] ; Param: invalid input message
		push 	[ebp+56] ; Param: the input array length
		push 	[ebp+60] ; Param: the input array element size
		push	[ebp+64] ; Param: the address to the source array 
		push	[ebp+68] ; Param: the address to the destination array 
		push	[ebp+72] ; Param: the address to the final integer result
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
		ret	40	
getUserNumberInputArray ENDP

; ---------------------------------------------------------
; Procedure to get user string input and convert to a number
; receives: 8 Parameters on the system stack
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
; returns: The final value is stored in the second parameter above.
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
; receives: 3 Parameters on the system stack
;			Here is the list from the top of the stack to the bottom:
;			1. Address of the array to clear
;			2. The number of elements in the array to display
;			3. The type size of the element
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

	; Loop to clear all elements in the array
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
; receives: 3 Parameters on the system stack
;			Here is the list from the top of the stack to the bottom:
;			1. Address of the array to display
;			2. The number of elements in the array to display
;			3. Address of the string array used for display 
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

		push 	[ebp+44] ; Param: Address to hold the recursive value 
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
		loop 	displayNextElement ; Restart loop to display another element if ecx is not 0

		call	CrLf

	popad
	ret 12
displayArray ENDP

; ---------------------------------------------------------
; Procedure displays the given integer
; receives: 2 Parameters on the system stack
;			Here is the list from the top of the stack to the bottom:
;			1. The int value to display
;			2. The offset to the string array that will be used as a 
;			   vehicle to display a string value.
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; Note: This is a recursive procedure.
; ---------------------------------------------------------
writeVal PROC
	pushad
	mov 	ebp, esp

	mov 	eax, [ebp+36] ; Get the int value
	mov 	ebx, 10 ; Save the divisor

	; --- Recursive Definition --- 
	; Base Case: 
	;	If quotient of ((passed in number) / 10) == 0
	;		Execute displayString on the remainder
	;		return from procedure call
	; Recursive Case:
	;	If base case is false
	;		call writeVal with the (integer / 10)

	cdq		; Clear edx, which will be used for division
	div 	ebx ; Divide eax by ebx
	cmp 	eax, 0 ; Check if we hit the base case
	jne 	recurseDeeper ; If not base case, go to the recursive section
	jmp		endRecurse ; This is the base case, go to the base case section

	recurseDeeper:
		; This is the recursive case
		push	[ebp+40] ; Param: the one character string array used for display
		push 	eax ; Param: the integer that we want to recurse on in order to display
		call 	writeVal ; Do a recursive call
	endRecurse:
		; This is the base case
		add		dl, 48 ; Add 48 to get the ascii integer value
		mov		edi, [ebp+40] ; Save the string array into edi
		mov 	[edi], dl ; Save integer character to destination address
		displayString [ebp+40] ; Call the macro to display the string

	popad
	ret 8 
writeVal ENDP 

; ---------------------------------------------------------
; Procedure displays the sum of all the elements in a given integer array
; receives: 5 Parameters on the system stack
;			Here is the list from the top of the stack to the bottom:
;			1. The address of the array to find the sum of
;			2. The number of elements in the array
;			3. The address of where to put the final sum result
;			4. The address to hold the string array for display
;			5. The address of the output message to display
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; Note: This is a recursive procedure.
; ---------------------------------------------------------
displayArraySum PROC
	pushad

	; Initialize registers
	mov 	ebp, esp
	mov 	eax, 0 ; Clear eax
	mov 	ecx, [ebp+40] ; Save number of elements in the array for looping
	mov 	esi, [ebp+36] ; Save the address of the array
	mov 	edi, [ebp+44] ; Save the address of the sum result

	displayNextElement:

		add 	eax, [esi] ; Add value at integer array to value in eax
		add 	esi, 4 ; Increment to next element
		loop 	displayNextElement ; Restart loop to add next integer element
		mov 	[edi], eax ; Save final sum into sum destination 

	; Display the output message
	displayString [ebp+52]

	; Display the sum
	push 	[ebp+48] ; Param: Address to hold the recursive value 
	push 	[edi] ; Param: the int to display
	call 	writeVal ; Output the numerical value
	call	CrLf

	popad
	ret 20 
displayArraySum ENDP 

; ---------------------------------------------------------
; Procedure displays the average of all the elements in a given integer array. 
; Note: The average is rounded down.
; receives: 4 Parameters on the system stack
;			Here is the list from the top of the stack to the bottom:
;			1. The number of elements in the array
;			2. The final sum result
;			3. The address to hold the string array for display
;			4. The address of the output message to display
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; Note: This is a recursive procedure.
; ---------------------------------------------------------
displayArrayAverage PROC
	pushad

	; Initialize registers
	mov 	ebp, esp
	mov 	eax, 0 ; Clear eax
	mov 	ebx, [ebp+36] ; Get the divisor
	mov 	eax, [ebp+40] ; Get the dividend

	cdq
	div 	ebx ; Divide eax by ebx

	; Display the average output message
	displayString [ebp+48]

	; Display the average number 
	push 	[ebp+44] ; Param: Address to hold the recursive value 
	push 	eax ; Param: the int to display
	call 	writeVal ; Output the numerical value
	call	CrLf

	popad
	ret 16
displayArrayAverage ENDP 

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
