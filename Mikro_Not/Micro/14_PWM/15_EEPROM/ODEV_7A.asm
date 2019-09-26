	list p=16F877A
	include "p16F877A.inc"	

	Sayac0 equ 0x20                      ;Genel 
	Sayac1 equ 0x21                      ;Deðiþkenler
	Sayac2 equ 0x22                      ;Tanýmlandý.
	Sayac_yazma_adres equ 0x23
	ORG 	0			
	clrf 	PCLATH			
	goto 	ana_program		
	ORG	4	

Kesme
	Retfie

ADC_Oku
	Banksel ADCON0                       ;ADCON0 için BANK0'a geç.
	bsf	ADCON0, 2                        ;Dönüþümü baþlat.
    movlw d'1'				             
    call Delay                           

ADC_j1
	btfsc 	ADCON0, 2                    ;Dönüþtürme tamamlanana kadar bekle.
	goto 	ADC_j1
	bsf STATUS,RP0			 
	movf ADRESL,w                        ;En degersiz 8 biti workinge at.
	bcf STATUS,RP0                       
	movwf PORTB                          ;Onemsiz 8 biti PORTB de Goster. 
	movf ADRESH,w                        ;Degerli bitleri workinge at.
	movwf PORTC                          ;Onemli 2 biti PORTC de Goster.

	movlw d'15'                          ;Gecik.
	call Delay

	call Yazma_Ayari                     ;Yazma alt programýna dallan.
	call Okuma_Ayari                     ;Okuma alt programýna dallan.
	incfsz Sayac_yazma_adres,f           ;EEPROM dolana kadar bunu tekrarla.
	goto ADC_Oku 
 
Sadece_Okuma                             ;EEPROM dolunca sadece okuma kýsmý.
    Banksel PORTC                        
	bsf PORTC,7                          ;PORTC nin 7.bitini yak (Okuma var).
	movlw d'15'                          ;Gecik.
	call Delay                        
	call Okuma_Ayari                     ;Okuma alt programýna dallan.
	Banksel PORTC
	bcf PORTC,7                          ;Okuma bitti Ledi Sondur.
	incfsz Sayac_yazma_adres,f           ;EEPROM daki tüm degerler okunana kadar tekrarla.
	goto Sadece_Okuma
 
Sonsuzluk                                ;EEPROM daki tüm degerler donduyse sozsuz donguye gir.
	nop
	goto Sonsuzluk

Yazma_Ayari
	movf Sayac_yazma_adres,w
	banksel EEADR                                                            
	movwf 	EEADR                        ;Adres bilgisi yüklendi.
	banksel ADRESL
	movf ADRESL,w			             ;Adresl'yi oku.
	banksel EEDATA
	movwf	EEDATA                       ;EEDATA ya yani EEPROM a yazýlacak veri 
                                         ;ADC De dönüþtürülen en deðersiz 8 bit.
	banksel EECON1                      
	bcf	EECON1,EEPGD                     ;Veri belleðine eriþim izni.
	bcf	INTCON, GIE                      ;Genel kesmeler pasif. (Yazmada iþlem akýþý bozulmamalý.)
	bsf	EECON1, WREN                     ;Yazma etkinleþtirme bit’i set edildi.
	movlw	0x55                         ;Yazma için buradan itibaren 5 satýr aynen korunmalý.                                  
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1, WR                       ;Yaz komutu verildi.
	
	Banksel PORTC                        
	bsf PORTC,6                          ;Yazma esnasýnda PORTC nin 6. Ledini yak.
	Banksel EECON1
	
dahili_ee_j1
	btfsc 	EECON1, WR                   ;Yazma iþlemi tamamlanana kadar bekle (WR=0 olana kadar).
	goto 	dahili_ee_j1
	bcf 	EECON1, WREN                 ;Yazma izni kaldýrýldý.

	Banksel PORTC
	bcf PORTC,6                          ;Yazma bittiyse PORTC nin 6. Ledini Sondur

	return


Okuma_Ayari
	movf Sayac_yazma_adres,w
	banksel EEADR                     
	movwf	EEADR                        ;Adres bilgisi yüklendi.
	banksel EECON1
	bcf	EECON1,EEPGD                     ;Veri belleðine eriþim izni.
	bsf	EECON1, RD                       ;EEPROM Okuma modunda.
	banksel EEDATA
	movf	EEDATA, W
	banksel PORTD                        
	movwf	PORTD                        ;EEDATA daki deðer PORTD ye gönderiliyor.
	return


ana_program
	movlw 	D'255'			             ;TRISA için yönlendirme bilgisÝ W'ye yükleniyor.
	Banksel TRISA                        
	movwf 	TRISA                        ;PORTA giriþe yönlendirildi.
	clrf 	TRISB                        ;PORTB çýkýþa yönlendirildi.
	clrf    TRISC                        ;PORTC çýkýþa yönlendirildi.
	clrf	TRISD                        ;PORTD çýkýþa yönlendirildi.
	movlw 	0x80
	bsf 	STATUS, RP0                 
	movwf 	ADCON1                       ;ADCON1 Ayarlarý (Giriþler Analog, Dahili RC Osilatör)
	bcf 	STATUS, RP0                  
	clrf 	PORTB                        
	clrf	PORTD
	clrf Sayac_yazma_adres
	movlw 	0xD1
	movwf 	ADCON0                       ;ADCON0 Ayarlarý (AN2 Seciliyor, ADC Aç, Frekans Sec)
    movlw d'1'				             
    call Delay                           
	goto  	ADC_Oku                      ;ADC Baslat.

Delay					                 ;Gecikme Programý
	movwf Sayac0	                   
Dongu1				                     
	movlw d'8'		                    
	movwf Sayac1                        
Dongu2			                       
	clrf Sayac2	                        
Dongu3:		                            
	incfsz Sayac2,f	                 
	goto Dongu3		                  
	decfsz Sayac1,f	                   
	goto Dongu2	                       
	decfsz Sayac0,f	                    
	goto Dongu1                           
	return                               

	END

