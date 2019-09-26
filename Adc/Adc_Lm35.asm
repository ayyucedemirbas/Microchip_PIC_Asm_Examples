	LIST P=16F877A
;Erdogan Canbay Taraf�ndan Dizayn Edildi F�rat Universitesi Bilgisayar Muhendisligi ��rencisi
	#INCLUDE <P16F877A.INC>
	DEGER EQU 0X20
	DEGER2 EQU 0X21
	TEMP EQU 0X22
	BIRLER EQU 0X23
	ONLAR EQU 0X24
	YUZLER EQU 0X25
	OKUNAN_DEGER EQU 0X26
	HEDEFBIRLER EQU 0X27
	HEDEFONLAR EQU 0X28
	ORG 0X00
	GOTO MAIN
MAIN
	BANKSEL TRISB
	CLRF TRISB
	CLRF TRISC	

	MOVLW 0X0F
	MOVWF TRISD

	BANKSEL ADCON0		;A portu normalde analogdur hangi portlardan analog hangi portlardan d�j�tal ��k�� alaca��m�z� adcon registeri ile belirleriz
	MOVLW B'11000001'		;Register ayarlamas� ve port ayarlamar�n� yap�yoruz
	MOVWF ADCON0		

	BANKSEL ADCON1
	MOVLW B'10001000'
	MOVWF ADCON1

	BANKSEL TRISA
	MOVLW 0XFF
	MOVWF TRISA

	BANKSEL PORTB
	CLRF PORTB
	CLRF PORTA
	CLRF PORTD
	BSF PORTD,4
	MOVLW 0X30 			;hedef de�erinin birler basama��
	MOVWF HEDEFBIRLER 
	MOVLW 0X30 			;hedef basama��n�n onlar de�eri
	MOVWF HEDEFONLAR 	;0x30 ascii kod duzeninde 0 say�s�na denk gelmektedir

TEMIZLE	
	MOVLW 0X02			;lcd paneli ile igili kodlar 
	CALL KOMUT_YAZ		;�rne�in 0x02 sat�r ba��na imleci getirir
	MOVLW 0X28			;Lcd ile ilgili i�lem yapmadan �nce bu tarz ayarlamalar�
	CALL KOMUT_YAZ		;yap�p lcd yi kullan�ma haz�rlmam�z gerekmektedir
	MOVLW 0X0C			
	CALL KOMUT_YAZ
	MOVLW 0X80	
	CALL KOMUT_YAZ

DONUSTUR
	BANKSEL ADCON0
	BSF ADCON0,GO	 ;A/D DONUSUME Basla
	CALL GECIKME
KONTROL
	BTFSC ADCON0,GO ;A/D DONUSUM BITTI MI
	GOTO KONTROL	;d�n��t�rme i�lemi bittiyse adresL ye bir de�er y�klenmi� olacakt�r
	BANKSEL ADRESL  	;adresL yada AdresH a atanacak de�er ADFM biti ile belirlenecektir
	MOVF ADRESL,W	;ADFM 1 olursa sa�a dayal� (AdresH a yazar)
	BCF STATUS,RP0		;ADFM 0 olursa Sola Dayal� (AdresL ye yazar)
	MOVWF OKUNAN_DEGER
	
	BTFSC PORTD,0
	GOTO ARTTIR
	BTFSC PORTD,1
	GOTO AZALT	
	GOTO LOOP

ARTTIR
	MOVLW 0X39			;Hedef birler basama�� 9 olduysa (Asci de 0x39 a denk gelir)
	SUBWF HEDEFBIRLER,W 	;9 dan sonra 0 yaz 
	BTFSS STATUS,C      		 
	INCF HEDEFBIRLER
	BTFSS STATUS,C      
	GOTO LOOP			;birler basama�� 9 olduktan sonra onlar basama��n�n 1 art�p birler basama��n�n tekrar 0 olmas� gerekmektedir
	INCF HEDEFONLAR		;ve hedef onlar onlar basama��n� artt�r
	MOVLW 0X30			;9 say�s�dan sonra tekrar 0 de�erini birler basam��na atamam�z gerekiyor
	MOVWF HEDEFBIRLER
	GOTO LOOP
	
AZALT
	MOVLW 0X31			;azaltma de�eri i�in birler basam��n�n 0 oldu�u durumda tekrar 9 de�erini atayarak yap�yoruz 
	SUBWF HEDEFBIRLER,W ; HEDEFBIRLER-0X30
	BTFSC STATUS,C       ; C=1 DEGER3 > 0X30
	DECF HEDEFBIRLER
	BTFSC STATUS,C			;�rne�in de�erimiz 45 44 43 42 41 40 diye azal�yor
	GOTO LOOP			;40 say�s�nda onlar basam�� 4 birler basama�� 0 d�r (2 par�a halinde d���nmek zorunday�z zira asci kodlamada 40 diye bir say� yoktur biz rakamlar� yan yana yazabiliriz)
	DECF HEDEFONLAR		;�imdi burada onlar basama�� 1 azalacakt�r ve birler basama�� 9 olacakt�r
	MOVLW 0X39			;40 dan sonraki de�erimiz 39 olacakt�r (2 par�a halinde d���n�rsek onlar basama�� 1 azald� birler basama��da 0 dan sonra 9 de�erini ald�)
	MOVWF HEDEFBIRLER	;pic kodlamak d���k seviye kodlama oldu�u i�in hangi ad�mda hangi de�i�imin olaca��n� detayl� �ekilde d���n�p kodlamam�z gerekmektedir


