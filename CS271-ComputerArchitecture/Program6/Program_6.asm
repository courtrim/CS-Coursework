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

; Constant Definitions
MAX_NUM_TOGENERATE = 200 ; Represents max amount of numbers to generate
MIN_NUM_TOGENERATE = 10 ; Represents min amount of numbers to generate
RAN_LOWER_LIMIT = 100 ; Represents the random number lower limit
RAN_UPPER_LIMIT = 999 ; Represents the random number upper limit

; MACRO Definitions
displayString MACRO displayStringAddr
	push 	edx
	mov 	edx, OFFSET displayStringAddr
	call 	writestring
	call		CrLf
	pop 	edx
endm

.data
intro_1					BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0
intro_2					BYTE	"Written by: Kevin To", 0
instruct_msg1			BYTE	"Please provide 10 unsigned decimal integers.", 0
instruct_msg2			BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instruct_msg3			BYTE	"After you have finished inputting the raw numbers I will display a list", 0
instruct_msg4			BYTE	"of the integers, their sum, and their average value.", 0
input_msg				BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
err_OverLimit_msg		BYTE	"Out of Range. Try again.", 0
three_spaces 			BYTE 	"   ", 0 ; Contains a string with three spaces
unsort_display_msg		BYTE	"The unsorted random numbers:", 0
sorted_display_msg		BYTE	"The sorted list:", 0
median_display_msg		BYTE	"The median is ", 0
period_msg				BYTE	".", 0
half_num_string			BYTE	".5", 0
right_paren_display		BYTE	")", 0
left_paren_display		BYTE	"(", 0
exit_msg				BYTE	"Thanks for playing!", 0

num_to_generate			DWORD	10
unsorted_array			DWORD	MAX_NUM_TOGENERATE DUP(0)

.code
main PROC
	; ------------Program Introduction Section----------
	call	introduceProgram
	call	displayInstructions

	; ------------Get User Data Section-----------------
	;push	OFFSET num_to_generate
	;call	getUserNumberInput

	; ------------Fill Array section--------------------
	;push 	num_to_generate
	;push 	OFFSET unsorted_array
	;call 	fillArray ; Fill array with random values

	;call	DisplayUnsortedArrayMsg ; Display unsorted array msg
	;push	num_to_generate
	;push 	OFFSET unsorted_array
	;call 	displayArray ; Display the unsorted array

	; ------------Sort Array section--------------------
	;push	num_to_generate
	;push 	OFFSET unsorted_array
	;call	sortArray ; Sort the unsorted array in descending order

	; ------------Calculate and Display Median section--------------------
	; Note: Displaying the median requires that the array be sorted first.
	;push	num_to_generate
	;push 	OFFSET unsorted_array
	;call DisplayMedian

	; ------------Display Sorted Array section--------------------
	;call	DisplaySortedArrayMsg ; Display sorted array msg
	;push	num_to_generate
	;push 	OFFSET unsorted_array
	;call 	displayArray ; Display the sorted array

	; ------------Farwell Section-----------------------
	call	farewell

	exit	; exit to operating system
main ENDP

; ---------------------------------------------------------
; Procedure to display program title and
; programmer's name.
; receives: intro_1 as a global string variable
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
introduceProgram PROC
	; Display title
	displayString intro_1

	; Display programmer name
	displayString intro_2

	ret
introduceProgram ENDP

; ---------------------------------------------------------
; Procedure to display program instructions
; receives: instruct_msg1, instruct_msg2, and instruct_msg3
;		     as the program instructions
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
displayInstructions PROC
	; Display program instructions
	call	CrLf
	displayString instruct_msg1
	displayString instruct_msg2
	displayString instruct_msg3
	displayString instruct_msg4
	call	CrLf
	call	CrLf

	ret
displayInstructions ENDP

