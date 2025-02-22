#import "lib/data.asm"
#import "lib/objects.asm"

.const DEVICE=10
.const FILENO=1
.const top = 0
.const bottom = 1
.const right = 2
.const left = 3
.const top_right = 4
.const top_left = 5
.const bottom_right = 6
.const bottom_left = 7
.const fill = 8

.const COLUMNS=40
.const ROWS=25
.const PIXELS_PER_BYTE=4
.const BYTES_PER_CHAR=8
.const BUFFER_LENGTH=COLUMNS*PIXELS_PER_BYTE

#import "lib/boxes.asm"

get:
        jsr construct
        ldy variable
        lda (this),Y
        rts

select:
        jsr construct
        ldy #[box_select-box_origin]
        lda #1
        sta (this),Y
        lda #0
        rts
        
deselect:
        jsr construct
        ldy #[box_select-box_origin]
        lda #0
        sta (this),Y
        lda #0        
        rts
                       
toggle:
        jsr construct
        loadObjectByte(box_check)
        eor #1
        sta (this),Y
        lda #0
        rts
        
render_toggle:
        jsr construct
        clc
        lda box_origin
        adc #X_CHARS+1
        sta _chptr
        lda box_origin+1
        adc #0 
        sta _chptr+1                

        loadObjectByte(box_check)
        cmp #1
        beq !+
        lda #87        
        jmp !++
!:      lda #81
!:      ldy #0
        sta (_chptr),Y
        lda #0
        rts
render:
        jsr construct
        lda scrmode
        beq !+
        lda #0
        rts
!:      lda box_height
        sta box_height_working

        loadObjectByte(box_select)
        cmp #0
        beq _notselected
        lda #<style2
        sta _styleptr
        lda #>style2
        sta _styleptr+1
        jmp _style_done
        
_notselected:
        loadObjectPointer(box_style, _styleptr)
_style_done:
        loadObjectPointer(box_origin, _chptr)
                                               
        // Top line
        ldy box_width
        dey
        sty box_width_working
        ldy #top_right
        lda (_styleptr),Y
        ldy box_width_working
        sta (_chptr),Y

        sty box_width_working
        ldy #top
        lda (_styleptr),Y
        ldy box_width_working
!:      dey
        sta (_chptr),y
        bne !-

        sty box_width_working
        ldy #top_left
        lda (_styleptr),Y
        ldy box_width_working
        sta (_chptr),y

        dec box_height_working

        // middle lines
_mid:   clc
        lda #X_CHARS
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1
        ldy box_width

        sty box_width_working
        ldy #right
        lda (_styleptr),Y
        ldy box_width_working
        dey
        sta (_chptr),y
        sty box_width_working
        ldy #fill
        lda (_styleptr),Y
        ldy box_width_working
!:      dey
        sta (_chptr),y
        bne !-
        sty box_width_working
        ldy #left
        lda (_styleptr),Y
        ldy box_width_working
        sta (_chptr),y

        dec box_height_working
        bne _mid
        // bottom line
        ldy box_width
        sty box_width_working
        ldy #bottom_right
        lda (_styleptr),Y
        ldy box_width_working
        dey
        sta (_chptr),y
        sty box_width_working
        ldy #bottom
        lda (_styleptr),Y
        ldy box_width_working
!:      dey
        sta (_chptr),y
        bne !-
        sty box_width_working
        ldy #bottom_left
        lda (_styleptr),Y
        ldy box_width_working
        sta (_chptr),y
 
//Fill in colour

        lda box_col_origin
        sta _chptr
        lda box_col_origin+1
        sta _chptr+1

        lda box_height
        sta box_height_working
        lda box_width
        sta box_width_working
        lda box_edited
        beq !+
        lda #red
        jmp !+++
!:      lda box_select
        beq !+
        lda #cyan
        jmp !++
!:      lda box_frame_colour
!:      sta box_colour_working
        jsr _colframe

        clc
        lda box_col_origin
        adc #X_CHARS+1
        sta _chptr
        lda box_col_origin+1 
        adc #0
        sta _chptr+1
        clc
        lda box_height
        sbc #1
        sta box_height_working
        clc
        lda box_width
        sbc #1
        sta box_width_working
        lda box_colour
        sta box_colour_working
        jsr _colbox
        
