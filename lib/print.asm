.macro str(_s) {
        .text _s
        .byte 0
}

.macro print(str,col,reverse) {
        pha
        txa
        pha
        tya
        pha
        lda #col
        sta chrout_colour
        lda #reverse
        sta 199
        lda #<str
        ldx #>str        
        jsr printstr
        pla
        tay
        pla
        tax
        pla
}

.macro printhex(col,reverse) {
        enterProc()
        lda #col
        sta chrout_colour
        lda #reverse
        sta 199
        tsx
        lda $103,X 
        jsr printhex
        leaveProc()
}

.macro printhexProg(col,reverse) {
        enterProc()
        lda #col
        sta chrout_colour
        lda #reverse
        sta 199
        tsx
        lda $103,X 
        jsr printhexProg
        leaveProc()
}

printstr:
        tay
        lda _chptr
        pha
        lda _chptr+1
        pha
        tya
        sta _chptr
        stx _chptr+1
        ldy #$00
_loop:  lda (_chptr),y
        beq !+
        jsr chrout
        iny
        bne _loop
!:      pla
        sta _chptr+1
        pla
        sta _chptr
        rts

_hexDigit:
        cmp #$0A
        bcc !+
        adc #$06
 !:     adc #$30
        jmp chrout

printhex:
        pha
        lsr
        lsr
        lsr
        lsr
        jsr _hexDigit
        pla
        and #$0F
        jmp _hexDigit

printhexProg:
        pha
        lsr
        lsr
        lsr
        lsr
        jsr chrout
        pla
        and #$0F
        jmp chrout