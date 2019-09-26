	LIST P=16F877A
;Erdogan Canbay Tarafýndan Dizayn Edildi Fýrat Universitesi Bilgisayar Muhendisligi Öðrencisi
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

	BANKSEL ADCON0		;A portu normalde analogdur hangi portlardan analog hangi portlardan dýjýtal çýkýþ alacaðýmýzý adcon registeri ile belirleriz
	MOVLW B'11000001'		;Register ayarlamasý ve port ayarlamarýný yapýyoruz
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
	MOVLW 0X30 			;hedef deðerinin birler basamaðý
	MOVWF HEDEFBIRLER 
	MOVLW 0X30 			;hedef basamaðýnýn onlar deðeri
	MOVWF HEDEFONLAR 	;0x30 ascii kod duzeninde 0 sayýsýna denk gelmektedir

TEMIZLE	
	MOVLW 0X02			;lcd paneli ile igili kodlar 
	CALL KOMUT_YAZ		;örneðin 0x02 satýr baþýna imleci getirir
	MOVLW 0X28			;Lcd ile ilgili iþlem yapmadan önce bu tarz ayarlamalarý
	CALL KOMUT_YAZ		;yapýp lcd yi kullanýma hazýrlmamýz gerekmektedir
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
	GOTO KONTROL	;dönüþtürme iþlemi bittiyse adresL ye bir deðer yüklenmiþ olacaktýr
	BANKSEL ADRESL  	;adresL yada AdresH a atanacak deðer ADFM biti ile belirlenecektir
	MOVF ADRESL,W	;ADFM 1 olursa saða dayalý (AdresH a yazar)
	BCF STATUS,RP0		;ADFM 0 olursa Sola Dayalý (AdresL ye yazar)
	MOVWF OKUNAN_DEGER
	
	BTFSC PORTD,0
	GOTO ARTTIR
	BTFSC PORTD,1
	GOTO AZALT	
	GOTO LOOP

ARTTIR
	MOVLW 0X39			;Hedef birler basamaðý 9 olduysa (Asci de 0x39 a denk gelir)
	SUBWF HEDEFBIRLER,W 	;9 dan sonra 0 yaz 
	BTFSS STATUS,C      		 
	INCF HEDEFBIRLER
	BTFSS STATUS,C      
	GOTO LOOP			;birler basamaðý 9 olduktan sonra onlar basamaðýnýn 1 artýp birler basamaðýnýn tekrar 0 olmasý gerekmektedir
	INCF HEDEFONLAR		;ve hedef onlar onlar basamaðýný arttýr
	MOVLW 0X30			;9 sayýsýdan sonra tekrar 0 deðerini birler basamðýna atamamýz gerekiyor
	MOVWF HEDEFBIRLER
	GOTO LOOP
	
AZALT
	MOVLW 0X31			;azaltma deðeri için birler basamðýnýn 0 olduðu durumda tekrar 9 deðerini atayarak yapýyoruz 
	SUBWF HEDEFBIRLER,W ; HEDEFBIRLER-0X30
	BTFSC STATUS,C       ; C=1 DEGER3 > 0X30
	DECF HEDEFBIRLER
	BTFSC STATUS,C			;örneðin deðerimiz 45 44 43 42 41 40 diye azalýyor
	GOTO LOOP			;40 sayýsýnda onlar basamðý 4 birler basamaðý 0 dýr (2 parça halinde düþünmek zorundayýz zira asci kodlamada 40 diye bir sayý yoktur biz rakamlarý yan yana yazabiliriz)
	DECF HEDEFONLAR		;þimdi burada onlar basamaðý 1 azalacaktýr ve birler basamaðý 9 olacaktýr
	MOVLW 0X39			;40 dan sonraki deðerimiz 39 olacaktýr (2 parça halinde düþünürsek onlar basamaðý 1 azaldý birler basamaðýda 0 dan sonra 9 deðerini aldý)
	MOVWF HEDEFBIRLER	;pic kodlamak düþük seviye kodlama olduðu için hangi adýmda hangi deðiþimin olacaðýný detaylý þekilde düþünüp kodlamamýz gerekmektedir


