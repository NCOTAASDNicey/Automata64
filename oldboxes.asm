#import "lib/kernal.asm"
#import "macros.asm"
#import "objects.asm"

.const method_render = 0
.const method_key = 1
.const method_get = 2
.const method_select = 3
.const method_deselect = 4
.const method_action = 5
.const method_detail = 6
.const method_escape = 7
.const method_continue = 8
    
.const  jmp_header_size = 6

.const top = 0
.const bottom = 1
.const right = 2
.const left = 3
.const top_right = 4
.const top_left = 5
.const bottom_right = 6
.const bottom_left = 7
.const fill = 8
.const bitmap = $2000
.const DEVICE=10
.const FILENO=1
.const boxes_list_size = 12 //Update this when you add more boxes

* = zero_page_rs_232 virtual
.zp {
this: .word 0
_chptr: .word 0
_styleptr: .word 0
_tempptr: .word 0
}

:BasicUpstart2(mainProg)
        * = $1000
mainProg:
     sei
     cls()
     screen_col(black, black)
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
     lda _scratch+4 // debug
     sta screen_mem
     jmp _main_loop    
       
done:
     jsr leave_fullscreen
     lda #<boxFinal
     ldx #>boxFinal
     ldy #0
     jsr invokevirtual
     lda #0
     sta $800
     sta $801
     sta $802
     rts

waitkey:
!:   jsr getin
     cmp #0
     beq !-    
     rts

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
_loop: lda (_chptr),y
         beq !+
         jsr chrout
         iny
         bne _loop
!:      pla
         sta _chptr+1
         pla
        sta _chptr
         rts



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
         cmp #0
         beq !+
       lda #87        
         jmp !++
!:     lda #81
!:       ldy #0
         sta (_chptr),Y
       lda #0
         rts
render:
         jsr construct
       lda scrmode
         beq !+
       lda #0
         rts
!:     lda box_height
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
!:       dey
         sta (_chptr),y
         bne !-
        
         sty box_width_working
         ldy #top_left
       lda (_styleptr),Y
         ldy box_width_working
         sta (_chptr),y

         dec box_height_working

        // middle lines
_mid:    clc
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
!:       dey
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
!:       dey
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
!:     lda box_select
         beq !+
       lda #cyan
         jmp !++
!:     lda box_frame_colour
!:       sta box_colour_working
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
!:       sta 199

       lda box_legend
         ldx box_legend+1
         jsr printstr
!:     lda #0
         rts        
        
_colframe:
       lda box_colour_working
         ldy box_width_working
!:       dey
         sta (_chptr),Y
         bne !-
         dec box_height_working
        
!:       clc
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
!:       dey
         sta (_chptr),Y
         bne !-
       lda #0
         rts
        
_colbox:
!:     lda box_colour_working
         ldy box_width_working
!:       dey
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


toggle_fullscreen:
       lda #0
         sta multicolour
         jmp _toggle_fullscreen

toggle_fullscreen_multi:
       lda #8
         sta multicolour

_toggle_fullscreen:
      lda #$01
        eor scrmode
        sta scrmode
        cmp #0
        bne _enter_fullscreen
        jmp leave_fullscreen
_enter_fullscreen:
        ldy #[box_colour-box_origin]
      lda [boxColB+jmp_header_size],Y
        sta VIC_back_0
      lda [boxColR+jmp_header_size],Y
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
!:    lda #$0
        ldy #0
!:      sta (_chptr),Y
        dey
        bne !-
        inc _chptr+1
      lda _chptr+1
        cmp #$58
        bne !--

       //Character colour for HI-RES 2 colour mode
        ldy #[box_colour-box_origin]
      lda [boxColP+jmp_header_size],Y // upper nybble pixel set colour
        rol
        rol
        rol
        rol
       
        ora [boxColB+jmp_header_size],Y  // lower nybble pixel set colour      


//        ora multicolour // set multicolour mode
             
        ldy #0
      lda #$73
!:      sta screen_mem,Y
        sta screen_mem+250,Y
        sta screen_mem+500,Y
        sta screen_mem+750,Y
        iny
        cpy #250
        bne !-
      lda#0
        rts

