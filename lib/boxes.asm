#importonce

style1: .byte 64, 64, 93, 93, 110, 112, 125, 109, 102
style2: .byte 98, 98+128, 97, 97+128, 123, 108, 126, 124, 160
style3: .byte 64, 64, 93, 93, 73, 85, 75, 74, 102
style4: .byte 98+128, 98, 97+128, 97, 127, 255, 255, 127, 102
styleTitle: .byte 98+128, 98, 97+128, 97, 127, 127+128, 127+128, 127, 127+128



lableVtable:
    jsr doJumpTable
    .word render, handlekey, empty, empty, empty, empty, empty, empty, empty

boxesVtable:
     jsr doJumpTable
    .word render, handlekey, get, select, deselect, empty, empty, empty, empty
 
exitboxesVtable:
     jsr doJumpTable 
    .word render, handlekey, get, select, deselect, exit, empty, empty, empty

//confirmboxesVtable:
//      jsr doJumpTable    
//     .word render, handlekey, get, select, deselect, automata, empty, leave_fullscreen, continue
    
confirmboxes4Vtable:
     jsr doJumpTable    
    .word render, handlekey, get, select, deselect, render4, empty, leave_fullscreen, continue4   
    
colourboxesVtable:
     jsr doJumpTable    
    .word render, handlekeyc, get, select, deselect, empty, empty, empty, empty       
    
rule4IndexVtable:
     jsr doJumpTable    
    .word render, handlekeyi, get, select, deselect, empty, render_index, empty, empty       
    
// binaryruleVtable:
//      jsr doJumpTable
//     .word render_ruleb, handlerulekeyb, get, select, deselect, update_ruleb, empty, empty, empty    

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

title:
 jmp lableVtable
.byte [box_width_working-box_origin]-1
.word box_origin 
.word screen_mem + 0 + [X_CHARS*0]
.word colour_mem + 0 + [X_CHARS*0]
.byte 9,1,40,3
.byte yellow,yellow
.word styleTitle
.word str_automata
.byte 0
.byte 0
.byte 0

/*    
boxRun:
  jmp confirmboxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 17 + [X_CHARS*0]
.word colour_mem + 17 + [X_CHARS*0]
.byte 18,2,5,5
.byte selected_col,edge_col
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
.byte edge_col,edge_col
.word  style3
.word str_rule
.byte 1
.byte 0
.byte 0
*/


boxRandom:
  jmp toggleBoxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 2 + [X_CHARS*6]
.word colour_mem + 2 + [X_CHARS*6]
.byte 2,5,3,3
.byte selected_col,edge_col
.word style1
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
.byte green,edge_col
.word style3
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
.byte red,edge_col
.word style3
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
.byte yellow,edge_col
.word style3
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
.byte blue,edge_col
.word style3
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
.byte edge_col,edge_col
.word style3
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
.byte edge_col,edge_col
.word style3
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
.byte selected_col,edge_col
.word style1
.word str_run
.byte 0
.byte 0
.byte 0
    
boxExit:
  jmp exitboxesVtable
.byte [box_width_working-box_origin]-1
.word box_origin
.word screen_mem + 32 + [X_CHARS*22]
.word colour_mem + 32 + [X_CHARS*22]
.byte 34,23,8,3
.byte selected_col,edge_col
.word style1
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
.byte edge_col,red
.word style2
.word 0
.byte 0
.byte 0
.byte 0

.var boxesList = List().add(flow,title,boxRandom,boxColB,boxColR,boxColP,boxColA,boxRule4Index,boxRuleBit4,boxRun4,boxExit)

.const boxes_list_size = boxesList.size() //Update this when you add more boxes