LOOP
	CALL OKU
	MOVLW 0X02
	CALL KOMUT_YAZ
	
	MOVLW 'S'		;LCD nin ilk sat�r�na adc den gelecek s�cakl�k de�eri S�cakl�k: �eklindeki metni yaz�rada��z
	CALL VERI_YAZ		;her ad�mda bir harf yazd�rabildi�imiz i�in harf harf yazmak zorunday�z
	MOVLW 'I'
	CALL VERI_YAZ
	MOVLW 'C'
	CALL VERI_YAZ
	MOVLW 'A'
	CALL VERI_YAZ
	MOVLW 'K'
	CALL VERI_YAZ
	MOVLW 'L'
	CALL VERI_YAZ
	MOVLW 'I'
	CALL VERI_YAZ
	MOVLW 'K'
	CALL VERI_YAZ
	MOVLW ':'
	CALL VERI_YAZ

	MOVF YUZLER,W		;S�cakl�k: yazd�rd�ktan sonra yan�na s�cakl�k de�erini yazmam�z gerekmektedir
	CALL VERI_YAZ			;yuzler onlar birler basama��na gelen de�erleri s�rayla yazarak 3 basamakl� s�cakl�k �l�me de�erini yazm�� olaca��z
						;ancak ben �al��mada hedef s�cakl��� 0-99 derece aras�nda tuttum daha ust s�cakl�k de�erleri normal �artlarda g�rmeyece�imiz i�in kod kalabal��� yapmadan biraz daha sade olsun istedim
	MOVF ONLAR,W		
	CALL VERI_YAZ

	MOVF BIRLER,W
	CALL VERI_YAZ

	MOVLW ' '
	CALL VERI_YAZ
	MOVLW 0XDF
	CALL VERI_YAZ
	MOVLW 'C'		;C harfi Derece nin Sembolik �fadesi Olan C dir 
	CALL VERI_YAZ
	CALL GECIKME2

	MOVLW 0X06		;2.sat�ra ge�meden �nce 0x06 de�erini workinge atarak i�e ba�l�yoruz
	CALL KOMUT_YAZ	;belki farkl� 2.sat�ra ge�me de�erleride vard�r
	CALL SATIR2		;ancak yapt���m bir�ok ara�t�rmadan sonra bu de�eri buldum ve kulland�m
	MOVLW 'H'
	CALL VERI_YAZ
	MOVLW 'E'
	CALL VERI_YAZ
	MOVLW 'D'
	CALL VERI_YAZ
	MOVLW 'E'
	CALL VERI_YAZ
	MOVLW 'F'
	CALL VERI_YAZ
	MOVLW ':'
	CALL VERI_YAZ

	MOVF HEDEFONLAR,W		;hedef de�erimizi 2 basamakl� olarak yazaca��m�z i�in onlar ve birler basamaklar�ndan olu�maktad�r 
	CALL VERI_YAZ

	MOVF HEDEFBIRLER,W 
	CALL VERI_YAZ

	MOVLW ' '			;Hedef De�erinin artmas� azalmas� i�in kontrol kullan�p
	CALL VERI_YAZ			;daha fazla kod yaz�p kar��t�rmak istemedim
	MOVLW 0XDF			;hedef s�canl�k 00 derece oldu�unda hedef s�cakl�k azaltmaya bast���m�zda
	CALL VERI_YAZ			;yada hedef 99 derece oldu�unda hedef s�cakl�k art�rmaya bast���n�zda
	MOVLW 'C'			;durmayacakt�r 00 daki hedefde eksiltme yaparsan�z /9
	CALL VERI_YAZ			;99 daki hedefte art�rmaya bast���n�zda :0 de�erini alacaks�n�z
	MOVLW ' '			;birler basama�� i�in kontrol yap�s� kullan�ld� 0-9 aras� says�n diye
	CALL VERI_YAZ			;onlar basama�� i�in 0-9 aras� bir k�s�tlama yap�s� konulmad�


	CALL GECIKME2
	GOTO DONUSTUR


OKU
	CLRF YUZLER
	CLRF ONLAR
	CLRF BIRLER
	CLRF PORTB

	MOVF OKUNAN_DEGER,W
	BANKSEL PORTC
	MOVWF PORTC
	MOVWF OKUNAN_DEGER
	
	
YUZLER_ARTIR
	MOVLW D'100'					;okunan de�er 100 den buyuk mu status carry bitine bakt���m�zda aritmetik i�lem sonucu negatif yada pozitif olarak de�erlenir ve carry biti buna g�re de�er al�r
	SUBWF OKUNAN_DEGER,W		;okunan de�erimiz kontrol etiketi alt�ndaki adresl nin de�eridir
	BTFSS STATUS,C  ;C=1 M� ARITMETIK SONUC + MI POZ�T�F M� ?
	GOTO ONLAR_ARTIR			;i�lem sonucu negatif ise carry biti 0 de�erini al�r pozitif ise 1 de�erini al�r	
	MOVWF OKUNAN_DEGER
	INCF YUZLER,F
	GOTO YUZLER_ARTIR
