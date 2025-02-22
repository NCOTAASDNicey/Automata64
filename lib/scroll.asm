.const JIFFY_MASK = 3

vectorCache: .word 0

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

scroll1line:
        // Only scroll if we have rendered as far the bottom row
        lda row_counter
        cmp #BYTES_PER_CHAR*ROWS
        bcs !+
        rts

 !:     lda VIC_control_1
        sec
        sbc #$01
        and #$07
        sta _scratch
        lda VIC_control_1
        and #$F8        
        ora _scratch
        sta VIC_control_1
        lda _scratch
        cmp #$07
        bne !+
        jsr continue8rows
!:      rts

scrollIRQ:
        lda JIFFY_CLOCK+2
        and #JIFFY_MASK
        cmp #JIFFY_MASK
        beq !+
        jmp (vectorCache)
!:      
        jsr scroll1line
        jmp (vectorCache)

attachScrollIRQ:
        sei
        lda CINV
        sta vectorCache
        lda CINV+1
        sta vectorCache+1
        lda #<scrollIRQ
        sta CINV
        lda #>scrollIRQ
        sta CINV+1               
        cli
        rts

detachScrollIRQ:
        sei
        lda vectorCache
        sta CINV
        lda vectorCache+1
        sta CINV+1            
        cli
        rts