LOOP
	CALL OKU
	MOVLW 0X02
	CALL KOMUT_YAZ
	
	MOVLW 'S'		;LCD nin ilk satýrýna adc den gelecek sýcaklýk deðeri Sýcaklýk: þeklindeki metni yazýradaðýz
	CALL VERI_YAZ		;her adýmda bir harf yazdýrabildiðimiz için harf harf yazmak zorundayýz
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

	MOVF YUZLER,W		;Sýcaklýk: yazdýrdýktan sonra yanýna sýcaklýk deðerini yazmamýz gerekmektedir
	CALL VERI_YAZ			;yuzler onlar birler basamaðýna gelen deðerleri sýrayla yazarak 3 basamaklý sýcaklýk ölçme deðerini yazmýþ olacaðýz
						;ancak ben çalýþmada hedef sýcaklýðý 0-99 derece arasýnda tuttum daha ust sýcaklýk deðerleri normal þartlarda görmeyeceðimiz için kod kalabalýðý yapmadan biraz daha sade olsun istedim
	MOVF ONLAR,W		
	CALL VERI_YAZ

	MOVF BIRLER,W
	CALL VERI_YAZ

	MOVLW ' '
	CALL VERI_YAZ
	MOVLW 0XDF
	CALL VERI_YAZ
	MOVLW 'C'		;C harfi Derece nin Sembolik Ýfadesi Olan C dir 
	CALL VERI_YAZ
	CALL GECIKME2

	MOVLW 0X06		;2.satýra geçmeden önce 0x06 deðerini workinge atarak iþe baþlýyoruz
	CALL KOMUT_YAZ	;belki farklý 2.satýra geçme deðerleride vardýr
	CALL SATIR2		;ancak yaptýðým birçok araþtýrmadan sonra bu deðeri buldum ve kullandým
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

	MOVF HEDEFONLAR,W		;hedef deðerimizi 2 basamaklý olarak yazacaðýmýz için onlar ve birler basamaklarýndan oluþmaktadýr 
	CALL VERI_YAZ

	MOVF HEDEFBIRLER,W 
	CALL VERI_YAZ

	MOVLW ' '			;Hedef Deðerinin artmasý azalmasý için kontrol kullanýp
	CALL VERI_YAZ			;daha fazla kod yazýp karýþtýrmak istemedim
	MOVLW 0XDF			;hedef sýcanlýk 00 derece olduðunda hedef sýcaklýk azaltmaya bastýðýmýzda
	CALL VERI_YAZ			;yada hedef 99 derece olduðunda hedef sýcaklýk artýrmaya bastýðýnýzda
	MOVLW 'C'			;durmayacaktýr 00 daki hedefde eksiltme yaparsanýz /9
	CALL VERI_YAZ			;99 daki hedefte artýrmaya bastýðýnýzda :0 deðerini alacaksýnýz
	MOVLW ' '			;birler basamaðý için kontrol yapýsý kullanýldý 0-9 arasý saysýn diye
	CALL VERI_YAZ			;onlar basamaðý için 0-9 arasý bir kýsýtlama yapýsý konulmadý


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
	MOVLW D'100'					;okunan deðer 100 den buyuk mu status carry bitine baktýðýmýzda aritmetik iþlem sonucu negatif yada pozitif olarak deðerlenir ve carry biti buna göre deðer alýr
	SUBWF OKUNAN_DEGER,W		;okunan deðerimiz kontrol etiketi altýndaki adresl nin deðeridir
	BTFSS STATUS,C  ;C=1 MÝ ARITMETIK SONUC + MI POZÝTÝF MÝ ?
	GOTO ONLAR_ARTIR			;iþlem sonucu negatif ise carry biti 0 deðerini alýr pozitif ise 1 deðerini alýr	
	MOVWF OKUNAN_DEGER
	INCF YUZLER,F
	GOTO YUZLER_ARTIR
