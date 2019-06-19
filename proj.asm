IDEAL
MODEL small
p186
JUMPS
STACK 0f500h
MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200

SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40

DATASEG
	Clock equ es:6Ch
    OneBmpLine 	db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
    ScreenLineMax 	db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
	;BMP File data
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	opscr db 'opscr.bmp',0
	inst db 'inst.bmp',0
	opt db 'opt.bmp',0
	car1pic db 'car1.bmp',0
	car2pic db 'car2.bmp',0
	three db 'three.bmp',0
	two db 'two.bmp',0
	one db 'one.bmp',0
	go db 'go.bmp',0
	blank db 'blank.bmp',0
	right db 'right.bmp',0
	left db 'left.bmp',0
	bcar db 'bcar.bmp',0
	score0 db 'score0.bmp',0
	score1 db 'score1.bmp',0
	score2 db 'score2.bmp',0
	score3 db 'score3.bmp',0
	score4 db 'score4.bmp',0
	score5 db 'score5.bmp',0
	score6 db 'score6.bmp',0
	score7 db 'score7.bmp',0
	score8 db 'score8.bmp',0
	score9 db 'score9.bmp',0
	heart db 'heart.bmp',0
	mTenPoints db 'mtp.bmp',0
	obstacle1Pic db 'obst1.bmp',0
	obstacle2Pic db 'obst2.bmp',0
	obstacle3Pic db 'obst3.bmp',0
	obsttop db 'obsttop.bmp',0
	gob db 'gob.bmp',0
	gor db 'gor.bmp',0
	obstexp db 'obstexp.bmp',0
	dif db 'dif.bmp',0
	lgtdif db 'lgtdif.bmp',0
	easy db 'easy.bmp',0
	lgteasy db 'lgteasy.bmp',0
	norm db 'norm.bmp',0
	lgtnorm db 'lgtnorm.bmp',0
	hard db 'hard.bmp',0
	lgthard db 'lgthard.bmp',0
	blc db 'blc.bmp',0
	BmpFileErrorMsg    	db 'Error At Opening Bmp File .', 0dh, 0ah,'$'
	ErrorFile           db 0
    BB db "BB..",'$'	
	starts db "starting...",'$'	
	stop db 'stoping...', '$'
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?	
	x db 10
	imgofs dw ?
	color db ?
	rectXparm dw ?
	rectYparm dw ?
	rectLen dw ?
	rectWid dw ?
	counttime dw ?
	keyboardData db 'n'
	carXparam dw 148
	score dw 0000
	carNeutralState db 0
	lives dw 3
	backgroundColor db 2
	isMinTenPoints db 0
	minTenPointsY dw 30
	obstX dw ?
	obstY dw 0
	randomNumbersArr dw 129,172,135,162,121,177,176,115,158,147,108,123,147,130,124,137,154,118,119,109,169,165,0
	rnumIndex dw 0
	difficulty db 9 ;default difficulty is 9 - EASY
	
CODESEG
start:
	mov ax, @data
	mov ds, ax
	call SetGraphic 
	
homeScreenLabel: ;print opening screen
	call homeScreen
	mov ah,8
	int 21h
	cmp al,'i'
	je inspressed ;if 'i' is pressed
	cmp al,'o'
	je optpressed ;if 'o' is pressed
	cmp al,'s'
	je startPressed ;if 's' is pressed
	jmp homeScreenLabel ;if none of the above pressed get input again

inspressed:
	mov di,offset inst
	mov [imgofs],di
	call ppic
	mov ah,8
	int 21h
	cmp al,'b'
	je homeScreenLabel ;if 'b' is pressed
	jmp inspressed ;if none of the above pressed get input again
	
optpressed:
	call options
	jmp homeScreenLabel
	
startPressed:
	call ClearScreen ;clear the screen
	call drawDefaultBackground ;draw the default background
	call count321;;count 3, 2 ,1 ,GO!
	call redrawScoreBoard 
	call redrawLives
	