ONLAR_ARTIR					;okunan de�erimiz �rne�in 55 biz burda her 10 eksiltti�imizde onlar basam�� de�erini 1 artt�raca��z
	MOVLW D'10'				;54-10 = 44 onlar de�eri 1 oldu
	SUBWF OKUNAN_DEGER,W	;44-10 = 34 onlar de�eri 2 oldu
	BTFSS STATUS,C				;34-10 = 24 ... 24-10=14 ... 14-10=4 onlar de�eri 5 kere artm�� oldu
	GOTO BIRLER_ARTIR			;elimizde kalan de�er 4 oldu onlar basam��nndan arta kalan 
	MOVWF OKUNAN_DEGER		;kalan de�eride direk birler basama��na yaz�l�r
	INCF ONLAR,F				
	GOTO ONLAR_ARTIR
BIRLER_ARTIR
	MOVF OKUNAN_DEGER,W
	MOVWF BIRLER
	
	MOVLW 0X30			;ex-or i�lemi yaparak lcd panelde hesaplanan de�erleri yazmas�n� sa�l�yoruz
	IORWF YUZLER,F
	IORWF ONLAR,F
	IORWF BIRLER,F

ESITLIKBIRLER					;bu k�s�mda ust teki adc nen okunan de�er gibi hedef de�eri i�in olu�turulmu� sat�rlard�r
	MOVF HEDEFBIRLER,W ;0X35
	SUBWF BIRLER,W ;BIRLER-HEDEFBIRLER
	BTFSC STATUS,Z ;Z=1
	GOTO ESITLIKONLAR
	BSF PORTD,4
RETURN
ESITLIKONLAR
	MOVF HEDEFONLAR,W
	SUBWF ONLAR,W ;BIRLER-HEDEFBIRLER
	BTFSC STATUS,Z ;Z=1
	BCF PORTD,4
RETURN

KOMUT_YAZ
	MOVWF TEMP
	SWAPF TEMP,W ;EN ANLAMLI 4 B�T �LE EN ANLAMSIZ 4 B�T� DE���T�R
	CALL KOMUT_GONDER	;swap yapma amac�m�z 4 bit �al��t���m�z i�indir
	MOVF TEMP,W
	CALL KOMUT_GONDER
	RETURN

KOMUT_GONDER			;komut yaz komut g�nder temelde ayn�d�r
	MOVWF PORTB			;port �zerinden gelen veriyi i�ler
	BCF PORTB,4			;harf g�nderirsek harf yazd�raca��
	BSF PORTB,5			;komut g�nderirsek komut yazd�raca�� ayarlamas�
	CALL GECIKME			;RS piniyle yap�l�r (PortB,4.pin)
	BCF PORTB,5			;RS pinini clear yaparsak 0 g�nderirsek komut i�ler
	RETURN				;RS pinini 1 yaparsak Karekter i�ler
						;karekter dedi�imiz i�lem Asci tablosundaki herhangi bir
VERI_YAZ					;sembolun LCD �zerine yazmakt�r
	MOVWF TEMP			;komut i�leme olay� ise
	SWAPF TEMP,W		;lcd yi silmek --- lcd de imleci ba�a getirmek
	CALL VERI_GONDER		;lcd de 2.sat�ra ge�mek --- bunlar komuttur.
	MOVF TEMP,W
	CALL VERI_GONDER
	RETURN

VERI_GONDER
	ANDWF 0X0F
	MOVWF PORTB
	BSF PORTB,4
	BSF PORTB,5		;LCD de yapt���m�z i�lemlerin tamamlanmas� i�in E pinini
	CALL GECIKME		;RB,5 pini olmaktad�r set edip bekleyip sonra clear etmemiz gerekmetedir
	BCF PORTB,5		;E pini i�inde en az 450 NanoSaniye beklememiz gerekmektedir
	RETURN

SATIR2
	MOVLW 0XC0			;2.sat�r�n ba�lamas� i�in gerekli komut
	CALL KOMUT_YAZ
	MOVLW 0X14
	CALL KOMUT_YAZ
	MOVLW 0X14
	RETURN

GECIKME2				;lcd nin komut veya karekter i�lemesi i�in gerekli gecikme ayarlamalar�
	MOVLW 0XFF		;19,72 mikro saniyeyi yakla��k olarak tutturmaya �al���yoruz
	MOVWF DEGER		;8mhz h�z�nda �al���yoruz farkl� de�erlerde farkl� gecikme al�nabilir
	GOTO DON
GECIKME
	MOVLW 0X04 
	MOVWF DEGER
DON
	MOVLW 0X8F 
	MOVWF DEGER2
DON2
	DECFSZ DEGER2,1
	GOTO DON2
	DECFSZ DEGER,1
	GOTO DON
	RETURN				; ~~ WWW.mikroislemcim.com ~~
END
	