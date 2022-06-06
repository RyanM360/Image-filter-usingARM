; Ryan mark
; mini project 3
				AREA mini3, CODE, READONLY
rows            EQU   16 ; amount of rows in image
collum          EQU   16	; amount of collums in  image
storage         EQU   0x40000000 ;adress of the unfiltered image
filter_image    EQU   0x40000100 ;the adres of the image that is going to be filtered
Histo1          EQU   0x40000200 ;stores data for the histogram of unfiltered image
Histo2          EQU   0x40000300 ; stores data for histogram of filtered image
intensity       EQU   0x40000400 ; store the the list inntenitys found in unfiltered image
filt_intensity 	EQU   0x40000500 ; store the list of intensity found in filtered immage
				
				ENTRY 
				MOV r2 ,#collum ;counter for columns
				MOV r3,#storage
Image           DCD row1,row2,row3,row4,row5,row6,row7,row8,row9,row10,row11,row12,row13,row14,row15,row16; array of all the rows
				ALIGN

				LDR r0,= Image  ;loads adress of the 2d image
			
;----------------------2d map to 1d-------------------------------------------------------------------				
ONE_D           LDR r4,[r0],#4
				MOV r1,#rows ; counter for elements with thin a row
ELEMENT         LDRB r5,[r4],#1
				STRB r5,[r3],#1
				SUBS r1,r1,#1; counter goes down
				BNE ELEMENT
				SUBS r2,r2,#1
				BNE ONE_D
;-----------------------1d to 2d map--------------------------------------------------------------------------	
				LDR r0,= filter_image;image that will be filtered later on
				MOV r2, #collum;total number of number in the 16x16 matrix		
				MOV r3,#storage	
				
				MOV r1,#256 ; counter for elements 
COPY            LDRB r4,[r3],#1; 
				STRB r4,[r0],#1; create duplitcae of input that will be later fileter as the output
				SUBS r1,r1,#1
				BNE COPY
;----------------------------------------------------histogram for unfiltered image---------------------------------------------------------				

				LDR r0,=Histo1; will contain data for 1st histogram
				MOV r1,#0 ; counter used to co mpare vaules in the image
				MOV r4,#256 ;hiogram loop counter
				LDR r7, =intensity
HISTO        	MOV r2, #0; counter for how many of what pixel intesity is in the  image in
				MOV r3, #256 ;total number of element in the 16x16 matrix
				LDR r5, =storage; get adress of the one dimensional array used to compare and also reset r5 so it can be used again
;----------------------------------------array number search----------------------	
search          LDRB r6,[r5],#1
				CMP  r6,r1 ; compare the value of the element to the number that is being searched for
				ADDEQ r2,r2,#1; add to counter if one of the element is equal to the number being compared too
				SUBS r3,r3,#1
				BNE search
;-----------------------------end of array number search loop----------------
				CMP  r2,#0 ;check if r2  has any number of a specific pixel intensity
				STRBNE r2 ,[r0],#1; stores counter of the number of a sepcific pixel intensity if couter is not zero
				CMP r2,#0
				STRBNE r1,[r7],#1 ; store the intensity that exists in the image
				ADD r1,r1,#1; set the next number that going to be searched and comapered with
				SUBS r4,r4,#1 ; histogram counter goes down
				BNE HISTO
;----------------------------------------------------------image filter--------------------------------------
				LDR r0, =Image ; the original image 
				LDR r1, =filter_image ;  the image that will be filtered
				ADD r1,r1,#17 ; goes to the adress row 2 colum 2 whul will be the first pixel filtered
				MOV r12,#14; counter for rows  when excluding row 1 and 16
 ;-------------------------------------------------------  image filter loop----------------------------------------