leave_fullscreen:
      lda #0
        sta scrmode
       cls()
       screen_col(black, black)

      lda VIC_control_mem //Point screen memory at $0400
        and #$0F
        ora #$10
        sta VIC_control_mem
       
      lda VIC_control_1
        and #$DF
        sta VIC_control_1

      lda #0
        rts
 
automata:
         jsr toggle_fullscreen
       lda scrmode
         beq !+
        //JSR initialise_ptrs_automata
        //JSR initialise_cells_automata
       lda #yellow
         jmp !++
!:     lda #orange
!:       sta VIC_border
       lda #0
         rts
        
continue:
       lda #0
         cmp scrmode
         beq !+
         jsr initialise_ptrs_automata4
         jsr _render_automata_row
!:     lda #0
         rts
        
initialise_ptrs_automata:
        // initate pointers
       lda #<bitmap
         sta row_start
       lda #>bitmap
         sta row_start+1
        
       lda #[25*8]
         sta row_counter
        
       lda cellsrc
         sta _tempptr
       lda cellsrc+1
         sta _tempptr+1
         rts

initialise_cells_automata:
         rts        
        // clear  and initailise src buffer
         ldy #[box_check-box_origin]
       lda[boxRandom+jmp_header_size],Y
         cmp #0
         beq _random_init

_one_cell_init:
         ldy #[8*20]
       lda #0
!:       sta (_tempptr),Y
         dey
         bne !-
       lda #01
         sta cellbuffer1+80
         jmp  _render_automata_row
       
_random_init:
         ldy #[8*20] 
!:     lda 256,Y
         and #01
         sta (_tempptr),Y
         dey
         bne !-

_render_automata_row:
         clc
       lda cellsrc
         adc #1
         sta _tempptr
       lda cellsrc+1
         adc #0
         sta _tempptr+1

       lda row_start
         sta _chptr
       lda row_start+1
         sta _chptr+1

       lda #40
         sta col_counter      
        
        // render new row
        
        //Temp test for pixel writing
      lda#0
        rts
        
        
        
_render_automata_col:
        //collect 8 pixels from buffer
         ldx #8
         ldy #0
!:       clc
       lda pixel_acc
         asl
         sta pixel_acc
       lda (_tempptr),Y
         and #01
         ora pixel_acc
         sta pixel_acc
         iny
         dex
         bne !-
         pha
         clc
       lda #8
         adc _tempptr
         sta _tempptr
       lda #0
         adc _tempptr+1
         sta _tempptr+1 
         pla     
        
                
        //write 8 pixels to screen
         ldy #0
         sta (_chptr),Y
        
        //advance screen pointer to next 8 pixels
         clc
       lda _chptr
         adc #$08
         sta _chptr
       lda _chptr+1
         adc #0
         sta _chptr+1
                
        //repeat till end of buffer
         dec col_counter
         bne _render_automata_col
        
        //repeat till end of screen
        //advance row  start
         dec row_counter
         clc
       lda #$01
         adc row_start
         sta row_start
       lda #$00
         adc row_start+1
         sta row_start+1        
        
       lda row_counter
         and #$0F
         cmp #0
         bne !+ 
         clc
       lda #$30
         adc row_start
         sta row_start
       lda #$01
         adc row_start+1
         sta row_start+1  
       
        // calculate new row into dst using src
!:     lda cellsrc
         sta _chptr
       lda cellsrc+1
         sta _chptr+1
        
       lda celldst
         sta _tempptr
       lda celldst+1
         sta _tempptr+1
               
        //exchange last first  and cells
         ldy #160
       lda (_chptr),Y
         ldy #0
         sta (_chptr),Y
         ldy #1
       lda (_chptr),Y
         ldy #161
         sta (_chptr),Y                         
                             
         ldy #1
        
!:       ldx #0
         stx _styleptr
         dey
         txa
         cmp (_chptr),Y
         beq !+
       lda _styleptr
         ora #1
         sta _styleptr       
        