gameLoop:;לולאת המשחק
	call drawBlankCar
	call checkKeyboard
	cmp [keyboardData],'d'
	je rightLabel
	cmp [keyboardData],'a'
	je leftLabel
	cmp [keyboardData],'n'
	je carNeutral
rightLabel: ;פנייה ימינה
	add [carXparam],6 
	mov si,offset right
	jmp checkBoundsLabel
leftLabel: ;פנייה שמאלה
	sub [carXparam],6
	mov si,offset left
	jmp checkBoundsLabel
carNeutral: ;מצב נייטרלי
	cmp [carNeutralState],0 ;בדיקה איזה מצב נייטרלי הוא הנוכחי מבין ה2
	je drawCar1Label
	jne drawCar2Label
drawCar1label: ;מצב נייטרלי 1
	mov [carNeutralState],1
	mov si,offset car1pic
	jmp checkBoundsLabel
drawCar2Label: ;מצב נייטרלי 2
	mov [carNeutralState],0
	mov si,offset car2pic
			
checkBoundsLabel:;בודק אם המכונית יצאה מתחומי הכביש
	cmp [carXparam],190
	jae carOutOfBoundsLabel
	cmp [carXparam],104
	jbe carOutOfBoundsLabel
	jmp isMinTenPointsLabel
		
carOutOfBoundsLabel:
	call drawOffMinTenPoints
	call carOutOfBounds
isMinTenPointsLabel:; בודק אם יש לצייר את הודעת ה10- נקודות
	cmp [isMinTenPoints],1
	je minTenPointsLabel
	jne contiObstacle
		
minTenPointsLabel:
	cmp [minTenPointsY],160;בודק אם הודעת ה10- נקודות הגיעה לקצה 
	jae stopMinTenPoints; אם כן תפסיק את ההדפה
	call drawMinTenPoints; הדפסת ההודעה
	jmp contiObstacle
	
stopMinTenPoints: ;הפסקת הדפסת ההודעה
	call drawOffMinTenPoints
	mov [isMinTenPoints],0 
	mov [minTenPointsY],30 ;החזרת ההודעה למיקומה ההתחלתי
	
contiObstacle:; הדפסת המכשול
	call drawObstacle
	
checkX: ;של המכונית והמכשול נפגשים xבדיקה אם ערכי ה
	mov di,[carXparam]
	cmp [obstX],di
	ja obstLarger ;של המכשול גדול יותר xאם ה
	jb carLarger ;של הרכב גדול יותר xאם ה
	jmp checkY
	
obstLarger: 
	add di,24
	cmp [obstX],di 
	jb checkY
	jmp MainRedraw
	
carLarger:
	mov di,[obstX]
	add di,34
	cmp [carXparam],di
	jb checkY
	jmp MainRedraw
	
checkY:;של המכונית והמכשול נפגשים yבדיקה אם ערכי ה
	cmp [obstY],140
	ja hitLabel
	jmp MainRedraw
	
hitLabel:;תווית הפגיעה
	call hit
	mov di,[word ptr difficulty]
	mov [obstY],di
	cmp [lives],0
	je gameOverLabel
	call redrawLives
	jmp loopLabel

gameOverLabel: ;תווית סיום המשחק
	call gameOver ;ציור מסך סיום המשחק
	call resetParams ;החזרת המשתנים לערכם ההתחלתי
	jmp homeScreenLabel ;חזרה למסך הפתיחה

MainRedraw: 
	mov [imgofs],si
	call drawCar
	mov [counttime],1
	call countsec
	inc [score];;inc score
	call redrawScoreBoard
	mov di,[word ptr difficulty]
	cmp [obstY],di
	jae drawOverObstLabel
	jmp loopLabel
	
drawOverObstlabel:
	call drawOverObst
	cmp [rnumIndex],0
	je loopLabel
drawObstTopLabel: 
	mov di,[word ptr difficulty]
	cmp [obstY],di;בודק אם המכשול עשה שלב אחד בדרך אם כן יצייר
	ja loopLabel
	call drawObstTop
	
