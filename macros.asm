#importonce

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

.macro  screen_col(col,border) {
        lda #col        
        sta VIC_back_0
        lda #border
        sta VIC_border
}

.macro cls() {
        lda #147
        jsr chrout
}