; ---------------------------------------------------------
; Procedure to get user number input
; receives: n/a
; returns: Modifies num_primes_toDisplay
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
getUserNumberInput PROC
	pushad
	mov		ebp, esp

	StartUserNumInput:
		; Get number from user
		mov		edx, OFFSET input_msg
		call	WriteString	; Asks user to input a number
		call	ReadInt ; Gets user integer input

		mov 	ecx, 0 ; validateUserNumberInput will return a value in ecx. So need to clear it now.
		call	validateUserNumberInput

		cmp		ecx, 1
		je		StartUserNumInput ; if ecx is 1, then restart
		mov		ebx, [ebp+36] ; @num_to_generate in ebx
		mov		[ebx], eax ; Save amount of random numbers to generate
		call	CrLf

		popad
		ret		4
getUserNumberInput ENDP

; ---------------------------------------------------------
; Procedure to validate user number input
; receives: eax containing the number to be validated
; returns: Modifies ecx. ecx is
;		   set to 0 if the number is valid. ecx is set to
;		   1 if the number is invalid
; preconditions: eax contains number to be validated
; registers changed: ecx
; ---------------------------------------------------------
validateUserNumberInput PROC USES eax edx
		cmp		eax, MAX_NUM_TOGENERATE
		jle		checkIfNegativeOrZero ; If number is less than max number check if it is negative or zero
		jg		displayError ; Otherwise, number is over max

	checkIfNegativeOrZero:
		cmp		eax, MIN_NUM_TOGENERATE
		jl		displayError ; If number is less than 1, display out of range error message
		mov		ecx, 0 ; Number entered was valid.
		jmp		endValidate

	displayError:
		; User entered number outside of range, let them retry
		mov		edx, OFFSET err_OverLimit_msg
		call	WriteString ; Display outside of range error message
		call	CrLf
		mov		ecx, 1 ; Number entered was invalid

	endValidate:
		ret
validateUserNumberInput ENDP

; ---------------------------------------------------------
; Procedure to display the beginning msg for the unsorted array
; receives: unsort_display_msg as the display message
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
DisplayUnsortedArrayMsg PROC USES edx
	mov 	edx, OFFSET unsort_display_msg
	call 	writestring ; Displays the unsorted array message
	call 	CrLf
	ret
DisplayUnsortedArrayMsg ENDP

; ---------------------------------------------------------
; Procedure fills an array with random numbers
; receives: 2 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is number of elements
;			in the array
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
fillArray PROC
	pushad

	mov 	ebp, esp
	mov 	ecx, [ebp+40] ; Save number of elements in the array
	mov 	esi, [ebp+36] ; Save the address of the array

	; NOTE: This sequence to generate a random number based on a range calculation
	;		of (hi limit - lo limit + 1) was taken from the lecture 20 exercise.
	call Randomize

	mov		eax, RAN_UPPER_LIMIT ; Put random number upper limit into eax
	sub 	eax, RAN_LOWER_LIMIT ; Subtract lower limit by upper limit
	inc 	eax ; Increment eax to get range

	repeatFillArray:
		call 	RandomRange
		add 	eax, RAN_LOWER_LIMIT ; Add random number by lower limit to get final random number

		mov 	[esi], eax
		add 	esi, 4
		loop 	repeatFillArray

	popad
	ret 8
fillArray ENDP

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
	mov 	ecx, [ebp+40] ; Save number of elements in the array
	mov 	esi, [ebp+36] ; Save the address of the array
	mov 	ebx, 0 ; Keep track of how many elements we are displaying

	displayNextElement:

		mov 	eax, [esi]
		call 	writedec ; Write out the current element
		add 	esi, 4

		mov		edx, OFFSET three_spaces
		call 	writestring ; Add three spaces after the displayed number

		; Go to new line if there is 10 elements on the current line
		inc 	ebx
		push 	ebx
		call 	AppendNewLine ;
		loop 	displayNextElement

		call	CrLf
		call	CrLf
	popad
	ret 8
displayArray ENDP

; ---------------------------------------------------------
; Procedure starts a new line if there are
; 10 prime numbers in the current output window line
; receives: 1 parameter in the system stack. This param
; 			is the current number of elements on display
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
AppendNewLine PROC
	pushad
	mov 	ebp, esp
	mov 	eax, [ebp+36] ; Saves current number of elements being displayed.
	mov 	ecx, 10
	cdq
	div 	ecx ; Divide number of elements displayed found by 10. If number is divisible by then new line will be added.

	cmp 	edx, 0
	jne		exitAppendNewLine ; No new line is added. There is not 10 elements in the current line.

	call 	CrLf ; Start a new line

	exitAppendNewLine:
	popad
	ret 4
