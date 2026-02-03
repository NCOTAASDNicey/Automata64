// KERNAL routine aliases (C64)
#importonce

.const	acptr=		$ffa5
.const	chkin=		$ffc6
.const	chkout=		$ffc9
.const	chrin=		$ffcf
.const	chrout=		$ffd2
.const	ciout=		$ffa8
.const	cint=		$ff81
.const	clall=		$ffe7
.const	close=		$ffc3
.const	clrchn=		$ffcc
.const	getin=		$ffe4
.const	iobase=		$fff3
.const	ioinit=		$ff84
.const	listen=		$ffb1
.const	load=		$ffd5
.const	membot=		$ff9c
.const	memtop=		$ff99
.const	open=		$ffc0
.const	plot=		$fff0
.const	ramtas=		$ff87
.const	rdtim=		$ffde
.const	readst=		$ffb7
.const	restor=		$ff8a
.const	save=		$ffd8
.const	scnkey=		$ff9f
.const	screen=		$ffed
.const	second=		$ff93
.const	setlfs=		$ffba
.const	setmsg=		$ff90
.const	setnam=		$ffbd
.const	settim=		$ffdb
.const	settmo=		$ffa2
.const	stop=		$ffe1
.const	talk=		$ffb4
.const	tksa=		$ff96
.const	udtim=		$ffea
.const	unlsn=		$ffae
.const	untlk=		$ffab
.const	vector=		$ff8d

//VIC_II Registers
.const VIC_sprite_0_x=   $D000
.const VIC_sprite_0_y=   $D001
.const VIC_sprite_1_x=   $D002
.const VIC_sprite_1_y=   $D003
.const VIC_sprite_2_x=   $D004
.const VIC_sprite_2_y=   $D005
.const VIC_sprite_3_x=   $D006
.const VIC_sprite_3_y=   $D007
.const VIC_sprite_4_x=   $D008
.const VIC_sprite_4_y=   $D009
.const VIC_sprite_5_x=   $D00A
.const VIC_sprite_5_y=   $D00B
.const VIC_sprite_6_x=   $D00C
.const VIC_sprite_6_y=   $D00D
.const VIC_sprite_7_x=   $D00E
.const VIC_sprite_7_y=   $D00F
.const VIC_sprite_MSBX=  $D010
.const VIC_control_1=    $D011
.const VIC_raster=       $D012
.const VIC_h_pen=        $D013
.const VIC_v_pen=        $D014
.const VIC_sprite_enable= $D015
.const VIC_control_2=    $D016
.const VIC_sprite_2Y=    $D017
.const VIC_control_mem=  $D018
.const VIC_IRQ=          $D019
.const VIC_IRQ_mask=     $D01A
.const VIC_sprite_back=  $D01B
.const VIC_sprite_MCM=   $D01C
.const VIC_sprite_2X=    $D01D
.const VIC_SP_SP_COL=    $D01E
.const VIC_SP_BACK_COL=  $D01F
.const VIC_border=       $D020
.const VIC_back_0=       $D021
.const VIC_back_1=       $D022
.const VIC_back_2=       $D023
.const VIC_back_3=       $D024
.const VIC_sprite_multi_0= $D025
.const VIC_sprite_multi_1= $D026
.const VIC_sprite_0=     $D027
.const VIC_sprite_1=     $D028
.const VIC_sprite_2=     $D029
.const VIC_sprite_3=     $D02A
.const VIC_sprite_4=     $D02B
.const VIC_sprite_5=     $D02C
.const VIC_sprite_6=     $D02D
.const VIC_sprite_7=     $D02E

.const screen_mem=       $0400
.const screen_mem_hi=    $2000
.const colour_mem=       $D800

.const X_CHARS=   40
.const Y_CHARS=   25

.const KEY_CSR_UP= 145
.const KEY_CSR_DOWN= 17
.const KEY_CSR_LEFT= 157
.const KEY_CSR_RIGHT= 29
.const KEY_SPACE= 32
.const KEY_RETURN= 13
.const KEY_ESC= 3

.const zero_page_rs_232=   247

.const zero_page_free1=    251
.const zero_page_free2=    252
.const zero_page_free3=    253
.const zero_page_free4=    254
.const chrout_colour=      $286

.const SHFLAG=$028D
.const CINV=$0314 // Hardware interrupt vector
.const JIFFY_CLOCK=$A0
.const SAREG=$30C
.const SXREG=$30D
.const SYREG=$30E


