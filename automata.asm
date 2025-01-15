#import "kernal.asm"
#import "macros.asm"
#import "zero.asm"

:BasicUpstart2(mainProg)
        * = $840
mainProg:
    cls()
    jsr toggle_fullscreen_multi    
    jsr render4
!:  jsr udtim
    jsr stop
    bne !-
    jsr toggle_fullscreen_multi
    print(message, black, 0)
    rts

#import "screenModes.asm"
#import "render4.asm"

message: .text "WOO YAY"
.byte 0

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