AppendNewLine ENDP

; ---------------------------------------------------------
; Procedure to display the beginning msg for the sorted array
; receives: sort_display_msg as the display message
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
DisplaySortedArrayMsg PROC USES edx
	mov 	edx, OFFSET sorted_display_msg
	call 	writestring ; Displays the unsorted array message
	call 	CrLf
	ret
DisplaySortedArrayMsg ENDP

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
; Procedure to sort an array in descending order
; receives: 2 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is number of elements
;			in the array
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
sortArray PROC
	pushad

	mov 	ebp, esp
	mov 	ebx, [ebp+40] ; Save number of elements in the array
	mov 	esi, [ebp+36] ; Save the address of the array

	; Note: This function will implement the following selection sort
	;		algorithm. This algorithm was found on the assignment
	;		description.
	;for(k=0; k<request-1; k++) {
	;	i = k;
	;	for(j=k+1; j<request; j++) {
	;		if(array[j] > array[i])
	;			i = j;
	;	}
	;	swap(array[k], array[i]);
	;}

	mov 	edx, 0 ; Clear reg keeping track of outer loop
	dec 	ebx ; Decrement ebx to follow selection sort outer loop limit
	sortArrayOuterLoop:
		; The following function will perform the work inside the outer loop.
		push 	edx ; Save the current element position as a parameter
		push 	ebx ; Save the number of elements in the array as a parameter
		push 	esi ; Save the address of the array as a parameter
		call 	SwapWithHighestValueInArray; Swap the current element with
		;									 the highest element in the rest
		;									 of the array

		inc 	edx ; Increase outer loop counter
		cmp 	edx, ebx
		jl 		sortArrayOuterLoop ; If edx is less than ebx, continue the
		;							 loop until the end of the array

	popad
	ret 8
sortArray ENDP

; ---------------------------------------------------------
; Procedure to swap the current element in an array with the highest element
; in the rest of the array
; receives: 3 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is number of elements
;			in the array. The third parameter is the current element position.
; returns: nothing
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
SwapWithHighestValueInArray PROC
	; Save the stack
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esp
	push	esi
	push	edi
	push	ebp

	; Get the parameters and setup local variables
	mov 	ebp, esp
	sub 	esp, 16 ; Save space for 3 local variables
	mov 	esi, [ebp+36] ; Save the address of the array
	mov 	ebx, [ebp+40] ; Save number of elements in the array - 1
	inc 	ebx ; Increment ebx to get number of elements in the array = request
	mov 	edx, [ebp+44] ; Save calling proc array index = k
	mov		DWORD PTR [ebp-16], edx; save edx or k into a local variable
	mov 	edi, edx ; this var is for i

	; Note: This is the code that we are implementing. It is the contents
	;		within the outer loop of the selection sort algorithm.
	;	i = k
	;	for(j=k+1; j<request; j++) {
	;		if(array[j] > array[i])
	;			i = j;
	;	}
	;	swap(array[k], array[i]);

	mov		eax, edx ; save edx, so we can generate j
	findBiggestIntLoopStart:
		inc 	eax ; Gives the j value

		; Check if loop is still valid
		cmp		eax, ebx
		jge		FindBigLoopEnd ; If we are outside the bounds of the array, exit

		; This section will populate the local variables to hold the
		; j and i indexes accounting for the double word array size.
		mov 	DWORD PTR [ebp-4], eax ; local variable to hold (j * 4)
		mov 	DWORD PTR [ebp-8], edi ; local variable to hold (i * 4)
		mov 	DWORD PTR [ebp-12], eax ; local variable to hold eax

		; Calculate j-index with array doubleword offset
		mov 	eax, [ebp-4]
		mov 	ecx, 4
		mul 	ecx ; Multiply eax by ecx
		mov 	DWORD PTR [ebp-4], eax ; Save j index with offset as a local variable

		; Calculate i-index with array doubleword offset
		mov 	eax, [ebp-8]
		mov 	ecx, 4
		mul 	ecx ; Multiply eax by ecx
		mov 	DWORD PTR [ebp-8], eax ; Save i index with offset as a local variable

		; Section for the if statement comparing array[j] to array[i]
		mov 	eax, [ebp-4] ; Get real index of j
		mov 	ecx, [esi+eax] ; Store value at index j in ecx
		mov 	eax, [ebp-8] ; Get real index of i
		cmp		ecx, [esi+eax] ; Compare array[j] with array[i]
		jle 	continueFindBigLoop ; If array[j] <= array[i], then we restart the loop
		mov		eax, [ebp-12] ; restore eax to original value at beginning of loop
		mov 	edi, eax ; array[j] is greater than array[i], so i = j now.

		; loop re-run condition
		continueFindBigLoop:
		mov		eax, [ebp-12] ; restore eax to original value at beginning of loop
		cmp		eax, ebx
		jl 		findBiggestIntLoopStart ; If we are still within the bounds of the array, continue looping

	FindBigLoopEnd:
		; Loop is done now perform swap
		mov		edx, [ebp-16]; restore edx from a local variable. edx represents k
		push	esi ; Saves array address as a parameter
		push 	edx	; Saves swap index 1 as a parameter
		push 	edi	; Saves swap index 2 as a parameter
		call	swapNumbers

	; Clean up local vars and restore the system stack
	mov		esp, ebp
	pop 	ebp
	pop	 	edi
	pop 	esi
	pop 	esp
	pop 	edx
	pop 	ecx
	pop 	ebx
	pop 	eax
	ret		12
