#importonce
#import "kernal.asm"

* = $a7 virtual
.zp {
fullscreen: .byte 0
}
* = zero_page_rs_232 virtual
.zp {
this: .word 0
_chptr: .word 0
_styleptr: .word 0
_tempptr: .word 0
}
