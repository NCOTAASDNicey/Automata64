#import "kernal.asm"
#import "macros.asm"
#import "zero.asm"

programChars:
{
        enterProc()
        sei
        lda $1
        and #$fb
        sta $1

        lda #$30
        sta _tempptr+1
        lda #$d0
        sta _chptr+1
        ldx #$10
        ldy #$00
        sty _chptr
        sty _tempptr

        !:
        lda (_chptr),y
        sta (_tempptr),y
        iny
        bne !-
        inc _chptr+1
        inc _tempptr+1
        dex
        bne !-

// Set up arrow chars
        customChar(0,65)
        customChar(1,83)
        customChar(2,88)
        customChar(3,90)                             
        customChar(4,102)
        customChar(5,94)                          

        lda $1
        ora #$04
        sta $1    
        cli
        leaveProc()
        rts        
}

.macro customChar(source,num) {
        ldx #7
        !:
        lda customChars+(8*source),x
        sta $3000+(num*8),x
        eor #$FF
        sta $3400+(num*8),x
        dex
        bpl !-          
}


customChars:
        .byte %00000000
        .byte %00001000
        .byte %00011100
        .byte %00101010
        .byte %00001000
        .byte %00001000
        .byte %00001000
        .byte %00000000

        .byte %00000000
        .byte %00001000
        .byte %00001000
        .byte %00001000
        .byte %00101010
        .byte %00011100
        .byte %00001000
        .byte %00000000


        .byte %00000000
        .byte %00000100
        .byte %00000010
        .byte %01111111
        .byte %00000010
        .byte %00000100
        .byte %00000000
        .byte %00000000

        .byte %00000000
        .byte %00100000
        .byte %01000000
        .byte %11111110
        .byte %01000000
        .byte %00100000
        .byte %00000000
        .byte %00000000

        .byte %01010101
        .byte %10101010
        .byte %01010101
        .byte %10101010
        .byte %01010101
        .byte %10101010
        .byte %01010101
        .byte %10101010

        .byte %00000000
        .byte %00000010        
        .byte %00100010
        .byte %01000010
        .byte %11111110
        .byte %01000000
        .byte %00100000
        .byte %00000000

customCharsEnd: