.include "kernal.inc"
.include "macros.inc"
.outfile "Drive8/boxes.prg"

.org    $0
.word   $0801
.org    $0801

        .word next, 10       ; Next line and current line number
        .byte $9e,"2064",0   ; SYS 2064
next:   .word 0              ; End of program

.advance $0810

.text
    `cls
    `screen_col black, black
    LDA #0
    STA fullscreen
    STA return
    LDA #1
    STA selected
    JSR _key_handledf
    `callMethod method_render, _boxlist

_main_loop:    
    JSR waitkey
    STA keypress    
    `callMethod method_key, _boxList
    PHA ; Use key methods return values
    `callMethod method_render, _boxlist
    PLA
    BNE done
    LDA _scratch+4 ; debug
    STA screen_mem
    JMP _main_loop    
       
done:
    JSR leave_fullscreen
    LDA #<boxFinal
    LDX #>boxFinal
    LDY #0
    JSR invokevirtual
    LDA #0
    STA $800
    STA $801
    STA $802
    RTS

waitkey:
*   JSR getin
    CMP #0
    BEQ -    
    RTS

printstr:
        TAY
        LDA _chptr
        PHA
        LDA _chptr+1
        PHA
        TYA
        STA _chptr
        STX _chptr+1
        LDY #$00
_loop:  LDA (_chptr),y
        BEQ +
        JSR chrout
        INY
        BNE _loop
*       PLA
        STA _chptr+1
        PLA
        STA _chptr
        RTS

.data zp
.org zero_page_rs_232
.space this 2
.space _chptr 2
.space _styleptr 2
.space _tempptr 2

.text

.macro getInstanceVariable
    ; _1 variable
    ; _2 Instance
    ; Box instance
        LDA #[_1-box_origin]
        STA var
        LDA #<_2
        LDX #>_2
        LDY #method_get
        JSR invokevirtual           
.macend

get:
        JSR construct
        LDY var
        LDA (this),Y
        RTS

select:
        JSR construct
        LDY #[box_select-box_origin]
        LDA #1
        STA (this),Y
        LDA #0
        RTS
        
deselect:
        JSR construct
        LDY #[box_select-box_origin]
        LDA #0
        STA (this),Y
        LDA #0        
        RTS
                       
toggle:
        JSR construct
        `loadObjectByte box_check
        EOR #1
        STA (this),Y
        LDA #0
        RTS
        
render_toggle:
        JSR construct
        CLC
        LDA box_origin
        ADC #X_CHARS+1
        STA _chptr
        LDA box_origin+1
        ADC #0 
        STA _chptr+1                

        `loadObjectByte box_check
        CMP #0
        BEQ +
        LDA #87        
        JMP ++
*       LDA #81
*       LDY #0
        STA (_chptr),Y
        LDA #0
        RTS
render:
        JSR construct
        LDA fullscreen
        BEQ +
        LDA #0
        RTS
*       LDA box_height
        STA box_height_working
        
        `loadObjectByte box_select
        CMP #0
        BEQ _notselected
        LDA #<style2
        STA _styleptr
        LDA #>style2
        STA _styleptr+1
        JMP _style_done
        
_notselected:
        `loadObjectPointer box_style, _styleptr
_style_done:
        `loadObjectPointer box_origin, _chptr             
                                               
        ; Top line
        LDY box_width
        DEY
        STY box_width_working
        LDY #top_right
        LDA (_styleptr),Y
        LDY box_width_working
        STA (_chptr),Y
        
        STY box_width_working
        LDY #top
        LDA (_styleptr),Y
        LDY box_width_working
*       DEY
        STA (_chptr),y
        BNE -
        
        STY box_width_working
        LDY #top_left
        LDA (_styleptr),Y
        LDY box_width_working
        STA (_chptr),y

        DEC box_height_working

        ; middle lines
_mid:   CLC
        LDA #X_CHARS
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1
        LDY box_width
           
        STY box_width_working
        LDY #right
        LDA (_styleptr),Y
        LDY box_width_working
        DEY
        STA (_chptr),y
        STY box_width_working
        LDY #fill
        LDA (_styleptr),Y
        LDY box_width_working
*       DEY
        STA (_chptr),y
        BNE -
        STY box_width_working
        LDY #left
        LDA (_styleptr),Y
        LDY box_width_working
        STA (_chptr),y
            
        DEC box_height_working
        BNE _mid
        ; bottom line
        LDY box_width
        STY box_width_working
        LDY #bottom_right
        LDA (_styleptr),Y
        LDY box_width_working
        DEY
        STA (_chptr),y
        STY box_width_working
        LDY #bottom
        LDA (_styleptr),Y
        LDY box_width_working
*       DEY
        STA (_chptr),y
        BNE -
        STY box_width_working
        LDY #bottom_left
        LDA (_styleptr),Y
        LDY box_width_working
        STA (_chptr),y
 
;Fill in colour

        LDA box_col_origin
        STA _chptr
        LDA box_col_origin+1
        STA _chptr+1
        
        LDA box_height
        STA box_height_working
        LDA box_width
        STA box_width_working
        LDA box_edited
        BEQ +
        LDA #red
        JMP +++
*       LDA box_select
        BEQ +
        LDA #cyan
        JMP ++
*       LDA box_frame_colour
*       STA box_colour_working
        JSR _colframe

        CLC
        LDA box_col_origin
        ADC #X_CHARS+1
        STA _chptr
        LDA box_col_origin+1 
        ADC #0
        STA _chptr+1
        CLC
        LDA box_height
        SBC #1
        STA box_height_working
        CLC
        LDA box_width
        SBC #1
        STA box_width_working
        LDA box_colour
        STA box_colour_working
        JSR _colbox
        
;print legend
        LDA box_legend
        BEQ ++
        CLC
        LDX box_y
        LDY box_x
        JSR plot
        
        LDA box_colour
        STA chrout_colour
        
        LDA #1
        CMP box_select
        BEQ +
        LDA #0
*       STA 199

        LDA box_legend
        LDX box_legend+1
        JSR printstr
*       LDA #0
        RTS        
        
_colframe:
        LDA box_colour_working
        LDY box_width_working
*       DEY
        STA (_chptr),Y
        BNE -
        DEC box_height_working
        
*       CLC
        LDA #X_CHARS
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1
        LDY box_width_working
        DEY
        LDA box_colour_working
        STA (_chptr),Y
        LDY #0
        STA (_chptr),Y
        DEC box_height_working
        BNE -
        
        LDY box_width_working
*       DEY
        STA (_chptr),Y
        BNE -
        LDA #0
        RTS
        
_colbox:
*       LDA box_colour_working
        LDY box_width_working
*       DEY
        STA (_chptr),Y
        BNE -
        CLC
        LDA #X_CHARS
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1
        DEC box_height_working
        BNE --
        LDY #method_detail
        JSR reinvokevirtual
        LDA #0
        RTS 


toggle_fullscreen:
        LDA #0
        STA multicolour
        JMP _toggle_fullscreen

toggle_fullscreen_multi:
        LDA #8
        STA multicolour

_toggle_fullscreen:
       LDA #$01
       EOR fullscreen
       STA fullscreen
       CMP #0
       BNE _enter_fullscreen
       JMP leave_fullscreen
_enter_fullscreen:
       LDY #[box_colour-box_origin]
       LDA [boxColB+jmp_header_size],Y
       STA VIC_back_0
       LDA [boxColR+jmp_header_size],Y
       STA VIC_border
       
       LDA VIC_control_mem ;Point screen memory at $2000
       AND #$0F
       ORA #$80
       STA VIC_control_mem
       
       LDA VIC_control_1
       ORA #$20
       STA VIC_control_1
             
       ;Clear character map
       LDA #<bitmap
       STA _chptr
       LDA #>bitmap
       STA _chptr+1
*      LDA #$0
       LDY #0
*      STA (_chptr),Y
       DEY
       BNE -
       INC _chptr+1
       LDA _chptr+1
       CMP #$58
       BNE --

       ;Character colour for HI-RES 2 colour mode
       LDY #[box_colour-box_origin]
       LDA [boxColP+jmp_header_size],Y ; upper nybble pixel set colour
       ROL
       ROL
       ROL
       ROL
       
       ORA [boxColB+jmp_header_size],Y  ; lower nybble pixel set colour      


;       ORA multicolour ; set multicolour mode
             
       LDY #0
       LDA #$73
*      STA screen_mem,Y
       STA screen_mem+250,Y
       STA screen_mem+500,Y
       STA screen_mem+750,Y
       INY
       CPY #250
       BNE -
       LDA #0
       RTS