loopLabel:;חוזר לתחילת הלולאה
	jmp gameLoop
	
exit:
	mov dx, offset BB
	mov ah,9
	;int 21h
	mov ah,0
	int 16h
	mov ax,2
	int 10h
	mov ax, 4c00h
	int 21h	
	
;========================
;==========================
;===== Procedures  Area ===
;==========================
;==========================

proc drawOffMinTenPoints ;פרוצדורה שמציירת ריבוע בצבע הרקע במיקום בו הייתה הודעת ה10- נקודות
	mov dl,[backgroundColor]
	mov [color],dl
	mov di,[minTenPointsY]
	mov [rectXparm],0
	mov [rectYparm],di
	mov [rectLen],105
	mov [rectWid],31
	call drawRect
	ret
endp drawOffMinTenPoints

proc homeScreen ;פרוצדורה שמציירת את מסך הפתיחה
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	mov di,offset opscr ;opening screen
	mov [imgofs],di
	call ppic
	ret
endp homeScreen


;פרוצדורת הפגיעה
proc hit ;פרוצדורה שמחסרת 1 מבר החיים ומציירת פיצוץ ובזה מסמנת את הפגיעה
	pusha
	dec [lives]
	mov di,[obstX]
	mov si,[obstY]
	sub si,[word ptr difficulty]
	mov [BmpLeft],di
	mov [BmpTop],si
	mov [BmpColSize],34
	mov [BmpRowSize],30
	mov bx,offset obstexp
	mov [imgofs],bx
	call ppic
	call countsec
	mov [color],7
	mov [rectXparm],di
	mov [rectYparm],si
	mov [rectLen],34
	mov [rectWid],31
	call drawRect
	popa
	ret
endp hit

proc drawOverObst ;מצייר ריבוע בצבע הכביש במקום שבו המכשול נמצא
	mov [color],7
	mov [rectXparm],105
	mov [rectYparm],170
	mov [rectLen],108
	mov [rectWid],30
	call drawRect
	ret
endp drawOverObst

proc drawObstTop ;מצייר את החלק העליון של המכשול על לאחר שהגיע לקצה
	pusha
	mov bx,[rnumIndex]
	sub bx,2
	mov si,[randomNumbersArr+bx]
	mov [BmpLeft],si
	mov [BmpTop],185
	mov [BmpColSize], 34
	mov [BmpRowSize],15
	mov di,offset obsttop
	mov [imgofs],di
	call ppic
	popa
	ret
endp drawObstTop

proc options;פרוצדורה של האופציות שמציירת תמונה ומפעילה את הבר אופציות
	pusha
	push [counttime]
	mov [counttime],2
	mov di,offset opt
	mov [imgofs],di
	call ppic
	mov [BmpLeft],100
	mov [BmpTop],30
	mov [BmpColSize], 50
	mov [BmpRowSize] ,19
	mov di,offset lgtdif
	mov [imgofs],di
	call ppic
@@start:
	mov [BmpLeft],100
	mov [BmpTop],49
	mov [BmpColSize], 50
	mov [BmpRowSize],57
	mov di,offset blc
	mov [imgofs],di
	call ppic
	mov [BmpLeft],100
	mov [BmpTop],30
	mov [BmpColSize], 50
	mov [BmpRowSize] ,19
	mov ah,8
	int 21h
	cmp al,'b'
	je @@quit
	cmp al,13;;enter key
	je @@difficulty
	jmp @@start
	
@@difficulty:
	add [BmpTop],19
	mov di,offset hard
	mov [imgofs],di
	call ppic
	call countsec
	mov di,offset norm
	mov [imgofs],di
	call ppic
	add [BmpTop],19
	mov di,offset hard
	mov [imgofs],di
	call ppic
	call countsec
	sub [BmpTop],19
	mov di,offset easy
	mov [imgofs],di
	call ppic
	add [BmpTop],19
	mov di,offset norm
	mov [imgofs],di
	call ppic
	add [BmpTop],19
	mov di,offset hard
	mov [imgofs],di
	call ppic
	call countsec
	sub [BmpTop],57