//print legend
        lda box_legend
        beq !++
        clc
        ldx box_y
        ldy box_x
        jsr plot

        lda box_colour
        sta chrout_colour

        lda #1
        cmp box_select
        beq !+
        lda #0
!:      sta 199

        lda box_legend
        ldx box_legend+1
        jsr printstr
!:      lda #0
        rts        
        
_colframe:
        lda box_colour_working
        ldy box_width_working
!:      dey
        sta (_chptr),Y
        bne !-
        dec box_height_working

!:      clc
        lda #X_CHARS
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1
        ldy box_width_working
        dey
        lda box_colour_working
        sta (_chptr),Y
        ldy #0
        sta (_chptr),Y
        dec box_height_working
        bne !-

        ldy box_width_working
!:      dey
        sta (_chptr),Y
        bne !-
        lda #0
        rts
        
_colbox:
!:      lda box_colour_working
        ldy box_width_working
!:      dey
        sta (_chptr),Y
        bne !-
        clc
        lda #X_CHARS
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1
        dec box_height_working
        bne !--
        ldy #method_detail
        jsr reinvokevirtual
        lda #0
        rts 


update_rule4:
        sec
        sbc #49
        bpl !+
        lda #9
 !:     tay
        lda #<rule4
        sta _chptr
        lda #>rule4
        sta _chptr+1

        lda #<str_rule4
        sta _styleptr
        lda #>str_rule4
        sta _styleptr+1

        lda (_chptr),Y
        clc
        adc #1
        and #3
        sta (_chptr),Y
        adc #48
        sta (_styleptr),Y
        lda #0
        rts
        
renderrule4:
        lda #<rule4
        sta _chptr
        lda #>rule4
        sta _chptr+1

        lda #<str_rule4
        sta _styleptr
        lda #>str_rule4
        sta _styleptr+1

        ldy #0
!:      lda (_chptr),Y
        clc
        adc #48
        sta (_styleptr),Y
        iny
        cpy #10
        bne !-
        jsr render
        rts
        
handlekey:
        jsr construct
        loadObjectByteY(box_select)
        beq !+++

        lda #KEY_RETURN
        cmp keypress
        bne !+
        ldy #method_action
        jmp reinvokevirtual
        
!:      lda #KEY_SPACE
        cmp keypress
        bne !+
        ldy #method_continue
        jmp reinvokevirtual       

!:      lda #KEY_ESC
        cmp keypress
        bne !+
        ldy #method_escape
        jmp reinvokevirtual

        !:     lda #0 //Dont signal program end
        rts
        
handlerulekey4:
        jsr construct
        loadObjectByteY(box_select)
        beq !+++
        lda keypress
        cmp #KEY_CSR_UP
        bne !+
        jsr handlekeyi
        jmp !++++

        cmp #KEY_CSR_DOWN
        bne !+
        jsr handlekeyi
        jmp !++++        

!:      
        cmp #48
        bcc !+
        cmp #58
        bcs !+
        ldy #method_action
        jsr reinvokevirtual
        jsr construct
        lda #1
        saveObjectByte(box_edited)
        lda #0 //Dont signal program end
        rts
                
!:      cmp #83 //S for Save
        bne !+
        
        //JSR writeBank
        lda #FILENO
        ldx #DEVICE
        ldy #1
        jsr setlfs

        lda #[str_rule-str_filenameS]
        ldx #<str_filenameS
        ldy #>str_filenameS
        jsr setnam

        lda #<rule4bank
        sta _chptr
        lda #>rule4bank
        sta _chptr+1
        ldx #<rule4bankend
        ldy #>rule4bankend
        lda #_chptr
        jsr save
        lda #0
        saveObjectByte(box_edited)
        lda #0 //Dont signal program end
        rts
        
