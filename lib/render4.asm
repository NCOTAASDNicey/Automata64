#import "zero.asm"

row_counter: .byte 0
col_counter: .byte 0
row_start: .word 0
cellsrc:
.word cellbuffer1
celldst:
.word cellbuffer2
cellbuffer1: .fill [4*40]+2, 0
cellbuffer2: .fill [4*40]+2, 0
pixel_acc: .byte 0
render_random: .byte 1
rule4:
.byte 1,2,3, 0,1,2, 2,0,3, 2

render4:
        lda fullscreen
        beq !+
        jsr initialise_ptrs_automata4
        jsr initialise_cells_automata4
!:      lda #0
        rts
        
continue4:
        lda fullscreen
        beq !+
        jsr initialise_ptrs_automata4
        jsr _render_automata_row4
!:      lda #0
        rts            
        
initialise_ptrs_automata4:
        // initate pointers
        lda #<screen_mem_hi
        sta row_start
        lda #>screen_mem_hi
        sta row_start+1

        lda #0
        sta row_counter        

        lda cellsrc
        sta _tempptr
        lda cellsrc+1
        sta _tempptr+1
        rts

initialise_cells_automata4:     
        // clear  and initailise src buffer
        lda render_random
        cmp #0
        bne _random_init4              

_one_cell_init4:      
        ldy #[4*20]+2        
        lda #0
!:      sta (_tempptr),Y
        dey
        bne !-
        lda #03
        sta cellbuffer1+40
        jmp  _render_automata_row4
       
_random_init4:
        lda $A2
        clc
        ldy #[4*40]                
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

        lda #40
        sta col_counter      
        
        // render new row
        
_render_automata_col4:
        //collect 4 pixels from buffer
        ldx #4
        ldy #0
        sty pixel_acc
!:      clc
        asl pixel_acc
        asl pixel_acc
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
        adc #$8        //bytes in a programmable character
        sta _chptr
        lda _chptr+1
        adc #0
        sta _chptr+1
                
        //repeat till end of buffer
        dec col_counter
        bne _render_automata_col4
        
        //repeat till end of screen
        //advance row  start
        inc row_counter
        lda row_counter
        and #$07
        cmp #$00
        beq !+

        // advance just one byte
        clc
        lda #$01
        adc row_start
        sta row_start
        lda #$00
        adc row_start+1
        sta row_start+1
        jmp !++

        // All 8 rows done advance 160 bytes
!:      clc
        lda #$39
        adc row_start
        sta row_start
        lda #$01
        adc row_start+1
        sta row_start+1
       
        // calculate new row into dst using src
!:      lda cellsrc
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
        ldy #$A1
        sta (_chptr),Y

        ldy #0        
!:      dey
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

        cpy #$A1          //Repeat until all cells processed
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
        cmp #[8*25]
        bcs !+
        jmp _render_automata_row4        
 !:     lda #0 //Dont signal exit 
        rts
