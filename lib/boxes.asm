#importonce

style1: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
style2: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
style3: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
style4: .byte 98+128, 98, 97+128, 97, 127, 255, 255, 127, 102
styleTitle: .byte 98+128, 98, 97+128, 97, 127, 127+128, 127+128, 127, 102


lableVtable:
    jsr doJumpTable
    .word render, handlekey, empty, empty, empty, empty, empty, empty, empty

boxesVtable:
     jsr doJumpTable
    .word render, handlekey, get, select, deselect, empty, empty, empty, empty
 
exitboxesVtable:
     jsr doJumpTable 
    .word render, handlekey, get, select, deselect, exit, empty, empty, empty
    
confirmboxes4Vtable:
     jsr doJumpTable    
    .word render, handlekey, get, select, deselect, render4, empty, leave_fullscreen, continue8rows   
    
colourboxesVtable:
     jsr doJumpTable    
    .word render, handlekeyc, get, select, deselect, empty, empty, empty, empty       
    
rule4IndexVtable:
     jsr doJumpTable    
    .word render, handlekeyi, get, select, deselect, empty, render_index, empty, empty       
    
bit4ruleVtable:
     jsr doJumpTable
    .word renderrule4, handlerulekey4, get, select, deselect, update_rule4, empty, empty, empty
    
flowVtable:
     jsr doJumpTable
    .word empty, flowKey, get, empty, empty, empty, empty, empty
    
toggleBoxesVtable:
     jsr doJumpTable
   .word render, handlekey, get, select, deselect, toggle, render_toggle, empty, empty

flow:
  jmp flowVtable
.byte 1
.word keys_pressed 
.byte 0


.macro box(vtable,str,x,y,w,h,xo,yo,scol,ecol,style,selected) {
  jmp vtable
  .byte BOX_DATA_SIZE
  .word box_origin 
  .word screen_mem + x + [X_CHARS*y]
  .word colour_mem + x + [X_CHARS*y]
  .byte x+xo,y+yo,w,h
  .byte scol,ecol
  .word style
  .word str
  .byte 0
  .byte selected
  .byte 0  
}

.const row2=5
.const row1=13
.const grp1=8
.const grp2=2
.const grp3=22

title:
box(lableVtable,str_automata,0,0,40,3,9,1,lt_blue,blue,styleTitle,0)

boxRule4Index:
box(rule4IndexVtable,str_ind,grp1,row2+1,3,3,0,-1,edge_col,edge_col,style3,0)

boxRuleBit4:
box(bit4ruleVtable,str_rule4,grp1+3,row2,14,5,2,2,edge_col,edge_col,style3,0)

boxRun4:
box(confirmboxes4Vtable,str_run,grp1+17,row2,5,5,1,2,selected_col,edge_col,style1,0)

boxRandom:
box(toggleBoxesVtable,str_rnd,grp2,row1,3,3,0,-1,selected_col,edge_col,style1,1)

boxScroll:
box(toggleBoxesVtable,str_scroll,grp2+6,row1,3,3,-1,-1,selected_col,edge_col,style1,1)

boxColB:
box(colourboxesVtable,str_back,grp3,row1,3,3,0,-1,green,edge_col,style3,0)

boxColR:
box(colourboxesVtable,str_bord,grp3+4,row1,3,3,0,-1,red,edge_col,style3,0)

boxColP:
box(colourboxesVtable,str_pen,grp3+8,row1,3,3,0,-1,yellow,edge_col,style3,0)

boxColA:
box(colourboxesVtable,str_aux,grp3+12,row1,3,3,0,-1,blue,edge_col,style3,0)
    
boxExit:
box(exitboxesVtable,str_exit,32,22,8,3,2,1,selected_col,edge_col,style1,0)

boxFinal:
box(boxesVtable,0,1,1,X_CHARS-2,Y_CHARS-2,2,2,edge_col,red,style2,0)

.var boxesList = List().add(flow,boxRule4Index,boxRuleBit4,boxRun4,boxRandom,boxScroll,boxColB,boxColR,boxColP,boxColA,boxExit,title)

.const boxes_list_size = boxesList.size()
