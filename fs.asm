BasicUpstart2(start)
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
// 			Graphic conversion with FloydSteinberg
//--------------------------------------------------------------------------
//--------------------------------------------------------------------------

start:	sei
		lda #$3b
		sta $d011
		lda #$18
		sta $d018
		lda #BLACK
		sta $d020
		ldx #0
		lda #BLACK | (WHITE<<4)
loop:	sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $0700,x
		inx
		bne loop
		jmp *

		*=$2000 "Picture"
		.var pic1 = floydSteinberg("jen.jpg")
		.fill 40*200, pic1.get(i)

.function setPixel(errors,x,y,value){
	.if (x >= 0 && x<320 && y>=0 && y<200) {
		.var idx=x+y*320
		.eval errors.set(idx, errors.get(idx) + value)
	}
}

.function render(pixels){
	// Convert to byteStream
	.var result = List()
	.for (var charY=0; charY<25; charY++)
	{
		.for (var charX=0; charX<40; charX++)
		{
			.for (var charRow=0; charRow<8; charRow++)
			{
				.var byte = 0
				.var idx = charX*8 + (charY*8+charRow)*320
				.for (var pixelNo=0; pixelNo<8; pixelNo++)
				{
					.eval byte=byte*2+(pixels.get(idx+pixelNo) == 255?1:0)
				}
				.eval result.add(byte)
			}
		}
	}
	.return result
}

.function fs48(errors,x,y,e) {
	.eval setPixel(errors,x+1,y,e *7/48)
	.eval setPixel(errors,x+2,y,e *5/48)

	.eval setPixel(errors,x-2,y+1,e *3/48)			
	.eval setPixel(errors,x-1,y+1,e *5/48)			
	.eval setPixel(errors,x,y+1,e *7/48)			
	.eval setPixel(errors,x+1,y+1,e *5/48)			
	.eval setPixel(errors,x+2,y+1,e *3/48)			
	
	.eval setPixel(errors,x-2,y+2,e *1/48)			
	.eval setPixel(errors,x-1,y+2,e *3/48)			
	.eval setPixel(errors,x,y+2,e *5/48)			
	.eval setPixel(errors,x+1,y+2,e *3/48)			
	.eval setPixel(errors,x+2,y+2,e *1/48)	
}

.function floydSteinberg(filename) {
	.var width=320
	.var height=200
	.const total=width*height

	.var errors=List(total);
	.for (var i=0;i<total;i++)
		.eval errors.set(i,0);		

	.var picture = LoadPicture(filename);
	.var dithered=List(total);
	.for (var y=0; y<height; y++) {
		.for (var x=0; x<width; x++) {
			.var idx=x+y*width
			.var rgb = picture.getPixel(x,y)
			.var grey = floor(((rgb>>0)&$ff * 0.299) + ((rgb>>8)&$ff * 0.587) + ((rgb>>16)&$ff * 0.114))
			.eval grey -= errors.get(idx)
			.var e=0;
			.if (grey < 128 ){
				.eval e=grey * -1
				.eval grey=0
			}else{
				.eval e=255 - grey
				.eval grey=255
			}
			.eval dithered.set(idx,grey)
			.eval fs48(errors,x,y,e)							
		}
	}
	.return render(dithered)
}

