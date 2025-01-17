#importonce

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