leave_fullscreen:
       LDA #0
       STA fullscreen
      `cls
      `screen_col black, black

       LDA VIC_control_mem ;Point screen memory at $0400
       AND #$0F
       ORA #$10
       STA VIC_control_mem
       
       LDA VIC_control_1
       AND #$DF
       STA VIC_control_1

       LDA #0
       RTS
 
automata:
        JSR toggle_fullscreen
        LDA fullscreen
        BEQ +
        ;JSR initialise_ptrs_automata
        ;JSR initialise_cells_automata
        LDA #yellow
        JMP ++
*       LDA #orange
*       STA VIC_border
        LDA #0
        RTS
        
continue:
        LDA #0
        CMP fullscreen
        BEQ +
        JSR initialise_ptrs_automata4
        JSR _render_automata_row
*       LDA #0
        RTS
        
initialise_ptrs_automata:
        ; initate pointers
        LDA #<bitmap
        STA row_start
        LDA #>bitmap
        STA row_start+1
        
        LDA #[25*8]
        STA row_counter
        
        LDA  cellsrc
        STA _tempptr
        LDA  cellsrc+1
        STA _tempptr+1
        RTS

initialise_cells_automata:
        RTS        
        ; clear and initailise src buffer
        LDY #[box_check-box_origin]
        LDA [boxRandom+jmp_header_size],Y
        CMP #0
        BEQ _random_init

_one_cell_init:
        LDY #[8*20]
        LDA #0
*       STA (_tempptr),Y
        DEY
        BNE -
        LDA #01
        STA cellbuffer1+80
        JMP  _render_automata_row
       
_random_init:
        LDY #[8*20] 
*       LDA 256,Y
        AND #01
        STA (_tempptr),Y
        DEY
        BNE -

_render_automata_row:
        CLC
        LDA  cellsrc
        ADC #1
        STA _tempptr
        LDA  cellsrc+1
        ADC #0
        STA _tempptr+1

        LDA row_start
        STA _chptr
        LDA row_start+1
        STA _chptr+1

        LDA #40
        STA col_counter      
        
        ; render new row
        
        ;Temp test for pixel writing
;        LDA #$55
;        STA $2001
       LDA #0
       RTS
        
        
        
_render_automata_col:
        ;collect 8 pixels from buffer
        LDX #8
        LDY #0
*       CLC
        LDA pixel_acc
        ASL
        STA pixel_acc
        LDA (_tempptr),Y
        AND #01
        ORA pixel_acc
        STA pixel_acc
        INY
        DEX
        BNE -
        PHA
        CLC
        LDA #8
        ADC _tempptr
        STA _tempptr
        LDA #0
        ADC _tempptr+1
        STA _tempptr+1 
        PLA     
        
                
        ;write 8 pixels to screen
        LDY #0
        STA (_chptr),Y
        
        ;advance screen pointer to next 8 pixels
        CLC
        LDA _chptr
        ADC #$08
        STA _chptr
        LDA _chptr+1
        ADC #0
        STA _chptr+1
                
        ;repeat till end of buffer
        DEC col_counter
        BNE _render_automata_col
        
        ;repeat till end of screen
        ;advance row start
        DEC row_counter
        CLC
        LDA #$01
        ADC row_start
        STA row_start
        LDA #$00
        ADC row_start+1
        STA row_start+1        
        
        LDA row_counter
        AND #$0F
        CMP #0
        BNE + 
        CLC
        LDA #$30
        ADC row_start
        STA row_start
        LDA #$01
        ADC row_start+1
        STA row_start+1  
       
        ; calculate new row into dst using src
*       LDA cellsrc
        STA _chptr
        LDA cellsrc+1
        STA _chptr+1
        
        LDA celldst
        STA _tempptr
        LDA celldst+1
        STA _tempptr+1
               
        ;exchange last first and cells
        LDY #160
        LDA (_chptr),Y
        LDY #0
        STA (_chptr),Y
        LDY #1
        LDA (_chptr),Y
        LDY #161
        STA (_chptr),Y                         
                             
        LDY #1
        
*       LDX #0
        STX _styleptr
        DEY
        TXA
        CMP (_chptr),Y
        BEQ +
        LDA _styleptr
        ORA #1
        STA _styleptr       
        
*       INY
        TXA
        CMP (_chptr),Y
        BEQ + 
        LDA _styleptr       
        ORA #2
        STA _styleptr
                              
