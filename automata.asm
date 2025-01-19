#import "lib/kernal.asm"
#import "macros.asm"
#import "zero.asm"

:BasicUpstart2(mainProg)
        * = $840

.const edge_col=white
.const selected_col=yellow
.const gui_back_col=black
.const gui_bor_col=gray_3


#import "lib/print.asm"
#import "lib/gui.asm"
#import "lib/screenModes.asm"
#import "lib/render4.asm"

mainProg:
    cls()
    screen_col(gui_back_col, gui_bor_col)
    lda #0
    sta scrmode
    sta return
    lda #1
    sta selected
    jsr _key_handledf
    callMethod(method_render, _boxlist)    

_main_loop:
    jsr waitkey
    sta keypress    
    callMethod(method_key, _boxlist)
    pha // Use key methods return values
    callMethod(method_render, _boxlist)
    pla
    bne done
    jmp _main_loop

done:
    cls()
    screen_col(lt_blue, blue)
    print(message, black, 0)
    rts

waitkey:
!:   jsr getin
     cmp #0
     beq !-    
     rts          



message: .text "WOO YAY"
.byte 0