!:       iny
         txa
         cmp (_chptr),Y
         beq !+ 
       lda _styleptr       
         ora #2
         sta _styleptr
                              
!:       iny
         txa
         cmp (_chptr),Y
         beq !+
       lda _styleptr
         ora #4
         sta _styleptr
                
!:       tya
         pha
        
         ldy _styleptr
         ldx rule,Y 
                
         pla
         tay
        
         txa
         dey     
         sta (_tempptr),Y
         iny       
         
         cpy #161
         bne !----                     

        //swap pointers
       lda _chptr
         sta celldst
       lda _chptr+1
         sta celldst+1
        
       lda _tempptr
         sta cellsrc
       lda _tempptr+1
         sta cellsrc+1       
       
       lda row_counter
         cmp #0
         beq !+
         jmp _render_automata_row
                
!:     lda #0 //Dont signal exit 
         rts


automata4:
         jsr toggle_fullscreen_multi
       lda scrmode
         beq !+
         jsr initialise_ptrs_automata4
         jsr initialise_cells_automata4
!:     lda #0
         rts
        
continue4:
       lda #0
         cmp scrmode
         beq !+
         jsr initialise_ptrs_automata4
         jsr _render_automata_row4
!:     lda #0
         rts            
        
initialise_ptrs_automata4:
        // initate pointers
       lda #<bitmap
         sta row_start
       lda #>bitmap
         sta row_start+1
        
       lda#[11*16]
         sta row_counter        
        
       lda cellsrc
         sta _tempptr
       lda cellsrc+1
         sta _tempptr+1
         rts

initialise_cells_automata4:     
        // clear  and initailise src buffer
         ldy #[box_check-box_origin]
       lda [boxRandom+jmp_header_size],Y
         cmp #0
         beq _random_init4              

_one_cell_init4:      
         ldy #[4*20]+2        
        lda #0
!:       sta (_tempptr),Y
         dey
         bne !-
        lda #03
         sta cellbuffer1+40
         jmp  _render_automata_row4
       
_random_init4:
        lda $A2
        clc
        ldy #[4*20]+2                
!:      adc 0,Y
        pha
        and #03
        sta (_tempptr),Y
        pla
        dey
        bne !-
                              
_render_automata_row4:
         clc
       lda cellsrc
         adc #1          //Start 1 cell in to allow for wrapping
         sta _tempptr
       lda cellsrc+1
         adc #0
         sta _tempptr+1

       lda row_start
         sta _chptr
       lda row_start+1
         sta _chptr+1

       lda #20
         sta col_counter      
        
        // render new row
        
_render_automata_col4:
        //collect 4 pixels from buffer
         ldx #4
         ldy #0
         sty pixel_acc
!:       clc
       lda pixel_acc
         asl
         asl
         sta pixel_acc
       lda (_tempptr),Y
         and #03
         ora pixel_acc
         sta pixel_acc
         iny
         dex
         bne !-
         pha
         clc
       lda #4
         adc _tempptr
         sta _tempptr
       lda #0
         adc _tempptr+1
         sta _tempptr+1 
         pla     
        
                
        //write 4 multicolour pixels to screen
         ldy #0
         sta (_chptr),Y
        
        //advance screen pointer to next 4 pixels
         clc
       lda _chptr
         adc #$10        //bytes in a double height programmable character
         sta _chptr
       lda _chptr+1
         adc #0
         sta _chptr+1
                
        //repeat till end of buffer
         dec col_counter
         bne _render_automata_col4
        
        //repeat till end of screen
        //advance row  start
         dec row_counter
         clc
       lda #$01
         adc row_start
         sta row_start
       lda #$00
         adc row_start+1
         sta row_start+1
        
       lda row_counter
         and #$0F
         cmp #0
         bne !+
         clc
       lda #$30
         adc row_start
         sta row_start
       lda #$01
         adc row_start+1
         sta row_start+1
       
        // calculate new row into dst using src
!:     lda cellsrc
         sta _chptr
       lda cellsrc+1
         sta _chptr+1
        
       lda celldst
         sta _tempptr
       lda celldst+1
         sta _tempptr+1
               
        //exchange last first  and cells
         ldy #80
       lda (_chptr),Y
         ldy #0
         sta (_chptr),Y

         ldy #1
       lda (_chptr),Y
         ldy #81
         sta (_chptr),Y

         ldy #0
        