@@pdifinput:
	mov ah,8
	int 21h
	cmp al,13
	je @@start
	cmp al,'s'
	je @@lgteasylabel
	jmp @@pdifinput

@@lgteasylabel:
	add [BmpTop],19
	mov di,offset lgteasy
	mov [imgofs],di
	call ppic
	mov ah,8
	int 21h
	cmp al,13 ;; enterkey
	je @@setEasy
	mov di,offset easy
	mov [imgofs],di
	call ppic
	sub [BmpTop],19
	cmp al,'s'
	je @@lgtnormallabel
	jmp @@lgteasylabel

@@lgtnormallabel:
	add [BmpTop],38
	mov di,offset lgtnorm
	mov [imgofs],di
	call ppic
	mov ah,8
	int 21h
	cmp al,13 ;; enterkey
	je @@setNormal
	mov di,offset norm
	mov [imgofs],di
	call ppic
	cmp al,'s'
	je @@lgthardlabel
	sub [BmpTop],38
	cmp al,'w'
	je @@lgteasylabel
	jmp @@lgtnormallabel
	
@@lgthardlabel:
	add [BmpTop],19
	mov di,offset lgthard
	mov [imgofs],di
	call ppic
	mov ah,8
	int 21h
	cmp al,13 ;; enterkey
	je @@setHard
	mov di,offset hard
	mov [imgofs],di
	call ppic
	sub [BmpTop],57
	cmp al,'w'
	je @@lgtnormallabel
	add [BmpTop],38
	jmp @@lgthardlabel
	
@@setEasy:;מגדיר את רמת הקושי לרמה הקלה - 9
	mov [difficulty],9
	jmp @@start

@@setNormal:;מגדיר את רמת הקושי לרמה הנורמלית - 12
	mov [difficulty],12
	jmp @@start
@@setHard:
	mov [difficulty],14;מגדיר את רמת הקושי לרמה הקשה - 14
	jmp @@start
	
@@quit:
	pop [counttime]
	popa
	ret
endp options

proc resetParams ;פרוצדורה שמגדירה את הפרמטרים למצב ההתחלתי שלהם
	mov [rnumIndex],0
	mov [lives],3
	mov [score],0
	mov [obstY],0
	mov [keyboardData],'n'
	mov [carXparam],148
	mov [isMinTenPoints],0
	mov [minTenPointsY],30
	ret
endp resetParams

proc gameOver ;פרוצדורה שמציירת את מסך סיום המשחק
	pusha
	mov [counttime],15
	mov cx,2
@@loop:
	push cx
	cmp cx,0
	je @@quitproc
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	mov di,offset gob
	mov [imgofs],di
	call ppic
	call countsec
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	mov di,offset gor
	mov [imgofs],di
	call ppic
	call countsec
	pop cx
	dec cx
	jmp @@loop
	
@@quitproc:
	pop cx
	popa
	ret 
endp gameOver

proc drawObstacle ;פרוצדורה שמציירת את המכשול
	pusha
	mov di,[obstY]
	mov bx,[rnumIndex]
	mov si,[randomNumbersArr + bx]
	cmp si,0
	je @@zeroIndex
	jmp @@label
	
@@zeroIndex:
	mov [rnumIndex],0
	mov si,129
	mov [obstY],0
	
@@label:
	cmp [obstY],0
	ja @@drawRectLabel
	jmp @@drawObstLabel
	
@@drawRectLabel:
	sub di,[word ptr difficulty]
	mov [color],7
	mov [rectXparm],si
	mov [rectYparm],di
	mov [rectLen],34
	mov [rectWid],30
	call drawRect
	add di,[word ptr difficulty]
	push bx
	mov bx,178
	sub bx,[word ptr difficulty]
	cmp [obstY],bx
	pop bx
	jae @@zeroTheYparm
	
