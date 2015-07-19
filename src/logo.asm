;Commodore 64 Logo by Eric Odland
;This displays an animated Commodore 64 logo

C64LOGO	subroutine
	LDA #<.SPR	;copy sprite data to bank 64-
	LDY #>.SPR
	STA Temp
	STY Temp+1
	LDA #$00
	LDY #$10
	STA Temp2
	STY Temp2+1
	LDY #0
.LOOP1	LDA (Temp),Y		;get byte
	CMP #$F2		;exit if done
	BEQ .ROUT0
	CMP #$F1		;if row of zeroes, expand
	BNE .NZ
	INC Temp
	BNE .L1
	INC Temp+1
.L1	LDA (Temp),Y		;expand zeroes
	TAX
	LDA #0
.LOOP2	STA (Temp2),Y
	DEX
	BEQ .L2
	INC Temp2
	BNE .LOOP2
	INC Temp2+1
	JMP .LOOP2
.NZ	STA (Temp2),Y		;not a row of zeroes, copy normally
.L2	INC Temp2
	BNE .EX
	INC Temp2+1
.EX	INC Temp
	BNE .LOOP1
	INC Temp+1
	JMP .LOOP1
;COPY C64 LOGO CHAR DATA, turn it upside down
.ROUT0	LDX #$90	;copy logo char data
.C2	DEX
	BEQ .ROUT0B
	LDA .LOGO-1,X
	STA $39FF,X	;char 64
	JMP .C2
.ROUT0B	LDA #$90
	LDY #$3A
	STA Temp
	STY Temp+1
	LDX #0		;turn it upside down for chars 82-99?
	LDY #7
.C3	LDA $3A00,X
	STA (Temp),Y
	INX
	CPX #$8F
	BEQ .SCN
	DEY
	BPL .C3
	LDY #7
	LDA Temp
	CLC
	ADC #8
	BCC .C4
	INC Temp+1
.C4	STA Temp
	JMP .C3

;DRAW THE LOGO
.SCN	LDA #$20	;pause
	STA $0337
	JSR Wait
	
	;lda #%00110111
	;sta $1
	
;.logoir	LDA $D012
;	CMP #240
;	BNE .logoir
	
	;lda #%00110100
	;sta $1
	
	LDA #$50	;screen loc to copy to
	LDY #$05
	STA Temp
	STY Temp+1
	LDY #$D9	;color memory
	STA Temp2
	STY Temp2+1
	LDX #0
	LDY #0
.LOOP3	LDA .LOGOMP,X	;store
	BEQ .ROUT1
	STA (Temp),Y
	LDA #6
	STA (Temp2),Y
	INX
	INY
	CPY #8
	BNE .LOOP3
	LDY #0
	CLC		;next screen row
	LDA Temp
	ADC #$28
	BCC .C1
	INC Temp+1
.C1	STA Temp
	CLC
	LDA Temp2
	ADC #$28
	BCC .C0
	INC Temp2+1
.C0	STA Temp2
	JMP .LOOP3

.ROUT1	LDA #9	;set part of logo to brown
	JSR .RED
	LDA #5
	STA $0337
	JSR Wait
	LDA #2	;set part of logo to red
	JSR .RED
	LDX #$0E	;set sprite positions
.L3	DEX		
	BMI .ROUT2
	LDA .SPRXY,X
	STA SPR0X,X
	JMP .L3
.ROUT2	LDX #$07	;set sprite pointers
.L4	DEX
	BMI .ROUT3
	LDA .SPRP,X
	STA SPRDATA,X
	JMP .L4
.ROUT3	LDX #$07	;set sprite colors
.L5	DEX
	BMI .ROUT4
	LDA .SPRC,X
	STA SPR0C,X
	JMP .L5
.ROUT4	LDA #$55	;pause
	STA $0337
	JSR Wait
	LDA #%00001101	;turn some sprites on
	STA SPRDISP
	LDY #4
	LDA #5
	STA $0337
.ANIM	JSR Wait	;***Animate Logo***
	LDX #5