!:       dey
       lda (_chptr),Y    //Previous cell
         iny
         adc (_chptr),Y    //Current cell
         iny
         adc (_chptr),Y    //Next cell
         dey               //Set cell index back to current
         tax               //Summed cells to X
         tya
         pha               //Push current index
         txa
         tay
         ldx rule4,Y        //Look up summed value via rule into X
        
         pla               //Recover index from  stack
         tay
        
         txa
         sta (_tempptr),Y  //Save new cell value at current index on output ptr
         iny               //Advance current index
        
         cpy #81          //Repeat until all cells processed
         bne !-
        
        //swap pointers
       lda _chptr
         sta celldst
       lda _chptr+1
         sta celldst+1
        
       lda _tempptr
         sta cellsrc
       lda _tempptr+1
         sta cellsrc+1
        
       lda row_counter
         cmp #0
         beq !+
         jmp _render_automata_row4
        
!:     lda#0 //Dont signal exit 
         rts


update_ruleb:
         sec
         sbc #48
         tay
       lda rule,Y
         eor #1
         sta rule,Y
         cmp #1
         beq !+
       lda #48
         jmp !++
!:     lda #49
!:       sta str_rule,Y
       lda #0
         rts
        
render_ruleb:
         ldy #0
!:     lda rule,Y
         cmp #1
         beq !+
       lda #48
         jmp !++
!:     lda #49
!:       sta str_rule,Y
         iny
         cpy #8
         bne !---
        
         jsr render
       lda #0        
         rts
        
update_rule4:
         sec
         sbc #48
         tay
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
!:     lda (_chptr),Y
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
        
!:     lda #KEY_SPACE
         cmp keypress
         bne !+
         ldy #method_continue
         jmp reinvokevirtual
        
!:     lda #KEY_ESC
         cmp keypress
         bne !+
         ldy #method_escape
         jmp reinvokevirtual
        
!:     lda #0 //Dont signal program end
         rts

handlerulekeyb:
         jsr construct
        loadObjectByteY(box_select)
         beq !+
       lda keypress
         cmp #48
         bcc !+
         cmp #56
         bcs !+
         ldy #method_action
         jsr reinvokevirtual
!:     lda #0 //Dont signal program end
         rts
        
handlerulekey4:
         jsr construct
        loadObjectByteY(box_select)
         beq !+++
       lda keypress
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
                
!:       cmp #83 //S for Save
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
        
!:       cmp #76 //L for Load
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
!:     lda #0 //Dont signal program end
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
!:     lda #0 //Dont signal program end
         rts
!:     lda (this),Y
         clc
         adc #1
!:       and #15
         sta (this),Y
       lda #1
        saveObjectByte(box_edited)
         jmp !---
!:     lda (this),Y
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
!:       jsr rdBank
!:     lda #0 //Dont signal program end
         rts
!:     lda (this),Y
         jsr writeBank
         clc
         adc #1
!:       and #$0F
         sta (this),Y
         jmp !----
!:     lda (this),Y
         jsr writeBank
         sec
         sbc #1
         jmp !--
        
writeBank:
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
       lda #0
         adc _chptr+1
         sta _chptr+1 

       lda #<rule4
         sta _tempptr
       lda #>rule4
         sta _tempptr+1        
          
         ldy #10
!:       dey
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
!:       dey
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
!:       adc #48
!:       ldy #0
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
     bne !+
     inc selected
     jmp _key_handledf
!: lda #0 //Don't signal exit
     rts    
    
_key_handledf:
    callMethod(method_deselect, _boxlist)
   lda selected
     bne !+
   lda #boxes_list_size-1
     jmp !++
!:   cmp #boxes_list_size
     bcc !+
   lda #1
!:   sta selected
     sta _scratch+4
   lda #method_select
     sta method
   lda selected
     jsr _boxlistAt
   lda #0 //Don't signal exit
     rts