@@drawObstLabel:
	mov [obstX],si
	mov [BmpLeft],si
	mov [BmpTop],di
	mov [BmpColSize], 34
	mov [BmpRowSize] ,30
	mov di,offset obstacle1Pic
	mov [imgofs],di
	call ppic
	jmp @@quittheproc
	
@@zeroTheYparm:
	sub di,[word ptr difficulty]
	mov [color],7
	mov [rectXparm],si
	inc di
	mov [rectYparm],di
	mov [rectLen],34
	mov [rectWid],30
	call drawRect
	add di,[word ptr difficulty]
	mov [obstX],si
	mov [BmpLeft],si
	mov [BmpTop],di
	mov [BmpColSize], 34
	mov [BmpRowSize] ,30
	mov di,offset obstacle1Pic
	mov [imgofs],di
	call ppic
	mov [obstY],0
	add [rnumIndex],2
	
	
@@quittheproc:
	mov ax,[word ptr difficulty]
	add [obstY],ax
	
	popa
	ret
endp drawObstacle

proc drawMinTenPoints ;פרוצדורה שמציירת את הודעת המינוס 10 נקודות
	pusha
	mov dl,[backgroundColor]
	mov [color],dl
	mov di,[minTenPointsY]
	mov [rectXparm],0
	mov [rectYparm],di
	mov [rectLen],104
	mov [rectWid],30
	call drawRect
	add [minTenPointsY],15
	mov [BmpLeft],0
	mov di,[minTenPointsY]
	mov [BmpTop],di
	mov [BmpColSize], 104
	mov [BmpRowSize] ,30
	mov di,offset mTenPoints
	mov [imgofs],di
	call ppic
	popa
	ret
endp drawMinTenPoints

proc carOutOfBounds ;פרוצדורה שבודקת אם המכונית יצאה אל מחוץ לתחומי הכביש
	pusha
	mov [isMinTenPoints],1
	mov [minTenPointsY],30
	cmp [score],0
	jbe @@setScoreZero
	cmp [score],10
	je @@setScoreZero
	jb @@setScoreZero
	ja @@subTen
	jmp @@continue
	
@@subTen:
	sub [score],10
	jmp @@continue
@@setScoreZero:
	mov [score],0
@@continue:
	cmp [carXparam],190
	jae @@rightBoundary
	cmp [carXparam],106
	jbe @@leftBoundary
	
	
@@rightBoundary:
	mov [carXparam],183
	jmp @@quittproc
@@leftBoundary:
	mov [carXparam],111
	jmp @@quittproc

@@quittproc:
	mov [minTenPointsY],30
	popa
	ret
endp carOutOfBounds

proc redrawLives ;פרוצדורה שמציירת מחדש את בר החיים
	pusha
	mov dl,[backgroundColor]
	mov [color],dl
	mov [rectXparm],0
	mov [rectYparm],0
	mov [rectLen],80
	mov [rectWid],31
	call drawRect
	
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 26
	mov [BmpRowSize] ,30
	
	mov di,offset heart
	mov [imgofs],di
	mov cx,[lives]
@@loop:
	cmp cx,0
	je @@quitprocc
	call ppic
	dec cx
	add [BmpLeft],26
	jmp @@loop

@@quitprocc:

	popa
	ret
endp redrawLives

proc redrawScoreBoard ;פרוצדורה שמציירת מחדש את מסך הניקוד
	pusha
	mov dl,[backgroundColor]
	mov [color],dl
	mov [rectXparm],239
	mov [rectYparm],0
	mov [rectLen],80
	mov [rectWid],30
	call drawRect
	mov [BmpTop],0
	mov [BmpColSize],20
	mov [BmpRowSize],30

	mov ax,[score]
	mov bx,10
	mov cx,3
@@loop1:
	cmp cx,0ffffh
	je @@quitproc
	xor dx,dx
	div bx
	push cx
	push dx
	call drawNumber
	dec cx
	jmp @@loop1
	
	
