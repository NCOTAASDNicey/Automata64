#import "lib/kernal.asm"
#import "lib/macros.asm"
#import "lib/zero.asm"

:BasicUpstart2(mainProg)
        * = $840

.const edge_col=white
.const selected_col=cyan
.const gui_back_col=black
.const gui_bor_col=gray_3


#import "lib/data.asm"
#import "lib/objects.asm"
#import "lib/print.asm"
#import "lib/boxes.asm"
#import "lib/gui.asm"
#import "lib/screenModes.asm"
#import "lib/render4.asm"
#import "lib/scroll.asm"
#import "lib/file.asm"

initRandom:
    lda #$FF  // maximum frequency value
    sta $D40E // voice 3 frequency low byte
    sta $D40F // voice 3 frequency high byte
    lda #$80  // noise waveform, gate bit off
    sta $D412 // voice 3 control register
    rts

.macro random() {
    lda $D41B
}    

mainProg:
    cls()
    jsr initRandom
    screen_col(gui_back_col, gui_bor_col)
    lda #0
    sta scrmode
    sta return
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


message: str("WOO YAY")

