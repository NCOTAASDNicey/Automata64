#import "lib/data.asm"

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

.macro callInstanceMethod(m,i) {
        // _1 Method
        // _2 Instance
        // V table Method
        lda #m
        sta method
        // Box instance
        lda #<i
        ldx #>i       
        jsr invokevirtual
}


.macro callMethod(m,dest) {
        lda #m
        sta method                  
        jsr dest
}

.macro getInstanceVariable(v,i) {
        lda #[v-box_origin]
        sta v
        lda #<i
        ldx #>i
        ldy #method_get
        jsr invokevirtual           
}



.macro offsetFromThis(obj) {
        ldy #[obj-box_origin]
}

// 1 - offset from this
// 2 - target zero page pointer
.macro loadObjectPointer(obj,ptr) {
        offsetFromThis(obj)
        lda (this),Y
        sta ptr
        iny
        lda (this),Y
        sta ptr+1 
}

// 1 - offset from this
.macro loadObjectByte(obj) {
        offsetFromThis(obj)
        lda (this),Y
}

// 1 - offset from this
.macro saveObjectByte(obj) {
        offsetFromThis(obj)
        sta (this),Y
}

// 1 - offset from this
.macro loadObjectByteY(obj) {
        loadObjectByte(obj)
        tay
}

