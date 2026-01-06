#import "lib/kernal.asm"
#import "macros.asm"
#import "zero.asm"

toggle_fullscreen_multi:
        lda #1<<FULLSCREEN_BIT | 1<<MULTI_BIT
        eor scrmode
        sta scrmode
        cmp #0
        bne _enter_multi_fullscreen
        jmp leave_fullscreen

toggle_fullscreen:
        lda #1<<FULLSCREEN_BIT
        eor scrmode
        sta scrmode
        cmp #0
        bne _enter_fullscreen
        jmp leave_fullscreen

enter_fullscreen_multi:
        lda #1<<FULLSCREEN_BIT | 1<<MULTI_BIT
        ora scrmode
        sta scrmode
_enter_multi_fullscreen:
        // Multi colour
        lda VIC_control_2
        ora #$10
        sta VIC_control_2 

_enter_fullscreen:
        ldy #[box_colour-box_origin]
        lda [boxColB+jmp_header_size],Y        
        sta VIC_back_0
        lda [boxColB+jmp_header_size],Y        
        sta VIC_border

        // isBoxChecked(boxScroll)
        // beq !+       
        lda VIC_control_1
        and #$F7            // 24 rows
        sta VIC_control_1
        jsr attachScrollIRQ
//  !:      
        lda VIC_control_mem //Point screen memory at $2000
        ora #$8
        sta VIC_control_mem

        lda VIC_control_1
        ora #$20
        sta VIC_control_1
             
       //Clear character map
        lda #<screen_mem_hi
        sta _chptr
        lda #>screen_mem_hi
        sta _chptr+1
!:      lda #$0
        ldy #0
!:      sta (_chptr),Y
        dey
        bne !-
        inc _chptr+1
        lda _chptr+1
        cmp #$40
        bcc !--

        //Screen memory also holds colour nybbles 01/10
        ldy #[box_colour-box_origin]
        lda [boxColR+jmp_header_size],Y        
        clc
        rol
        rol
        rol
        rol
        ora [boxColP+jmp_header_size],Y        
        ldy #0
!:      sta screen_mem,Y
        sta screen_mem+250,Y
        sta screen_mem+500,Y
        sta screen_mem+750,Y
        iny
        cpy #250
        bne !-        

        ldy #[box_colour-box_origin]
        lda [boxColA+jmp_header_size],Y        
        ldy #0
!:      sta colour_mem,Y
        sta colour_mem+250,Y
        sta colour_mem+500,Y
        sta colour_mem+750,Y        
        iny
        cpy #250
        bne !-
        rts

leave_fullscreen:
        lda scrmode
        and #~[1<<FULLSCREEN_BIT | 1<<MULTI_BIT]
        sta scrmode
        cls()
        screen_col(gui_back_col, gui_bor_col)

        lda VIC_control_mem //Point screen memory at $0400
        and #$F7
        sta VIC_control_mem
     
        lda VIC_control_1
        ora #$0B             // Ensure 25 rows and scroll pos
        sta VIC_control_1
        jsr detachScrollIRQ
 !:         
       
        lda VIC_control_1
        and #$DB             // Exit multi mode clear bit 5
        sta VIC_control_1

        lda VIC_control_2
        and #$EF
        sta VIC_control_2
        lda #0
        rts