*       INY
        TXA
        CMP (_chptr),Y
        BEQ +
        LDA _styleptr
        ORA #4
        STA _styleptr
                
*       TYA
        PHA
        
        LDY _styleptr
        LDX rule,Y 
                
        PLA
        TAY
        
        TXA
        DEY     
        STA (_tempptr),Y
        INY       
         
        CPY #161
        BNE ----                     

        ;swap pointers
        LDA _chptr
        STA celldst
        LDA _chptr+1
        STA celldst+1
        
        LDA _tempptr
        STA cellsrc
        LDA _tempptr+1
        STA cellsrc+1       
       
        LDA row_counter
        CMP #0
        BEQ +
        JMP _render_automata_row
                
*       LDA #0 ;Dont signal exit 
        RTS


automata4:
        JSR toggle_fullscreen_multi
        LDA fullscreen
        BEQ +
        JSR initialise_ptrs_automata4
        JSR initialise_cells_automata4
*       LDA #0
        RTS
        
continue4:
        LDA #0
        CMP fullscreen
        BEQ +
        JSR initialise_ptrs_automata4
        JSR _render_automata_row4
*       LDA #0
        RTS            
        
initialise_ptrs_automata4:
        ; initate pointers
        LDA #<bitmap
        STA row_start
        LDA #>bitmap
        STA row_start+1
        
        LDA #[11*16]
        STA row_counter        
        
        LDA  cellsrc
        STA _tempptr
        LDA  cellsrc+1
        STA _tempptr+1
        RTS

initialise_cells_automata4:     
        ; clear and initailise src buffer
        LDY #[box_check-box_origin]
        LDA [boxRandom+jmp_header_size],Y
        CMP #0
        BEQ _random_init4              

_one_cell_init4:      
        LDY #[4*20]+2        
        LDA #0
*       STA (_tempptr),Y
        DEY
        BNE -
        LDA #03
        STA cellbuffer1+40
        JMP  _render_automata_row4
       
_random_init4:
       LDA $A2
       CLC
       LDY #[4*20]+2                
*      ADC 0,Y
       PHA
       AND #03
       STA (_tempptr),Y
       PLA
       DEY
       BNE -
                              
_render_automata_row4:
        CLC
        LDA  cellsrc
        ADC #1          ;Start 1 cell in to allow for wrapping
        STA _tempptr
        LDA  cellsrc+1
        ADC #0
        STA _tempptr+1

        LDA row_start
        STA _chptr
        LDA row_start+1
        STA _chptr+1

        LDA #20
        STA col_counter      
        
        ; render new row
        
_render_automata_col4:
        ;collect 4 pixels from buffer
        LDX #4
        LDY #0
        STY pixel_acc
*       CLC
        LDA pixel_acc
        ASL
        ASL
        STA pixel_acc
        LDA (_tempptr),Y
        AND #03
        ORA pixel_acc
        STA pixel_acc
        INY
        DEX
        BNE -
        PHA
        CLC
        LDA #4
        ADC _tempptr
        STA _tempptr
        LDA #0
        ADC _tempptr+1
        STA _tempptr+1 
        PLA     
        
                
        ;write 4 multicolour pixels to screen
        LDY #0
        STA (_chptr),Y
        
        ;advance screen pointer to next 4 pixels
        CLC
        LDA _chptr
        ADC #$10        ;bytes in a double height programmable character
        STA _chptr
        LDA _chptr+1
        ADC #0
        STA _chptr+1
                
        ;repeat till end of buffer
        DEC col_counter
        BNE _render_automata_col4
        
        ;repeat till end of screen
        ;advance row start
        DEC row_counter
        CLC
        LDA #$01
        ADC row_start
        STA row_start
        LDA #$00
        ADC row_start+1
        STA row_start+1
        
        LDA row_counter
        AND #$0F
        CMP #0
        BNE +
        CLC
        LDA #$30
        ADC row_start
        STA row_start
        LDA #$01
        ADC row_start+1
        STA row_start+1
       
        ; calculate new row into dst using src
*       LDA cellsrc
        STA _chptr
        LDA cellsrc+1
        STA _chptr+1
        
        LDA celldst
        STA _tempptr
        LDA celldst+1
        STA _tempptr+1
               
        ;exchange last first and cells
        LDY #80
        LDA (_chptr),Y
        LDY #0
        STA (_chptr),Y

        LDY #1
        LDA (_chptr),Y
        LDY #81
        STA (_chptr),Y

        LDY #0
        