SwapWithHighestValueInArray ENDP

; ---------------------------------------------------------
; Procedure that swaps array values
; receives: 3 parameters on the stack. The topmost parameter is address
;			of the array. The second parameter is the first swap position.
;			The third parameter is the second swap position.
; returns: n/a
; preconditions: parameters must be in the stack
; registers changed: n/a
; ---------------------------------------------------------
swapNumbers PROC
	push 	eax
	push 	ebx
	push 	ecx
	push 	esi
	push	ebp
	mov		ebp, esp
	sub		esp, 4 ; Create space for a local variable to hold a temp value

	mov 	esi, [ebp+32] ; Get array address

	; Save array value at first position to temp variable
	mov 	eax, [ebp+28] ; Get the first index for swapping
	mov 	ebx, 4
	mul		ebx; Multiply index (in eax) by 4 to directly access array element
	mov 	ebx, [esi+eax]
	mov 	DWORD PTR [ebp-4], ebx ; save swap element at first position to temp variable

	; Switch value at first position for value at second position
	mov 	eax, [ebp+24] ; Get the second index for swapping
	mov 	ebx, 4
	mul		ebx ; Multiply index (in eax) by 4 to directly access array element
	mov 	ecx, [esi+eax] ; ecx contains the value at the second position
	mov 	eax, [ebp+28] ; Get the first index for swapping
	mul		ebx; Multiply index (in eax) by 4 to directly access array element
	mov 	[esi+eax], ecx ; Put value at the second position into the first position

	; Switch value at second position with temp value
	mov 	eax, [ebp+24] ; Get the second index for swapping
	mov 	ebx, 4
	mul		ebx ; Multiply index (in eax) by 4 to directly access array element
	mov 	ecx, [ebp-4]
	mov 	[esi+eax], ecx ; Put temp value into second position

	; Clean up system stack
	mov		esp, ebp ; Clean up local vars
	pop		ebp
	pop 	esi
	pop 	ecx
	pop		ebx
	pop 	eax
	ret 	12  ; we need to return the space of a params
swapNumbers ENDP

; ---------------------------------------------------------
; Procedure outputs the end of program messages
; receives: Uses exit_msg
; returns: n/a
; preconditions: n/a
; registers changed: n/a
; ---------------------------------------------------------
farewell PROC

	; Outputs the exit messages
	call	CrLf
	call	CrLf
	displayString exit_msg
	call	CrLf

	ret
farewell ENDP
END main