!:      cmp #76 //L for Load
        bne !+

        lda #FILENO
        ldx #DEVICE
        ldy #1
        jsr setlfs

        lda #[str_filenameS-str_filenameL]
        ldx #<str_filenameL
        ldy #>str_filenameL
        jsr setnam

        lda #0      //Load
        ldx #<rule4bank
        ldy #>rule4bank
        jsr load                
!:      lda #0 //Dont signal program end
        rts    
        
handlekeyc:
        jsr construct
        loadObjectByteY(box_select)
        beq !+
        ldy #[box_colour-box_origin]
        lda keypress
        cmp #KEY_CSR_UP
        beq !++
        cmp #KEY_CSR_DOWN
        beq !++++
!:      lda #0 //Dont signal program end
        rts
!:      lda (this),Y
        clc
        adc #1
!:      and #15
        sta (this),Y
        lda #1
        saveObjectByte(box_edited)
        jmp !---
!:      lda (this),Y
        sec
        sbc #1
        jmp !--

handlekeyi:
        jsr construct
        loadObjectByteY(box_select)
        beq !++
        ldy #[box_check-box_origin]
        lda keypress
        cmp #KEY_CSR_UP
        beq !+++
        cmp #KEY_CSR_DOWN
        beq !+++++
        jmp !++
!:      jsr rdBank
!:      lda #0 //Dont signal program end
        rts
!:      lda (this),Y
        jsr writeBank
        clc
        adc #1
!:      and #$0F
        sta (this),Y
        jmp !----
!:      lda (this),Y
        jsr writeBank
        sec
        sbc #1
        jmp !--


handlekeyl:
        jsr construct        
        lda SHFLAG
        and #$01
        beq !+        
        offsetFromThis(box_colour)
        jmp !++
!:      offsetFromThis(box_colour_working)
!:      lda keypress
        cmp #KEY_CSR_UP
        beq !++
        cmp #KEY_CSR_DOWN
        beq !+++
!:      lda #0 //Dont signal program end
        jmp handlekey
!:      
        lda (this),Y
        clc
        adc #1
        and #$0F
        sta (this),Y
        jmp !--
!:      
        lda (this),Y
        sec
        sbc #1
        and #$0f
        sta (this),y
        jmp !---       
        
writeBank:
        pha
        tya
        pha
        txa
        pha
        
        lda #<rule4bank
        sta _chptr
        lda #>rule4bank
        sta _chptr+1
        lda rule4index
        clc
        asl
        asl
        asl
        asl
        adc _chptr
        sta _chptr
        lda #0
        adc _chptr+1
        sta _chptr+1 

        lda #<rule4
        sta _tempptr
        lda #>rule4
        sta _tempptr+1        
          
        ldy #10
!:      dey
        lda (_tempptr),Y
        sta (_chptr),Y
        cpy #0     
        bne !-    
        
        pla
        tax
        pla
        tay
        pla
        rts     

rdBank:
        pha
        sta _scratch
        tya
        pha
        txa
        pha

        lda #<rule4bank
        sta _chptr
        lda #>rule4bank
        sta _chptr+1
        lda _scratch
        clc
        asl
        asl
        asl
        asl
        adc _chptr
        sta _chptr
        lda#0
        adc _chptr+1
        sta _chptr+1 


        lda #<rule4
        sta _tempptr
        lda #>rule4
        sta _tempptr+1        

        ldy #10
!:      dey
        lda (_chptr),Y
        sta (_tempptr),Y
        cpy #0
        bne !-

        pla
        tax
        pla
        tay
        pla
        rts               
        
render_index:
        jsr construct
        clc
        lda box_origin
        adc #X_CHARS+1
        sta _chptr
        lda box_origin+1
        adc #0
        sta _chptr+1                

        loadObjectByte(box_check)
        tax
        cpx #10
        bcc !+   //10 or more
        sbc #9
        jmp !++
!:      adc #48
!:      ldy #0
        sta (_chptr),Y
        lda #0
        rts               
                                            
flowKey:
        lda keypress  

        cmp #KEY_CSR_LEFT
        bne _not_leftf
        dec selected
        jmp _key_handledf