*       DEY
        LDA (_chptr),Y    ;Previous cell
        INY
        ADC (_chptr),Y    ;Current cell
        INY
        ADC (_chptr),Y    ;Next cell
        DEY               ;Set cell index back to current
        TAX               ;Summed cells to X
        TYA
        PHA               ;Push current index
        TXA
        TAY
        LDX rule4,Y        ;Look up summed value via rule into X
        
        PLA               ;Recover index from stack
        TAY
        
        TXA
        STA (_tempptr),Y  ;Save new cell value at current index on output ptr
        INY               ;Advance current index
        
        CPY #81          ;Repeat until all cells processed
        BNE -
        
        ;swap pointers
        LDA _chptr
        STA celldst
        LDA _chptr+1
        STA celldst+1
        
        LDA _tempptr
        STA cellsrc
        LDA _tempptr+1
        STA cellsrc+1
        
        LDA row_counter
        CMP #0
        BEQ +
        JMP _render_automata_row4
        
*       LDA #0 ;Dont signal exit 
        RTS


update_ruleb:
        SEC
        SBC #48
        TAY
        LDA rule,Y
        EOR #1
        STA rule,Y
        CMP #1
        BEQ +
        LDA #48
        JMP ++
*       LDA #49
*       STA @rule,Y
        LDA #0
        RTS
        
render_ruleb:
        LDY #0
*       LDA rule,Y
        CMP #1
        BEQ +
        LDA #48
        JMP ++
*       LDA #49
*       STA @rule,Y
        INY
        CPY #8
        BNE ---
        
        JSR render
        LDA #0        
        RTS
        
update_rule4:
        SEC
        SBC #48
        TAY
        LDA #<rule4
        STA _chptr
        LDA #>rule4
        STA _chptr+1
        
        LDA #<@rule4
        STA _styleptr
        LDA #>@rule4
        STA _styleptr+1
        
        LDA (_chptr),Y
        CLC
        ADC #1
        AND #3
        STA (_chptr),Y
        ADC #48
        STA (_styleptr),Y
        LDA #0
        RTS
        
renderrule4:
        LDA #<rule4
        STA _chptr
        LDA #>rule4
        STA _chptr+1
        
        LDA #<@rule4
        STA _styleptr
        LDA #>@rule4
        STA _styleptr+1
        
        LDY #0
*       LDA (_chptr),Y
        CLC
        ADC #48
        STA (_styleptr),Y
        INY
        CPY #10
        BNE -
        JSR render
        RTS
        
handlekey:
        JSR construct
        `loadObjectByteY box_select
        BEQ +++
        
        LDA #KEY_RETURN
        CMP keypress
        BNE +
        LDY #method_action
        JMP reinvokevirtual
        
*       LDA #KEY_SPACE
        CMP keypress
        BNE +
        LDY #method_continue
        JMP reinvokevirtual
        
*       LDA #KEY_ESC
        CMP keypress
        BNE +
        LDY #method_escape
        JMP reinvokevirtual
        
*       LDA #0 ;Dont signal program end
        RTS

handlerulekeyb:
        JSR construct
        `loadObjectByteY box_select
        BEQ +
        LDA keypress
        CMP #48
        BCC +
        CMP #56
        BCS +
        LDY #method_action
        JSR reinvokevirtual
*       LDA #0 ;Dont signal program end
        RTS
        
handlerulekey4:
        JSR construct
        `loadObjectByteY box_select
        BEQ +++
        LDA keypress
        CMP #48
        BCC +
        CMP #58
        BCS +
        LDY #method_action
        JSR reinvokevirtual
        JSR construct
        LDA #1
        `saveObjectByte box_edited
        LDA #0 ;Dont signal program end
        RTS
                