ONLAR_ARTIR					;okunan deðerimiz örneðin 55 biz burda her 10 eksilttiðimizde onlar basamðý deðerini 1 arttýracaðýz
	MOVLW D'10'				;54-10 = 44 onlar deðeri 1 oldu
	SUBWF OKUNAN_DEGER,W	;44-10 = 34 onlar deðeri 2 oldu
	BTFSS STATUS,C				;34-10 = 24 ... 24-10=14 ... 14-10=4 onlar deðeri 5 kere artmýþ oldu
	GOTO BIRLER_ARTIR			;elimizde kalan deðer 4 oldu onlar basamðýnndan arta kalan 
	MOVWF OKUNAN_DEGER		;kalan deðeride direk birler basamaðýna yazýlýr
	INCF ONLAR,F				
	GOTO ONLAR_ARTIR
BIRLER_ARTIR
	MOVF OKUNAN_DEGER,W
	MOVWF BIRLER
	
	MOVLW 0X30			;ex-or iþlemi yaparak lcd panelde hesaplanan deðerleri yazmasýný saðlýyoruz
	IORWF YUZLER,F
	IORWF ONLAR,F
	IORWF BIRLER,F

ESITLIKBIRLER					;bu kýsýmda ust teki adc nen okunan deðer gibi hedef deðeri için oluþturulmuþ satýrlardýr
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
	SWAPF TEMP,W ;EN ANLAMLI 4 BÝT ÝLE EN ANLAMSIZ 4 BÝTÝ DEÐÝÞTÝR
	CALL KOMUT_GONDER	;swap yapma amacýmýz 4 bit çalýþtýðýmýz içindir
	MOVF TEMP,W
	CALL KOMUT_GONDER
	RETURN

KOMUT_GONDER			;komut yaz komut gönder temelde aynýdýr
	MOVWF PORTB			;port üzerinden gelen veriyi iþler
	BCF PORTB,4			;harf gönderirsek harf yazdýracaðý
	BSF PORTB,5			;komut gönderirsek komut yazdýracaðý ayarlamasý
	CALL GECIKME			;RS piniyle yapýlýr (PortB,4.pin)
	BCF PORTB,5			;RS pinini clear yaparsak 0 gönderirsek komut iþler
	RETURN				;RS pinini 1 yaparsak Karekter iþler
						;karekter dediðimiz iþlem Asci tablosundaki herhangi bir
VERI_YAZ					;sembolun LCD üzerine yazmaktýr
	MOVWF TEMP			;komut iþleme olayý ise
	SWAPF TEMP,W		;lcd yi silmek --- lcd de imleci baþa getirmek
	CALL VERI_GONDER		;lcd de 2.satýra geçmek --- bunlar komuttur.
	MOVF TEMP,W
	CALL VERI_GONDER
	RETURN

VERI_GONDER
	ANDWF 0X0F
	MOVWF PORTB
	BSF PORTB,4
	BSF PORTB,5		;LCD de yaptýðýmýz iþlemlerin tamamlanmasý için E pinini
	CALL GECIKME		;RB,5 pini olmaktadýr set edip bekleyip sonra clear etmemiz gerekmetedir
	BCF PORTB,5		;E pini içinde en az 450 NanoSaniye beklememiz gerekmektedir
	RETURN

SATIR2
	MOVLW 0XC0			;2.satýrýn baþlamasý için gerekli komut
	CALL KOMUT_YAZ
	MOVLW 0X14
	CALL KOMUT_YAZ
	MOVLW 0X14
	RETURN

GECIKME2				;lcd nin komut veya karekter iþlemesi için gerekli gecikme ayarlamalarý
	MOVLW 0XFF		;19,72 mikro saniyeyi yaklaþýk olarak tutturmaya çalýþýyoruz
	MOVWF DEGER		;8mhz hýzýnda çalýþýyoruz farklý deðerlerde farklý gecikme alýnabilir
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
	