_not_leftf:
        cmp #KEY_CSR_RIGHT
        bne !+++
        inc selected   
    
_key_handledf:
        callMethod(method_deselect, _boxlist)
        lda #method_select
        sta method
        lda selected
        cmp #0
        bne !+
        lda #boxes_list_size-1
        jmp !++
!:      cmp #boxes_list_size
        bne !+
        lda #1
!:      sta selected
        jsr _boxListAt
!:      lda #0 //Don't signal exit
        rts

_boxlist:
        ldy #0
        sty return
!:      lda boxes,Y
        iny
        ldx boxes,Y
        iny
        sty _scratch+1

        ldy method
        jsr invokevirtual
        cmp #0
        beq !+
        sta return 
!:      ldy _scratch+1 
        cpy #boxes_list_size*2
        bcc !--
        lda return
        rts


_boxListAt:
        asl
        tay
        lda boxes,Y
        ldx boxes+1,Y
        ldy method
        jmp invokevirtual //JSR,RTS
    
construct:
        ldy #3
        lda (this),Y // Fetch size of variables
        pha
        iny
        lda (this),Y // Fetch fixed variable pointer low byte
        sta _chptr
        iny
        lda (this),Y // Fetch fixed variable pointer high byte
        sta _chptr+1 
        clc        //advance this pointer over vtable to point at data
        lda this
        adc #jmp_header_size
        sta this
        lda this+1
        adc #0
        sta this+1

        pla
        tay
!:      lda (this),Y
        sta (_chptr),Y
        dey
        bpl !-
        rts

doJumpTable:
        sta _scratch
        pla
        sta _tempptr
        pla
        sta _tempptr+1
        tya
        asl
        tay
        iny
        lda (_tempptr), y
        sta _target
        iny
        lda (_tempptr), y
        sta _target+1
        lda _scratch
        jmp (_target)
             
            
invokevirtual:
        sta this
        stx this+1
        jmp (this)
         
reinvokevirtual:
        pha
        sec        //return this pointer to vtable
        lda this
        sbc #jmp_header_size
        sta this
        lda this+1
        sbc #0
        sta this+1
        pla
        jmp (this)
         
empty:
        lda #0
        rts
        
exit:
        jsr leave_fullscreen
        lda #1
        rts

rule:
.byte 0,1,1, 1,1,0, 0,0
ruledec:
.byte 30

rule4index:
.byte 0

rule4bank:
.byte 1,2,3,0,1,2,2,0,3,2,0,0,0,0,0,0
.byte 2,0,1,2,2,2,3,3,0,2,0,0,0,0,0,0
.byte 1,2,0,0,1,3,1,1,0,1,0,0,0,0,0,0
.byte 2,2,2,2,2,1,2,3,2,3,0,0,0,0,0,0

.byte 3,0,1,0,0,0,2,0,0,0,0,0,0,0,0,0
.byte 2,1,3,1,2,1,3,3,0,1,0,0,0,0,0,0
.byte 2,0,1,1,2,0,3,3,2,2,0,0,0,0,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 0,0,0,0,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 6,5,7,2,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 6,5,7,2,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 6,5,7,2,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 6,5,7,2,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 6,5,7,2,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 6,5,7,2,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 6,5,7,2,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 6,5,7,2,0,0
rule4bankend:


boxes:

.for (var i=0; i<boxesList.size(); i++) {
        .word boxesList.get(i)
}

str_exit: .text "EXIT"
.byte 0
str_run: .text "RUN"
.byte 0
str_back: .text "BCK"
.byte 0
str_pen: .text "PEN"
.byte 0
str_aux: .text "AUX"
.byte 0
str_bord: .text "BRD"
.byte 0
str_rnd: .text "RND"
.byte 0
str_ind: .text "IND"
.byte 0
str_scroll: .text "SCROLL"
.byte 0
str_automata: .text " 1D CELLULAR AUTOMATA "
.byte 0
str_filenameL: .text "RULE"
.byte 0
str_filenameS: .text "str_0:RULE"
.byte 0
str_rule: .text "********"
.byte 0
str_rule4: .text "**********"
.byte 0

