#import "kernal.asm"
#import "macros.asm"
#import "zero.asm"

multicolour: .byte 0

multi_scr_col: .byte blue
multi_bor_col: .byte green
multi_1_col: .byte red
multi_2_col: .byte yellow

toggle_fullscreen:
        lda #0
        sta multicolour
        jmp _toggle_fullscreen

toggle_fullscreen_multi:
        lda #8
        sta multicolour

_toggle_fullscreen:
        lda #$01
        eor fullscreen
        sta fullscreen
        cmp #0
        bne _enter_fullscreen
        jmp leave_fullscreen

_enter_fullscreen:
        lda multi_scr_col
        sta VIC_back_0
        lda multi_bor_col
        sta VIC_border
       
        lda VIC_control_mem //Point screen memory at $2000
        and #$0F
        ora #$80
        sta VIC_control_mem

        lda VIC_control_1
        ora #$20
        sta VIC_control_1
             
       //Clear character map
        lda #<bitmap
        sta _chptr
        lda #>bitmap
        sta _chptr+1
!:      lda #$0
        ldy #0
!:      sta (_chptr),Y
        dey
        bne !-
        inc _chptr+1
        lda _chptr+1
        cmp #$58
        bne !--

        //Character colour for HI-RES 2 colour mode
        lda multi_1_col // upper nybble pixel set colour
        rol
        rol
        rol
        rol
        ora multi_2_col  // lower nybble pixel set colour
        ora multicolour // set multicolour mode
             
        ldy #0
        //lda #$73
!:      sta screen_mem,Y
        sta screen_mem+250,Y
        sta screen_mem+500,Y
        sta screen_mem+750,Y
        iny
        cpy #250
        bne !-
        lda #0
        rts

leave_fullscreen:
        lda #0
        sta fullscreen
        cls()
        screen_col(lt_blue, blue)

        lda VIC_control_mem //Point screen memory at $0400
        and #$0F
        ora #$10
        sta VIC_control_mem
       
        lda VIC_control_1
        and #$DF
        sta VIC_control_1

        lda #0
        rts