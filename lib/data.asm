#importonce
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