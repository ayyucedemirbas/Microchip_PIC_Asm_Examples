	list p=16F877A
	include "p16F877A.inc"	

	Sayac0 equ 0x20                      ;Genel 
	Sayac1 equ 0x21                      ;De�i�kenler
	Sayac2 equ 0x22                      ;Tan�mland�.
	Sayac_yazma_adres equ 0x23
	ORG 	0			
	clrf 	PCLATH			
	goto 	ana_program		
	ORG	4	

Kesme
	Retfie

ADC_Oku
	Banksel ADCON0                       ;ADCON0 i�in BANK0'a ge�.
	bsf	ADCON0, 2                        ;D�n���m� ba�lat.
    movlw d'1'				             
    call Delay                           

ADC_j1
	btfsc 	ADCON0, 2                    ;D�n��t�rme tamamlanana kadar bekle.
	goto 	ADC_j1
	bsf STATUS,RP0			 
	movf ADRESL,w                        ;En degersiz 8 biti workinge at.
	bcf STATUS,RP0                       
	movwf PORTB                          ;Onemsiz 8 biti PORTB de Goster. 
	movf ADRESH,w                        ;Degerli bitleri workinge at.
	movwf PORTC                          ;Onemli 2 biti PORTC de Goster.

	movlw d'15'                          ;Gecik.
	call Delay

	call Yazma_Ayari                     ;Yazma alt program�na dallan.
	call Okuma_Ayari                     ;Okuma alt program�na dallan.
	incfsz Sayac_yazma_adres,f           ;EEPROM dolana kadar bunu tekrarla.
	goto ADC_Oku 
 
Sadece_Okuma                             ;EEPROM dolunca sadece okuma k�sm�.
    Banksel PORTC                        
	bsf PORTC,7                          ;PORTC nin 7.bitini yak (Okuma var).
	movlw d'15'                          ;Gecik.
	call Delay                        
	call Okuma_Ayari                     ;Okuma alt program�na dallan.
	Banksel PORTC
	bcf PORTC,7                          ;Okuma bitti Ledi Sondur.
	incfsz Sayac_yazma_adres,f           ;EEPROM daki t�m degerler okunana kadar tekrarla.
	goto Sadece_Okuma
 
Sonsuzluk                                ;EEPROM daki t�m degerler donduyse sozsuz donguye gir.
	nop
	goto Sonsuzluk

Yazma_Ayari
	movf Sayac_yazma_adres,w
	banksel EEADR                                                            
	movwf 	EEADR                        ;Adres bilgisi y�klendi.
	banksel ADRESL
	movf ADRESL,w			             ;Adresl'yi oku.
	banksel EEDATA
	movwf	EEDATA                       ;EEDATA ya yani EEPROM a yaz�lacak veri 
                                         ;ADC De d�n��t�r�len en de�ersiz 8 bit.
	banksel EECON1                      
	bcf	EECON1,EEPGD                     ;Veri belle�ine eri�im izni.
	bcf	INTCON, GIE                      ;Genel kesmeler pasif. (Yazmada i�lem ak��� bozulmamal�.)
	bsf	EECON1, WREN                     ;Yazma etkinle�tirme bit�i set edildi.
	movlw	0x55                         ;Yazma i�in buradan itibaren 5 sat�r aynen korunmal�.                                  
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1, WR                       ;Yaz komutu verildi.
	
	Banksel PORTC                        
	bsf PORTC,6                          ;Yazma esnas�nda PORTC nin 6. Ledini yak.
	Banksel EECON1
	
dahili_ee_j1
	btfsc 	EECON1, WR                   ;Yazma i�lemi tamamlanana kadar bekle (WR=0 olana kadar).
	goto 	dahili_ee_j1
	bcf 	EECON1, WREN                 ;Yazma izni kald�r�ld�.

	Banksel PORTC
	bcf PORTC,6                          ;Yazma bittiyse PORTC nin 6. Ledini Sondur

	return


Okuma_Ayari
	movf Sayac_yazma_adres,w
	banksel EEADR                     
	movwf	EEADR                        ;Adres bilgisi y�klendi.
	banksel EECON1
	bcf	EECON1,EEPGD                     ;Veri belle�ine eri�im izni.
	bsf	EECON1, RD                       ;EEPROM Okuma modunda.
	banksel EEDATA
	movf	EEDATA, W
	banksel PORTD                        
	movwf	PORTD                        ;EEDATA daki de�er PORTD ye g�nderiliyor.
	return


ana_program
	movlw 	D'255'			             ;TRISA i�in y�nlendirme bilgis� W'ye y�kleniyor.
	Banksel TRISA                        
	movwf 	TRISA                        ;PORTA giri�e y�nlendirildi.
	clrf 	TRISB                        ;PORTB ��k��a y�nlendirildi.
	clrf    TRISC                        ;PORTC ��k��a y�nlendirildi.
	clrf	TRISD                        ;PORTD ��k��a y�nlendirildi.
	movlw 	0x80
	bsf 	STATUS, RP0                 
	movwf 	ADCON1                       ;ADCON1 Ayarlar� (Giri�ler Analog, Dahili RC Osilat�r)
	bcf 	STATUS, RP0                  
	clrf 	PORTB                        
	clrf	PORTD
	clrf Sayac_yazma_adres
	movlw 	0xD1
	movwf 	ADCON0                       ;ADCON0 Ayarlar� (AN2 Seciliyor, ADC A�, Frekans Sec)
    movlw d'1'				             
    call Delay                           
	goto  	ADC_Oku                      ;ADC Baslat.

Delay					                 ;Gecikme Program�
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