@@quitproc:	
	popa
	ret
endp redrawScoreBoard

proc drawNumber ;פרוצדורה שמציירת מספר בשביל מסך הניקוד
	push bp
	mov bp,sp
	pusha
	index equ [bp+6]
	number equ [bp+4]

	mov di,index
	cmp di,0
	je @@label0
	cmp di,1
	je @@label1
	cmp di,2
	je @@label2
	cmp di,3
	je @@label3

@@label0:
	mov [BmpLeft],239
	jmp @@cmpnum
@@label1:
	mov [BmpLeft],259
	jmp @@cmpnum
@@label2:
	mov [BmpLeft],279
	jmp @@cmpnum
@@label3:
	mov [BmpLeft],299

@@cmpnum:
	mov di,number
	cmp di,0
	je @@n0
	cmp di,1
	je @@n1
	cmp di,2
	je @@n2
	cmp di,3
	je @@n3
	cmp di,4
	je @@n4
	cmp di,5
	je @@n5
	cmp di,6
	je @@n6
	cmp di,7
	je @@n7
	cmp di,8
	je @@n8
	cmp di,9
	je @@n9

@@n0:
	mov di,offset score0
	jmp @@draw
@@n1:
	mov di,offset score1
	jmp @@draw
@@n2:
	mov di,offset score2
	jmp @@draw
@@n3:
	mov di,offset score3
	jmp @@draw
@@n4:
	mov di,offset score4
	jmp @@draw
@@n5:
	mov di,offset score5
	jmp @@draw
@@n6:
	mov di,offset score6
	jmp @@draw
@@n7:
	mov di,offset score7
	jmp @@draw
@@n8:
	mov di,offset score8
	jmp @@draw
@@n9:
	mov di,offset score9

@@draw:
	mov [imgofs],di
	call ppic
	popa
	pop bp
ret 4
endp drawNumber

proc drawBlankCar ;פרוצדורה שמציירת תמונה בצבע הכביש ובגודל המכונית שמשמשת כדי למחוק את המכונית כדי שתצוייר מחדש
	mov di,[carXparam]
	mov [BmpLeft],di
	mov [BmpTop],169
	mov [BmpColSize], 24
	mov [BmpRowSize] ,30
	mov di,offset bcar
	mov [imgofs],di
	call ppic
ret
endp drawBlankCar

proc drawCar ;פרוצדורה שמציירת את המכונית
	mov di,[carXparam]
	mov [BmpLeft],di
	mov [BmpTop],169
	mov [BmpColSize], 24
	mov [BmpRowSize] ,30
	call ppic
ret
endp drawCar

proc checkKeyboard ;פרוצדורה שמקבלת מידע מהמקלדת
	in 	al,64h
	cmp al, 10b 		
	je quitproc
	in 	al, 60h
	cmp al, 20h; d pressed
	je dpressed
	cmp al,	0a0h ; d released
	je dreleased
	cmp al,	1eh ; a pressed 
	je apressed
	cmp al, 9eh ; a released
	je areleased
	jmp quitproc
dpressed:
	mov [keyboardData],'d'
	jmp quitproc
dreleased:
	mov [keyboardData],'n'
	jmp quitproc
apressed:
	mov [keyboardData],'a'
	jmp quitproc
areleased:
	mov [keyboardData],'n'
quitproc:
	
ret
endp checkKeyboard

proc drawDefaultBackground ;פרוצדורה שמציירת את הרקע
	mov dl,[backgroundColor]
	mov [color],dl
	mov [rectXparm],0
	mov [rectYparm],0
	mov [rectLen],320
	mov [rectWid],200
	call drawRect
	mov [color],7
	mov [rectXparm],105
	mov [rectYparm],0
	mov [rectLen],108
	mov [rectWid],200
	call drawRect
	mov [BmpLeft],148
	mov [BmpTop],169
	mov [BmpColSize], 24
	mov [BmpRowSize] ,30
	mov di,offset car1pic
	mov [imgofs],di
	call ppic
	ret