.L6A	DEX
	BMI .L6
	INC SPRDATA,X
	JMP .L6A
.L6	CPY #3
	BNE .L7
	LDA #%01111111	;turn on rest of sprites
	STA SPRDISP
.L7	CLC
	LDA SPR5X	;move sprites 5 and 6
	ADC #8
	STA SPR5X
	LDA SPR5Y
	ADC #8
	STA SPR5Y
	LDA SPR6X
	ADC #6
	STA SPR6X
	LDA SPR6Y
	ADC #6
	STA SPR6Y
	DEY
	BNE .ANIM
	LDA #$60	;pause
	STA $0337
	JSR Wait
	
	LDA #9		;***Fade out***
	JSR .RED
	LDY #2
	LDX #0
	STX Temp2
.F0	STX Temp
.F1	LDX Temp
	LDA .FDAT,X
	INC Temp
	INC Temp
	LDX Temp2
	STA SPR0C,X
	INC Temp2
	LDA Temp2
	CMP #8
	BNE .F1
	LDA #5
	STA $0337
	JSR Wait
	DEY
	BEQ .RET
	CPY #1
	BNE .F2
	jsr ClearScreen
.F2	LDX #0
	STX Temp2
	LDX #1
	JMP .F0
.RET	LDA #0
	STA SPRDISP
	LDA #$70	;pause
	STA $0337
	JSR Wait
	RTS

.FDAT	.BYTE $06, $00	;data for color fade
	.BYTE $0E, $06
	.BYTE $06, $00
	.BYTE $02, $09
	.BYTE $06, $00
	.BYTE $09, $00
	.BYTE $00, $00

;.wait	sta $0334
;	stx $0335
;	sty $0336
;	lda #0
;	tax
;	tay
;	jsr settim
;.loop	jsr rdtim
;	cmp $0337
;	bmi .loop
;	lda $0334
;	ldx $0335
;	ldy $0336
;	rts

	
.RED	LDX #3		;used for fading out the logo
.CR0	STA $D9F4,X
	DEX
	BNE .CR1
	LDX #43
.CR1	CPX #40
	BEQ .CR2
	JMP .CR0
.CR2	RTS

.SPRXY	.BYTE 158, 121, 158, 121, 192, 135, 192, 147, 169, 156, 155
	.BYTE 119, 157, 121
