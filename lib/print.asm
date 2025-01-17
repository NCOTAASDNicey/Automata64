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