image_filter								
				LDR r3,[r0,#4];goes to row 2 by getttin the adress of row2 pre indexing used to not change r0
				LDR r4,[r0,#8];goes to row 3 by getttin the adress of row3 pre indexing used to not change r0
				LDR r2,[r0],#4 ; goes to row 1 by getttin the adress of row post indexing used to  change r0 by adding 4 to adress to shift the starting poiint down by 1 row for the next cycle
				                 
				MOV r13,#14 ; this will serve as the collum counter since we do not filter colum 1 or 16
; ----------------pixel calculation assuming 3x3 matrix use for caluculation------------------------------				
pixel_filter    MOV r9,#0; value for filter of a pixel
				LDRB r7,[r2,#1]; row 1 collumn 2 value
				LDRB r8,[r2,#2]; row 1 collum 3 value a 
				LDRB r6,[r2],#1; row 1 collum 1 value  also adds one to the adress so we go through all collums
				
				; we do not multiply (row1,collum1) since it being multiplied by one 
				MOV r7,r7,LSL #1; multiply (row1,collum 2) by 2
				; we do not multiply (row1,collum3) since it being multiplied by one 
				
				ADD r7 ,r6,r7;  (row1,collum1) + (row1,collum2)
				ADD r8,r7,r8   ; (row1,collum1) + (row1,collum2)+ (row1, collum3)
				ADD r9,r9,r8     ;0 +(row1,collum1) + (row1,collum2)+ (row1, collum3)
				
				LDRB r7,[r3,#1]; row 2 collumn 2 value
				LDRB r8,[r3,#2]; row 2 collum 3 value 
				LDRB r6,[r3],#1; row 2 collum 1 value  also adds one to the adress so we go through all collums
				
				MOV r6,r6,LSL #1 ;multiply (row2,colum1) by 2
				MOV r7,r7,LSL #2; multiply(row2,collum2) by 4
				MOV r8,r8,LSL #1 ; multiply ((row2,collum2) by 2
				
				ADD r7 ,r6,r7;  (row2,collum1) + (row2,collum2)
				ADD r8,r7,r8  ; (row2,collum1) + (row2,collum2)+ (row2,collum3)
				ADD r9,r9,r8  ; (row1,collum1) + (row1,collum2)+ (row1, collum3)+(row2,collum1) + (row2,collum2)+ (row2,collum3)
				
				LDRB r7,[r4,#1]; row 3 collumn 2 value
				LDRB r8,[r4,#2]; row 3 collum 3 value a
				LDRB r6,[r4],#1; row 3 collum1 value  also adds one to the adress so we go through all collums
				
				; we do not multiply (row3,collum1) since it being multiplied by one 
				MOV r7,r7,LSL #1; multiply by 2
				; we do not multiply (row3,collum3) since it being multiplied by one 
				
				ADD r7 ,r6,r7; (row3,collum1) + (row3,collum2)
				ADD r8,r7,r8 ;(row3,collum1) + (row3,collum2)+ (row3,collum3)
				ADD r9,r9,r8 ;(row1,collum1) + (row1,collum2)+ (row1, collum3)+(row2,collum1) + (row2,collum2)+ (row2,collum3) +(row3,collum1) + (row3,collum2)+ (row3,collum3)
				
				MOV r9,r9,LSR #4 ; divide by 16 by shifting binary form by 4 to the right
				STRB r9,[r1],#1; store new filer value in designated destination and shiftes the pixel filter by one
				SUBS r13,r13,#1
				BNE pixel_filter
;----------------------------------------------------end of pixel fliter loop------------------------
				ADD r1,r1,#2; makes it so r1 has the adress of the next row while also makeing sure it starts at collum 2 of the next row
				SUBS r12,r12,#1 ; row counter goes down by 1
				BNE image_filter 
;-------------------------------------------------- end of image filter loop--------------------------


;------------------------------------------------------------histogram for filtered image----------------------		

				LDR r0,=Histo2; will contain data for 1st histogram
				MOV r1,#0 ; counter used to co mpare vaules in the image
				MOV r4,#256 ;hiogram loop counter
				LDR r7, =filt_intensity
HISTO_FILTER    MOV r2, #0; counter for how many of what pixel intesity is in the  image in
				MOV r3, #256 ;total number of element in the 16x16 matrix
				LDR r5, =filter_image; get adress of the one dimensional array used to compare
;----------------------------------------array number search----------------------	
search_filter   LDRB r6,[r5],#1
				CMP  r6,r1
				ADDEQ r2,r2,#1; add to counter if one of the element is equal to the number being compared too
				SUBS r3,r3,#1
				BNE search_filter
;-----------------------------end of array number search loop----------------
				CMP  r2,#0 ;check if r2  has any number of a specific pixel intensity
				STRBNE r2 ,[r0],#1; stores counter of the number of a sepcific pixel intensity if couter is not zero
				CMP r2,#0
				STRBNE r1,[r7],#1 ; store the intensity that exists in the image
				ADD r1,r1,#1; set the next number that going to be searched and comapered with
				SUBS r4,r4,#1 ; histogram counter goes down
				BNE HISTO_FILTER

				
stop		    B stop
;the  image
row1        	DCB 0,0,0,0,255,255,255,255,0,0,0,0,255,255,255,255
row2			DCB 0,0,0,0,255,255,255,255,0,0,0,0,255,255,255,255
row3			DCB 0,0,0,0,255,255,255,255,0,0,0,0,255,255,255,255
row4			DCB 0,0,0,0,255,255,255,255,0,0,0,0,255,255,255,255
row5			DCB 255,255,255,255,0,0,0,0,255,255,255,255,0,0,0,0
row6			DCB 255,255,255,255,0,0,0,0,255,255,255,255,0,0,0,0
row7			DCB 255,255,255,255,0,0,0,0,255,255,255,255,0,0,0,0
row8			DCB 255,255,255,255,0,0,0,0,255,255,255,255,0,0,0,0
row9			DCB 0,0,0,0,255,255,255,255,0,0,0,0,255,255,255,255
row10			DCB 0,0,0,0,255,255,255,255,0,0,0,0,255,255,255,255
row11           DCB 0,0,0,0,255,255,255,255,0,0,0,0,255,255,255,255
row12			DCB 0,0,0,0,255,255,255,255,0,0,0,0,255,255,255,255
row13			DCB 255,255,255,255,0,0,0,0,255,255,255,255,0,0,0,0
row14			DCB 255,255,255,255,0,0,0,0,255,255,255,255,0,0,0,0
row15			DCB 255,255,255,255,0,0,0,0,255,255,255,255,0,0,0,0
row16			DCB 255,255,255,255,0,0,0,0,255,255,255,255,0,0,0,0
	
		
				END