*       CMP #83 ;S for Save
        BNE +
        
        ;JSR writeBank
        LDA #FILENO
        LDX #DEVICE
        LDY #1
        JSR setlfs

        LDA #[@rule-@filenameS]
        LDX #<@filenameS
        LDY #>@filenameS
        JSR setnam

        LDA #<rule4bank
        STA _chptr
        LDA #>rule4bank
        STA _chptr+1
        LDX #<rule4bankend
        LDY #>rule4bankend
        LDA #_chptr
        JSR save
        LDA #0
        `saveObjectByte box_edited
        LDA #0 ;Dont signal program end
        RTS
        
*       CMP #76 ;L for Load
        BNE +

        LDA #FILENO
        LDX #DEVICE
        LDY #1
        JSR setlfs

        LDA #[@filenameS-@filenameL]
        LDX #<@filenameL
        LDY #>@filenameL
        JSR setnam

        LDA #0      ;Load
        LDX #<rule4bank
        LDY #>rule4bank
        JSR load
        ;`getInstanceVariable box_check, boxRule4Index
        ; STA 4536

        ;JSR readBank
                
*       LDA #0 ;Dont signal program end
        RTS 
        
.alias DEVICE 10
.alias FILENO 1       
        
handlekeyc:
        JSR construct
        `loadObjectByteY box_select
        BEQ +
        LDY #[box_colour-box_origin]
        LDA keypress
        CMP #KEY_CSR_UP
        BEQ ++
        CMP #KEY_CSR_DOWN
        BEQ ++++
*       LDA #0 ;Dont signal program end
        RTS
*       LDA (this),Y
        CLC
        ADC #1
*       AND #15
        STA (this),Y
        LDA #1
        `saveObjectByte box_edited
        JMP ---
*       LDA (this),Y
        SEC
        SBC #1
        JMP --

handlekeyi:
        JSR construct
        `loadObjectByteY box_select
        BEQ ++
        LDY #[box_check-box_origin]
        LDA keypress
        CMP #KEY_CSR_UP
        BEQ +++
        CMP #KEY_CSR_DOWN
        BEQ +++++
        JMP ++
*       JSR readBank
*       LDA #0 ;Dont signal program end
        RTS
*       LDA (this),Y
        JSR writeBank
        CLC
        ADC #1
*       AND #$0F
        STA (this),Y
        JMP ----
*       LDA (this),Y
        JSR writeBank
        SEC
        SBC #1
        JMP --
        
writeBank:
        PHA
        STA _scratch
        TYA
        PHA
        TXA
        PHA
        
        LDA #<rule4bank
        STA _chptr
        LDA #>rule4bank
        STA _chptr+1
        LDA _scratch
        CLC
        ASL
        ASL
        ASL
        ASL
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1 

        LDA #<rule4
        STA _tempptr
        LDA #>rule4
        STA _tempptr+1        
          
        LDY #10
*       DEY
        LDA (_tempptr),Y
        STA (_chptr),Y
        CPY #0
        BNE -    
        
        PLA
        TAX
        PLA
        TAY
        PLA
        RTS
        
        
readBank:
        PHA
        STA _scratch
        TYA
        PHA
        TXA
        PHA

        LDA #<rule4bank
        STA _chptr
        LDA #>rule4bank
        STA _chptr+1
        LDA _scratch
        CLC
        ASL
        ASL
        ASL
        ASL
        ADC _chptr
        STA _chptr
        LDA #0
        ADC _chptr+1
        STA _chptr+1 


        LDA #<rule4
        STA _tempptr
        LDA #>rule4
        STA _tempptr+1        
          
        LDY #10
*       DEY
        LDA (_chptr),Y
        STA (_tempptr),Y
        CPY #0
        BNE -
        
        PLA
        TAX
        PLA
        TAY
        PLA
        RTS               
        
render_index:
        JSR construct
        CLC
        LDA box_origin
        ADC #X_CHARS+1
        STA _chptr
        LDA box_origin+1
        ADC #0
        STA _chptr+1                

        `loadObjectByte box_check
        TAX
        CPX #10
        BCC +   ;10 or more
        SBC #9
        JMP ++
*       ADC #48
*       LDY #0
        STA (_chptr),Y
        LDA #0
        RTS               
                                            
flowKey:
    LDA keypress  
    
    CMP #KEY_CSR_LEFT
    BNE _not_leftf
    DEC selected
    JMP _key_handledf
_not_leftf:
    CMP #KEY_CSR_RIGHT
    BNE +
    INC selected
    JMP _key_handledf
*   LDA #0 ;Don't signal exit
    RTS    
    