endp drawDefaultBackground

proc count321 ;ובסהכ סופרת 4 שניות "go" פרוצדורה שסופרת שמציירת את המספרים 3,2,1 ומציירת 
	mov [BmpLeft],129
	mov [BmpTop],69
	mov [BmpColSize], 60
	mov [BmpRowSize] ,60
	mov [counttime],18
	mov di,offset three
	mov [imgofs],di
	call ppic
	call countsec
	mov di,offset two
	mov [imgofs],di
	call ppic
	call countsec
	mov di,offset one
	mov [imgofs],di
	call ppic
	call countsec
	mov di,offset go
	mov [imgofs],di
	call ppic
	call countsec
	mov di,offset blank
	mov [imgofs],di
	call ppic
ret
endp count321

proc drawPixel
xparm equ bp+6
yparm equ bp+4
	push bp
	mov bp,sp
	pusha

	mov bh,0h
	mov cx,[xparm]
	mov dx,[yparm]
	mov al,[color]
	mov ah,0ch
	int 10h

	popa
	pop bp
ret 4
endp drawPixel

proc drawLine
	len equ bp+8
	xparm equ bp+6
	yparm equ bp+4

	push bp
	mov bp,sp
	pusha

	mov ax,[xparm]
	mov cx,[len]
loopLine:
	push ax
	push [yparm]
	call drawPixel
	inc ax
	loop loopLine
			
	popa
	pop bp
ret 6
endp drawLine

proc drawRect ;פונקציה שמציירת ריבוע
	push [rectYparm]
	pusha
	mov cx,[rectWid]
loopLen:	
	push [rectLen]
	push [rectXparm]
	push [rectYparm]
	call drawLine
	inc [rectYparm]
	loop loopLen

	popa
	pop [rectYparm]
ret 
endp drawRect

proc ppic ;פרוצדורה שמדפיסה תמונה
	pusha
	mov bh, 0
	mov bl, [byte ptr x]
	add [x], 3
	;mov [BmpLeft],0
	;mov [BmpTop],0
	;mov [BmpColSize], 320
	;mov [BmpRowSize] ,200
	mov dx,[imgofs]
	call OpenShowBmp 
	cmp [ErrorFile],1
	jne continue
	jmp exitError
exitError:
    mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h	
continue:
	popa	
ret
endp ppic

proc countsec
	pusha
	push es
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]	
FirstTick:
	cmp ax, [Clock]
	je FirstTick
	; count 3 sec
	mov cx, [counttime] ; 182x0.055sec = ~10sec
DelayLoop:
	mov ax, [Clock]
Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
	pop es
	popa
ret
endp countsec
; input :
;	1.BmpLeft offset from left (where to start draw the picture) 
;	2. BmpTop offset from top
;	3. BmpColSize picture width , 
;	4. BmpRowSize bmp height 
;	5. dx offset to file name with zero at the end 
proc OpenShowBmp near
	push cx
	push bx
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	call ReadBmpHeader
	; from  here assume bx is global param with file handle. 
	call ReadBmpPalette
	call CopyBmpPalette
	call ShowBMP 
	call CloseBmpFile
@@ExitProc:
	pop bx
	pop cx
	ret
endp OpenShowBmp	
; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile

proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette
 
 

proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	mov bp,dx
	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScreenLineMax
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScreenLineMax
	rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 


proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

 proc ClearScreen
	push cx
	push ax
	push di
	push es		           ; Save ES value - IMPORTANT, or else the clock loop in the main program wouldn't work properly.
	mov ax,0A000h          ; BIOS graphics (not text).
	mov es,ax
    xor di,di
    xor ax,ax
    mov cx,32000d          ; 320 X 200, 64000 bytes in memory.
    cld
    rep stosw
	pop es
	pop di
	pop ax
	pop cx
	ret
endp ClearScreen

END start