_boxlist:
   ldy #0
   sty return
!: lda boxes+1,Y
   ldx boxes+2,Y
   sta _scratch+7   
   tya
   pha
   lda _scratch+7  
  
   ldy method
   jsr invokevirtual
   cmp #0
   beq !+
   sta return 
!:  pla
   tay
   iny
   iny 
   cpy boxes
   bcc !--
   beq !--
 lda return
   rts

   ldy #0
   sty return
!:lda boxes+1,Y
   iny
   ldx boxes+1,Y
   iny
   sty _scratch+1
  
   ldy method
   jsr invokevirtual
   cmp #0
   beq !+
   sta return 
!:  ldy _scratch+1 
   cpy boxes
   bcc !--
   beq !--
 lda return
   rts


_boxListAt:
     asl
     tay
   lda boxes+1,Y
     ldx boxes+2,Y
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
!:     lda (this),Y
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

 
      
flow:
  jmp flowVtable
.byte 1
.word keys_pressed 
.byte 0   
     
boxRun:
  jmp confirmboxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 17 + [X_CHARS*0]
.word colour_mem + 17 + [X_CHARS*0]
.byte 18,2,5,5
.byte cyan,white
.word  style1
.word str_run
.byte 0
.byte 0
.byte 0

boxRuleBinary:
  jmp binaryruleVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 0 + [X_CHARS*0]
.word colour_mem + 0 + [X_CHARS*0]
.byte 2,2,12,5
.byte white,white
.word  style3
.word str_rule
.byte 1
.byte 0
.byte 0


boxRandom:
  jmp toggleBoxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 2 + [X_CHARS*6]
.word colour_mem + 2 + [X_CHARS*6]
.byte 2,5,3,3
.byte cyan,white
.word  style1
.word str_rnd
.byte 0
.byte 0
.byte 0

boxColB:
  jmp colourboxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 7 + [X_CHARS*6]
.word colour_mem + 7 + [X_CHARS*6]
.byte 7,5,3,3
.byte blue,white
.word  style3
.word str_back
.byte 0
.byte 0
.byte 0

boxColR:
  jmp colourboxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 11 + [X_CHARS*6]
.word colour_mem + 11 + [X_CHARS*6]
.byte 11,5,3,3
.byte green,white
.word  style3
.word str_bord
.byte 0
.byte 0
.byte 0

boxColP:
  jmp colourboxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 15 + [X_CHARS*6]
.word colour_mem + 15 + [X_CHARS*6]
.byte 15,5,3,3
.byte yellow,white
.word  style3
.word str_pen
.byte 0
.byte 0
.byte 0

boxColA:
  jmp colourboxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 19 + [X_CHARS*6]
.word colour_mem + 19 + [X_CHARS*6]
.byte 19,5,3,3
.byte red,white
.word  style3
.word str_aux
.byte 0
.byte 0
.byte 0

boxRule4Index:
  jmp rule4IndexVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 0 + [X_CHARS*11]
.word colour_mem + 0 + [X_CHARS*11]
.byte 0,10,3,3
.byte white,white
.word  style3
.word str_ind
.byte 0
.byte 0
.byte 0

boxRuleBit4:
  jmp bit4ruleVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 3 + [X_CHARS*10]
.word colour_mem + 3 + [X_CHARS*10]
.byte 5,12,14,5
.byte white,white
.word  style3
.word str_rule4
.byte 0
.byte 0
.byte 0

boxRun4:
  jmp confirmboxes4Vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 17 + [X_CHARS*10]
.word colour_mem + 17 + [X_CHARS*10]
.byte 18,12,5,5
.byte cyan,white
.word  style1
.word str_run
.byte 0
.byte 0
.byte 0
    
boxExit:
  jmp exitboxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 11 + [X_CHARS*19]
.word colour_mem + 11 + [X_CHARS*19]
.byte 12,20,11,3
.byte cyan,white
.word  style1
.word str_exit
.byte 0
.byte 0
.byte 0

boxFinal:
  jmp boxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 1 + [X_CHARS*1]