;.SPRP	.BYTE 192, 195, 200, 200, 204, 209, 210
.SPRP	.BYTE 64, 67, 72, 72, 76, 81, 82
.SPRC	.BYTE $0E, $01, $0E, $0A, $0E, $08, $09
.SPR	.BYTE $F1, $0F, $02, $F1, $3C, $02, $00, $00, $03
	.BYTE $80, $00, $07, $00, $00, $01, $F1, $29, $FF
	.BYTE $F1, $03, $04, $00, $00, $04, $00, $00, $04
	.BYTE $00, $00, $07, $E0, $00, $05, $80, $00, $3F
	.BYTE $00, $00, $05, $00, $00, $01, $00, $00, $01
	.BYTE $F1, $24, $10, $00, $00, $18, $10, $00, $0A
	.BYTE $30, $00, $03, $40, $00, $08, $40, $00, $08
	.BYTE $80, $00, $00, $80, $00, $36, $00, $00, $61
	.BYTE $80, $00, $00, $40, $00, $00, $40, $00, $00
	.BYTE $20, $F1, $1C, $FF, $80, $00, $00, $40, $20
	.BYTE $00, $28, $60, $00, $0D, $00, $00, $10, $80
	.BYTE $00, $10, $80, $00, $10, $80, $00, $10, $80
	.BYTE $00, $0D, $00, $00, $71, $40, $00, $40, $F1
	.BYTE $03, $10, $00, $00, $08, $00, $00, $04, $F1
	.BYTE $15, $08, $F1, $10, $02, $F1, $2F, $FF, $F1
	.BYTE $09, $04, $80, $00, $07, $80, $00, $07, $00
	.BYTE $00, $0F, $00, $00, $01, $80, $F1, $32, $12
	.BYTE $80, $00, $0F, $00, $00, $0F, $00, $00, $0F
	.BYTE $00, $00, $0F, $00, $00, $12, $80, $F1, $05
	.BYTE $20, $F1, $1F, $FF, $80, $F1, $3F, $E0, $F1
	.BYTE $3E, $FF, $FE, $00, $00, $E0, $F1, $3C, $FF
	.BYTE $E0, $00, $FC, $00, $00, $E0, $00, $00, $80
	.BYTE $F1, $35, $FF, $FF, $F0, $00, $FE, $00, $00
	.BYTE $F0, $00, $00, $C0, $00, $00, $80, $00, $00
	.BYTE $80, $F1, $30, $40, $F1, $05, $10, $00, $00
	.BYTE $0C, $00, $00, $03, $80, $F1, $31, $FF, $C0
	.BYTE $00, $00, $40, $00, $00, $30, $00, $00, $1C
	.BYTE $00, $10, $07, $80, $E0, $00, $FF, $80, $F1
	.BYTE $2E, $C0, $00, $00, $40, $00, $00, $30, $00, $06
	.BYTE $1C, $00, $1E, $0F, $80, $F8, $03, $FF, $C0
	.BYTE $00, $7F, $F1, $2B, $FF, $C0, $00, $00, $40
	.BYTE $00, $00, $70, $00, $06, $3C, $00, $1E, $1F
	.BYTE $80, $FC, $0F, $FF, $F8, $03, $FF, $E0, $00
	.BYTE $7F, $F1, $29, $60, $00, $00, $F0, $00, $00
	.BYTE $60, $F1, $38, $FF, $1E, $00, $00, $3F, $00
	.BYTE $00, $7F, $80, $00, $FF, $C0, $00, $7F, $80
	.BYTE $00, $3F, $00, $00, $1E, $F1, $2D, $F2
;$F1 means a row of zeroes, $F2 means end of data
	
.LOGO	.BYTE $00, $00, $00, $00, $00, $00, $01, $07
	.BYTE $00, $00, $00, $00, $0F, $7F, $FF, $FF
	.BYTE $00, $00, $00, $FF, $FF, $FF, $FF, $FF
	.BYTE $00, $00, $00, $C0, $FC, $FF, $FF, $FF
	.BYTE $00, $00, $00, $00, $00, $01, $03, $07
	.BYTE $0F, $1F, $3F, $FF, $FF, $FF, $FF, $FF
	.BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.BYTE $0F, $0F, $1F, $1F, $3F, $3F, $3F, $7F
	.BYTE $FF, $FF, $FE, $F8, $E0, $E0, $80, $80
	.BYTE $FF, $C0, $00, $00, $00, $00, $00, $00
	.BYTE $FF, $7F, $0F, $03, $00, $00, $00, $00
	.BYTE $00, $00, $00, $00, $00, $FF, $FF, $FF
	.BYTE $00, $00, $00, $00, $00, $F8, $F0, $E0
	.BYTE $7F, $7F, $7F, $FF, $FF, $FF, $FF, $FF
	.BYTE $FF, $FF, $FE, $FE, $FC, $FC, $FC, $FC
	.BYTE $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
	.BYTE $FF, $FF, $FF, $FE, $FC, $F8, $F0, $00
	.BYTE $C0, $80, $00, $00, $00, $00, $00, $00
.LOGOMP	.BYTE $20, $40, $41, $42, $43, $20, $20, $20
	.BYTE $44, $45, $46, $46, $46, $20, $20, $20
	.BYTE $47, $46, $48, $49, $4A, $4B, $4B, $4C
	.BYTE $4D, $4E, $20, $20, $20, $4F, $50, $51
	.BYTE $5F, $60, $20, $20, $20, $61, $62, $63
	.BYTE $59, $46, $5A, $5B, $5C, $5D, $5D, $5E
	.BYTE $56, $57, $46, $46, $46, $20, $20, $20
	.BYTE $20, $52, $53, $54, $55, $20, $20, $20
	.BYTE $00

;	INCLUDE "system.asm"
