// *****************************************************************
// Dosya Adý		: 13_1.c
// Açýklama		: DC motor hýz ve yön kontrolü 
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
#define MOTOR           PORTC
#define MOTOR_tris      TRISC
#define yon             F0
#define enable          F1
#define hiz             F2
#define GUC_butonu      F4
#define YON_butonu      F5
#define ARTIR_butonu    F6
#define AZALT_butonu    F7

char mhiz;

// Pin giriþ-çýkýþlarý ve PWM modülü ayarlanýyor.
void init()
{
     TRISD = 0;
     MOTOR = 0;
     MOTOR_tris.GUC_butonu = 1;
     MOTOR_tris.YON_butonu = 1;
     MOTOR_tris.ARTIR_butonu = 1;
     MOTOR_tris.AZALT_butonu = 1;
     MOTOR_tris.yon = 0;
     MOTOR_tris.enable = 0;
     MOTOR_tris.hiz = 0;
     Pwm_Init(250);
     mhiz = 128;
}
// Ana Program.
void main()
{
     init();
     while(1)
     {
           if(MOTOR.GUC_butonu)
           {
                Pwm_Start();
                MOTOR.enable = 1;
           } else
           {
                Pwm_Stop();
                MOTOR.enable = 0;
           }
           if(MOTOR.YON_butonu) MOTOR.yon = 1; else MOTOR.yon = 0;
           if(!MOTOR.ARTIR_butonu) if(mhiz<255) mhiz++;
           if(!MOTOR.AZALT_butonu) if(mhiz>0) mhiz--;
           if(MOTOR.YON_butonu) Pwm_Change_Duty(~mhiz); 
else Pwm_Change_Duty(mhiz);
           PORTD = mhiz;
           Delay_ms(10);
     }
}
// *****************************************************************