.word colour_mem + 1 + [X_CHARS*1]
.byte 2,2,X_CHARS-2,Y_CHARS-2
.byte white,red
.word  style2
.word 0
.byte 0
.byte 0
.byte 0

cellsrc:
.word cellbuffer1
celldst:
.word cellbuffer2
rule:
.byte 0,1,1, 1,1,0, 0,0
ruledec:
.byte 30
rule4:
.byte 1,2,3, 0,1,2, 2,0,3, 2
endrule4:

rule4index:
.byte 0

rule4bank:
.byte 1,2,3, 0,1,2, 2,0,3, 2, 6,5,7,2,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 6,5,7,2,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 6,5,7,2,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 6,5,7,2,0,0

.byte 0,0,0, 0,0,0, 0,0,0, 0, 6,5,7,2,0,0
.byte 1,1,1, 1,1,1, 1,1,1, 1, 6,5,7,2,0,0
.byte 2,2,2, 2,2,2, 2,2,2, 2, 6,5,7,2,0,0
.byte 3,3,3, 3,3,3, 3,3,3, 3, 6,5,7,2,0,0

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
.byte 22
.word flow
.word boxRuleBinary
.word boxRun
.word boxRandom
.word boxColB
.word boxColR
.word boxColP
.word boxColA
.word boxRule4Index
.word boxRuleBit4
.word boxRun4
.word boxExit

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
str_filenameL: .text "RULE"
.byte 0
str_filenameS: .text "str_0:RULE"
.byte 0
str_rule: .text "********"
str_rule4: .text "**********"
style1: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
style2: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
style3: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
style4: .byte 98+128, 98, 97+128, 97, 127, 255, 255, 127, 102


boxesVtable:
     jsr doJumpTable
    .word render, handlekey, get, select, deselect, empty, empty, empty, empty
 
exitboxesVtable:
     jsr doJumpTable 
    .word render, handlekey, get, select, deselect, exit, empty, empty, empty

confirmboxesVtable:
     jsr doJumpTable    
    .word render, handlekey, get, select, deselect, automata, empty, leave_fullscreen, continue
    
confirmboxes4Vtable:
     jsr doJumpTable    
    .word render, handlekey, get, select, deselect, automata4, empty, leave_fullscreen, continue4   
    
colourboxesVtable:
     jsr doJumpTable    
    .word render, handlekeyc, get, select, deselect, empty, empty, empty, empty       
    
rule4IndexVtable:
     jsr doJumpTable    
    .word render, handlekeyi, get, select, deselect, empty, render_index, empty, empty       
    
binaryruleVtable:
     jsr doJumpTable
    .word render_ruleb, handlerulekeyb, get, select, deselect, update_ruleb, empty, empty, empty    

bit4ruleVtable:
     jsr doJumpTable
    .word renderrule4, handlerulekey4, get, select, deselect, update_rule4, empty, empty, empty
    
flowVtable:
     jsr doJumpTable
    .word empty, flowKey, get, empty, empty, empty, empty, empty
    
toggleBoxesVtable:
     jsr doJumpTable
   .word render, handlekey, get, select, deselect, toggle, render_toggle, empty, empty


* = $4000 "Data"
// globals
_target: .word 0
_scratch: .byte 0,0,0,0,0,0,0,0
method: .byte 0
variable: .byte 0
selected: .byte 0
keypress: .byte 0
fullscreen: .byte 0
return: .byte 0

//automata globals
row_counter: .byte 0
col_counter: .byte 0
row_start: .word 0
multicolour: .byte 0


// args for box
box_origin: .word 0
box_col_origin: .word 0
box_x: .byte 0
box_y: .byte 0
box_width: .byte 0
box_height: .byte 0
box_colour: .byte 0
box_frame_colour: .byte 0
box_style: .word 0
box_legend: .word 0
box_select: .byte 0
box_check: .byte 0
box_edited: .byte 0


box_width_working: .byte 0
box_height_working: .byte 0
box_colour_working: .byte 0

// args for flow
keys_pressed: .byte 0 

cellbuffer1: .fill 322, 0
cellbuffer2: .fill 322, 0
pixel_acc: .byte 0

