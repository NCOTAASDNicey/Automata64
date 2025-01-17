#import "lib/kernal.asm"
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

#import "lib/screenModes.asm"
#import "lib/render4.asm"
#import "lib/print.asm"

message: .text "WOO YAY"
.byte 0
