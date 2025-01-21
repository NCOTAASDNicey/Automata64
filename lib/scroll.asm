scrollup8:
        lda #<screen_mem_hi
        sta _tempptr
        lda #>screen_mem_hi
        sta _tempptr+1
        lda #<[screen_mem_hi+[COLUMNS*BYTES_PER_CHAR]]
        sta _chptr
        lda #>[screen_mem_hi+[COLUMNS*BYTES_PER_CHAR]]
        sta _chptr+1

        ldx #30
!:      ldy #0
!:      lda (_chptr),Y
        sta (_tempptr),Y
        dey
        bne !-
        inc _tempptr+1
        inc _chptr+1
        dex
        bne !--
        rts