_key_handledf:
    `callMethod method_deselect, _boxlist
    LDA selected
    BNE +
    LDA #boxes_list_size-1
    JMP ++
*   CMP #boxes_list_size
    BCC +
    LDA #1
*   STA selected
    STA _scratch+4
    LDA #method_select
    STA method
    LDA selected
    JSR _boxlistAt
    LDA #0 ;Don't signal exit
    RTS

_boxList:
  LDY #0
  STY return
*  LDA boxes+1,Y
  LDX boxes+2,Y
  STA _scratch+7   
  TYA
  PHA
  LDA _scratch+7  
  
  LDY method
  JSR invokevirtual
  CMP #0
  BEQ +
  STA return 
*  PLA
  TAY
  INY
  INY 
  CPY boxes
  BCC --
  BEQ --
  LDA return
  RTS

  LDY #0
  STY return
*  LDA boxes+1,Y
  INY
  LDX boxes+1,Y
  INY
  STY _scratch+1
  
  LDY method
  JSR invokevirtual
  CMP #0
  BEQ +
  STA return 
*  LDY _scratch+1 
  CPY boxes
  BCC --
  BEQ --
  LDA return
  RTS


_boxListAt:
    ASL
    TAY
    LDA boxes+1,Y
    LDX boxes+2,Y
    LDY method
    JMP invokevirtual ;JSR,RTS
    
construct:
        LDY #3
        LDA (this),Y ; Fetch size of variables
        PHA
        INY
        LDA (this),Y ; Fetch fixed variable pointer low byte
        STA _chptr
        INY
        LDA (this),Y ; Fetch fixed variable pointer high byte
        STA _chptr+1 
        CLC        ;advance this pointer over vtable to point at data
        LDA this
        ADC #jmp_header_size
        STA this
        LDA this+1
        ADC #0
        STA this+1
        
        PLA
        TAY
*       LDA (this),Y
        STA (_chptr),Y
        DEY
        BPL -
        RTS

do’jump’table:
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
         STA this
         STX this+1
         JMP (this)
         
reinvokevirtual:
        PHA
        SEC        ;return this pointer to vtable
        LDA this
        SBC #jmp_header_size
        STA this
        LDA this+1
        SBC #0
        STA this+1
        PLA
        JMP (this)
         
empty:
        LDA #0
        RTS
        
exit:
        JSR leave_fullscreen
        LDA #1
        RTS

.alias method_render 0
.alias method_key 1
.alias method_get 2
.alias method_select 3
.alias method_deselect 4
.alias method_action 5
.alias method_detail 6
.alias method_escape 7
.alias method_continue 8
    
.alias jmp_header_size 6  
      
flow:
 JMP flow'vtable
.byte 1
.word keys_pressed 
.byte 0   
     
boxRun:
 JMP confirmboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 17 + [X_CHARS*0]
.word colour_mem + 17 + [X_CHARS*0]
.byte 18,2,5,5
.byte cyan,white
.word style1
.word @run
.byte 0
.byte 0
.byte 0

boxRuleBinary:
 JMP binaryrule'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 0 + [X_CHARS*0]
.word colour_mem + 0 + [X_CHARS*0]
.byte 2,2,12,5
.byte white,white
.word style3
.word @rule
.byte 1
.byte 0
.byte 0


boxRandom:
 JMP toggleBoxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 2 + [X_CHARS*6]
.word colour_mem + 2 + [X_CHARS*6]
.byte 2,5,3,3
.byte cyan,white
.word style1
.word @rnd
.byte 0
.byte 0
.byte 0

boxColB:
 JMP colourboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 7 + [X_CHARS*6]
.word colour_mem + 7 + [X_CHARS*6]
.byte 7,5,3,3
.byte blue,white
.word style3
.word @back
.byte 0
.byte 0
.byte 0

boxColR:
 JMP colourboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 11 + [X_CHARS*6]
.word colour_mem + 11 + [X_CHARS*6]
.byte 11,5,3,3
.byte green,white
.word style3
.word @bord
.byte 0
.byte 0
.byte 0

boxColP:
 JMP colourboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 15 + [X_CHARS*6]
.word colour_mem + 15 + [X_CHARS*6]
.byte 15,5,3,3
.byte yellow,white
.word style3
.word @pen
.byte 0
.byte 0
.byte 0

boxColA:
 JMP colourboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 19 + [X_CHARS*6]
.word colour_mem + 19 + [X_CHARS*6]
.byte 19,5,3,3
.byte red,white
.word style3
.word @aux
.byte 0
.byte 0
.byte 0

boxRule4Index:
 JMP rule4Index'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 0 + [X_CHARS*11]
.word colour_mem + 0 + [X_CHARS*11]
.byte 0,10,3,3
.byte white,white
.word style3
.word @ind
.byte 0
.byte 0
.byte 0

boxRuleBit4:
 JMP bit4rule'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 3 + [X_CHARS*10]
.word colour_mem + 3 + [X_CHARS*10]
.byte 5,12,14,5
.byte white,white
.word style3
.word @rule4
.byte 0
.byte 0
.byte 0

boxRun4:
 JMP confirmboxes4'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 17 + [X_CHARS*10]
.word colour_mem + 17 + [X_CHARS*10]
.byte 18,12,5,5
.byte cyan,white
.word style1
.word @run
.byte 0
.byte 0
.byte 0
    
boxExit:
 JMP exitboxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 11 + [X_CHARS*19]
.word colour_mem + 11 + [X_CHARS*19]
.byte 12,20,11,3
.byte cyan,white
.word style1
.word @exit
.byte 0
.byte 0
.byte 0

boxFinal:
 JMP boxes'vtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 1 + [X_CHARS*1]
.word colour_mem + 1 + [X_CHARS*1]
.byte 2,2,X_CHARS-2,Y_CHARS-2
.byte white,red
.word style2
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


.alias boxes_list_size 12 ;Update this when you add more boxes

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

@exit: .byte "EXIT", 0
@run: .byte "RUN", 0
@back: .byte "BCK", 0
@pen: .byte "PEN", 0
@aux: .byte "AUX", 0
@bord: .byte "BRD", 0
@rnd: .byte "RND", 0
@ind: .byte "IND", 0
@filenameL: .byte "RULE"
@filenameS: .byte "@0:RULE"
@rule: .byte "********", 0
@rule4: .byte "**********", 0
style1: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
style2: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
style3: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
style4: .byte 98+128, 98, 97+128, 97, 127, 255, 255, 127, 102


boxes'vtable:
    JSR do’jump’table
    .word render, handlekey, get, select, deselect, empty, empty, empty, empty
 
exitboxes'vtable:
    JSR do’jump’table 
    .word render, handlekey, get, select, deselect, exit, empty, empty, empty

confirmboxes'vtable:
    JSR do’jump’table    
    .word render, handlekey, get, select, deselect, automata, empty, leave_fullscreen, continue
    
confirmboxes4'vtable:
    JSR do’jump’table    
    .word render, handlekey, get, select, deselect, automata4, empty, leave_fullscreen, continue4   
    
colourboxes'vtable:
    JSR do’jump’table    
    .word render, handlekeyc, get, select, deselect, empty, empty, empty, empty       
    
rule4Index'vtable:
    JSR do’jump’table    
    .word render, handlekeyi, get, select, deselect, empty, render_index, empty, empty       
    
binaryrule'vtable:
    JSR do’jump’table
    .word render_ruleb, handlerulekeyb, get, select, deselect, update_ruleb, empty, empty, empty    

bit4rule'vtable:
    JSR do’jump’table
    .word renderrule4, handlerulekey4, get, select, deselect, update_rule4, empty, empty, empty
    
flow'vtable:
    JSR do’jump’table
    .word empty, flowKey, get, empty, empty, empty, empty, empty
    
toggleBoxes'vtable:
    JSR do’jump’table
   .word render, handlekey, get, select, deselect, toggle, render_toggle, empty, empty


.alias top 0
.alias bottom 1
.alias right 2
.alias left 3
.alias top_right 4
.alias top_left 5
.alias bottom_right 6
.alias bottom_left 7
.alias fill 8
.checkpc $2000

.data
.org $4000
; globals
.space _target 2
.space _scratch 8
.space method 1
.space var 1
.space selected 1
.space keypress 1
.space fullscreen 1
.space return 1

;automata globals
.space row_counter 1
.space col_counter 1
.space row_start 2
.space multicolour 1


; args for box
.space box_origin 2
.space box_col_origin 2
.space box_x 1
.space box_y 1
.space box_width 1
.space box_height 1
.space box_colour 1
.space box_frame_colour 1
.space box_style 2
.space box_legend 2
.space box_select 1
.space box_check 1
.space box_edited 1


.space box_width_working 1
.space box_height_working 1
.space box_colour_working 1

; args for flow
.space keys_pressed 1

.space cellbuffer1 322
.space cellbuffer2 322
.space pixel_acc 1

.alias bitmap $2000
