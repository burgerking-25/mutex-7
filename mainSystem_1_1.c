#include <timers.h>
#include <p18f452.h>
#include "xlcd_grpd.h"
//#include "sst39sf040.h"
#include "ow.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <delays.h>
#include <pwm.h>
#include <capture.h>
#include <adc.h>
//#include <usart.h>

/* Set configuration bits for use with ICD2 / PICDEM2 PLUS Demo Board:
 * - set HS oscillator
 * - disable watchdog timer
 * - disable low voltage programming
 */
#pragma config OSC = HS
#pragma config WDT = OFF
#pragma config LVP = OFF

// CONFIG3H
#pragma config CCP2MUX = OFF    // CCP2 Mux bit (CCP2 input/output is multiplexed with RB3)

#define _XTAL_FREQ 4000000UL
#define CLR_DISP 0b00000001

#define toneA 153
#define toneB 125

#define x 2 //total number of notes in song to be played - modify for specific song

//#define set_port_kbd PORTC // Change if port is different
#define row1port LATCbits.LATC0
#define row2port LATCbits.LATC1
#define row3port LATDbits.LATD3
//#define row3port LATCbits.LATC2
#define row4port LATCbits.LATC3
#define col1port PORTCbits.RC4
#define col2port PORTCbits.RC5
#define col3port PORTCbits.RC6//PORTBbits.RB1
#define col4port PORTCbits.RC7//PORTBbits.RB2   //if a 4x4 keypad is used
#define S1 PORTBbits.RB5
#define TRISS1 TRISBbits.TRISB5
#define S0 PORTBbits.RB4
#define TRISS0 TRISBbits.TRISB4

/*Variables Definitions*/
char key, old_key;
void displayTemp(void);

/*void eraseSector(char, char, char);
void writeAddress(char,char,char);
void writeData(char,char,char,char);
void readData(char , char , char );*/
char const keyPadMatrix[] ={
    '1', '2', '3', 'A',
    '4', '5', '6', 'B',
    '7', '8', '9', 'C',
    '0', 'F', 'E', 'D',
    0xFF
};

volatile struct sav {
    unsigned TEMP : 1;
    unsigned HRV : 1;
    unsigned BPM : 1;
   /* unsigned GLU : 1;*/
} STORE;

/*STORE.TEMP = 0;
STORE.HRV = 0;
STORE.BPM = 0;*/


/*HR & HRV*/
int tenCount = 0, heartBeat = 0, bpmObt = 0, risEdg = 0;
unsigned int cptOut1 = 0, cptOut2 = 0, riseEdge = 0, interval = 0, ovrFlw = 0, cnt = 0, prev = 0, k = 0, fin = 0, nn = 0, nn_50 = 0;
float hrv = 0;

/*Alert Related*/
int song[x]={toneA, toneB}; //insert notes of song in array
int length[x]={1, 1}; //relative length of each note


/*Temp sensor Related*/
unsigned char tmpyMSB,tmpyLSB,degree = 0xDF;
unsigned int msbTmpy = 0,lsbTmpy = 0,intPart = 0;
float fFracPart = 0.0000;
int sign = 0;
int iFracPart =0;
int cnvCnt = 0;
char tempResult[20];



/*ADC Related*/
//float result;
//float voltage,adcRlts;
//int int_part, decimal_part;
//char buffer[8];


/*Variables Definitions*/

/**/
/**/

#pragma code
/*****************High priority ISR **************************/
#pragma interrupt high_isr

void high_isr(void) {
    float temp = 0;
    if (INTCONbits.TMR0IF == 1) { // Interrupt Check 
        tenCount = tenCount + 1;
        if (tenCount == 10) {
            CloseTimer0();
            bpmObt = 1;

            INTCONbits.TMR0IF = 0;
        } else {
            INTCONbits.TMR0IF = 0;
            WriteTimer0(0xBDC);
        }
    }
    if (INTCONbits.INT0F == 1) {
        LATAbits.LATA1 = 1;
        risEdg = risEdg + 1;
        INTCONbits.INT0F = 0;
    }

    if (PIR1bits.TMR1IF == 1) {
        PIR1bits.TMR1IF = 0;
        ovrFlw++;
    }
    if (PIR1bits.CCP1IF == 1) {
        LATAbits.LATA0 = 1;
        PIR1bits.CCP1IF = 0;
        if (riseEdge == 0) {
            if (k == 0) {
                cptOut1 = ReadCapture1();
            } else {
                cptOut2 = ReadCapture1();
            }
        } else if ((riseEdge == 1) && (k == 0)) {
            cptOut2 = ReadCapture1();
        }
        riseEdge++;
        if ((riseEdge > 1) || (k == 1)) {
            k = 1;
            interval = 65535 * ovrFlw + cptOut2 - cptOut1;
            nn++;
            prev = cptOut2;
            cptOut1 = prev;
            temp = (float) interval / (float) 1000;
            if ((float) temp > (float) 50) {
                nn_50++;
            }
            riseEdge = 0;
            if (nn > 15) {
                hrv = (float) nn_50 / (float) 15;
                hrv = hrv * 100;
                fin = 1;
                CloseCapture1();
                CloseTimer1();
            }
        }
    }
    /*if(PIR1bits.ADIF == 1){
        PIR1bits.ADIF = 0;
        result = ReadADC();   // Read result
        voltage = ((result*5)/1023.0);
        ADCON0bits.GO_DONE = 1; 
        displayAdc();
    }*/
}

/*****************High priority interrupt vector **************************/
#pragma code high_vector=0x08

void interrupt_at_high_vector(void) {
    _asm
    GOTO high_isr
    _endasm
}

void DelayFor18TCY(void) {
    Delay10TCYx(20); //delays 20 cycles
    return;
}

void DelayPORXLCD(void) // minimum 15ms
{
    Delay1KTCYx(15);
    return;
}

void DelayXLCD(void) // minimum 5ms
{
    Delay1KTCYx(5);
    return;
}

void initLCD(void) {
    OpenXLCD(FOUR_BIT & LINES_5X7);
    while (BusyXLCD());
    WriteCmdXLCD(FOUR_BIT & LINES_5X7);
    while (BusyXLCD());
    WriteCmdXLCD(BLINK_ON);
    while (BusyXLCD());
    WriteCmdXLCD(CLR_DISP);
    while (BusyXLCD());
}

//Run initLCD(); before running this 

void prtStrLitLCD(int lineNum, rom const char * string) {
    if (lineNum == 1) {
        SetDDRamAddr(0x00);
        while (BusyXLCD());
        putrsXLCD(string);
        while (BusyXLCD());
    } else if (lineNum == 2) {
        SetDDRamAddr(0x40);
        while (BusyXLCD());
        putrsXLCD(string);
        while (BusyXLCD());
    } else if (lineNum == 3) {
        SetDDRamAddr(0x10);
        while (BusyXLCD());
        putrsXLCD(string);
        while (BusyXLCD());
    } else if (lineNum == 4) {
        SetDDRamAddr(0x50);
        while (BusyXLCD());
        putrsXLCD(string);
        while (BusyXLCD());
    } else {
        SetDDRamAddr(0x00);
        while (BusyXLCD());
        putrsXLCD("ERROR: line #");
        while (BusyXLCD());
    }
}

//Run initLCD(); before running this 

void prtStrLCD(int lineNum, char * string) {
    if (lineNum == 1) {
        SetDDRamAddr(0x00);
        while (BusyXLCD());
        putsXLCD(string);
        while (BusyXLCD());
    } else if (lineNum == 2) {
        SetDDRamAddr(0x40);
        while (BusyXLCD());
        putsXLCD(string);
        while (BusyXLCD());
    } else if (lineNum == 3) {
        SetDDRamAddr(0x10);
        while (BusyXLCD());
        putsXLCD(string);
        while (BusyXLCD());
    } else if (lineNum == 4) {
        SetDDRamAddr(0x50);
        while (BusyXLCD());
        putsXLCD(string);
        while (BusyXLCD());
    } else {
        SetDDRamAddr(0x00);
        while (BusyXLCD());
        putrsXLCD("ERROR: line #");
        while (BusyXLCD());
    }
}

void initPorts() {
    PORTC = 0x00;
    LATC = 0x00;
    TRISC = 0xF4;
    TRISAbits.RA0 = 0;
    TRISAbits.RA1 = 0;
    TRISBbits.RB0 = 1;
    TRISBbits.RB1 = 1;
    TRISBbits.RB2 = 1;
    TRISS0 = 0;
    TRISS1 = 0;
    TRISBbits.RB3 = 0;
    PORTD = 0x00;
    TRISD = 0x00;
}

//void initUSART(void)
//{
//	OpenUSART(USART_RX_INT_ON & USART_EIGHT_BIT & USART_ASYNCH_MODE & USART_BRGH_HIGH
//			& USART_SINGLE_RX, 25); //9600 baud
//}


void initTimers() {
    INTCONbits.TMR0IE = 1; //Enable Timer0 Interrupt
    INTCONbits.TMR0IF = 0; //Clear Timer0 Interrupt Flag
    INTCON2bits.TMR0IP = 1; //Enable Priority Levels
    TMR1H = 0x00; // clear timer1 
    TMR1L = 0x00;
    T1CON = 0x81; // 10000001; Timer1 enabled; prescale 1:1 
    OpenTimer0(TIMER_INT_ON & T0_SOURCE_INT & T0_PS_1_16 & T0_16BIT);
    OpenTimer2(TIMER_INT_OFF & T0_PS_1_4 & T2_POST_1_1 );
}

void initInterrupts() {
    INTCONbits.INT0E = 1; // Enables the INT0 external interrupt
    INTCONbits.INT0F = 0; //The INT0 external interrupt occurred (must be cleared in software)   
    INTCON2bits.INTEDG0 = 1; //Interrupt on rising edge 
    PIE1bits.CCP1IE = 1; // CCP1 interrupt enabled 
    RCONbits.IPEN = 1; //Enable Priority Levels
    INTCONbits.GIEH = 1;
    INTCONbits.GIE = 1; // enable interrupts 
    INTCONbits.PEIE = 1;
    PIR1 = 0x00; // clear the interrupt flags 
    RCONbits.IPEN = 1; // interrupt priority enabled
    CCP1CON = 0x05; // 00000101; CCP1 as capture mode, every rising edge  
    IPR1 = 0x04; // 00000100; CCP1 interrupt set to high priority 
    //PIE1bits.ADIE = 1; // ADC interrupt enabled 
    //IPR1bits.ADIP = 1; //ADC interrupt set to high priority 
    //PIR1bits.ADIF = 0;////Clear ADC Interrupt Flag
}

void intitPWM(){
    TRISBbits.RB3 = 0; //Make CCP2 pin as output for RB3
    SetDCPWM2(30);
}

void intitADC(){
    OpenADC(ADC_FOSC_RC&ADC_RIGHT_JUST&ADC_8ANA_0REF,ADC_CH2&ADC_INT_ON);
}

int getKeyPress() {
    // This routine returns the first key found to be pressed during the scan.
    char key = 0, row;
    for (row = 0b00000001; row < 0b00010000; row <<= 1) {
        { // turn on row output
            row1port = (row & 0x0001) >> 0;
            row2port = (row & 0x0002) >> 1;
            row3port = (row & 0x0004) >> 2;
            row4port = (row & 0x0008) >> 3;
            Delay100TCYx(0xF6);
        }
        // read colums - break when key press detected
        if (col1port)break;
        key++;
        if (col2port)break;
        key++;
        if (col3port)break;
        key++;
        if (col4port)break;
        key++;
    }
    row1port = 0;
    row2port = 0;
    row3port = 0;
    row4port = 0;
    if (key != old_key) {
        old_key = key;
        return keyPadMatrix[ key ];
    } else {
        return keyPadMatrix[ 0x10 ];
    }
}

int getBpm() {
    int val = 0;
    val = heartBeat * 6;
    return val;
}

int getHrv() {
    int hrvValue = 0;
    hrvValue = hrv;
    return hrvValue;
}

void displayBpm(int bpmVal) {
    char buffer[80];
    if (STORE.BPM == 1)
    {
        sprintf(buffer, "HR *: %d bpm", bpmVal);
        prtStrLCD(1, buffer);
    }
    else{
        sprintf(buffer, "HR: %d bpm", bpmVal);
        prtStrLCD(1, buffer);
    }
}

void displayHrv(int hrvVal) {
    char buffer[16];
    if (STORE.HRV == 1){
        sprintf(buffer, "HRV *: %d%", hrvVal);
        prtStrLCD(2, buffer);
    }
    else{
        sprintf(buffer, "HRV: %d%", hrvVal);
        prtStrLCD(2, buffer);        
    }
        
}

void displayTemp(void)
{
        char buffer[20];
    if (STORE.TEMP == 1){
        strcpy(buffer, tempResult);
        strcat(buffer,"*");
        prtStrLCD(3, buffer);
    }
    else{
        strcpy(buffer, tempResult);
        strcat(buffer,"_");
        prtStrLCD(3, buffer);        
    }
}

/*void displayAdc(){
    int_part = (int)voltage ;
    adcRlts = int_part;
    decimal_part = (voltage - int_part) * 10;
    sprintf(buffer,(far char*)"ADC: %i.%i", int_part, decimal_part);
    prtStrLCD(3, buffer);
}*/

//void restValues(){
//    cptOut1=0,cptOut2=0,riseEdge=0,interval=0,ovrFlw=0,cnt=0,prev=0,k=0,fin=0,nn=0,nn_50=0;
//    tenCount = 0,heartBeat = 0,bpmObt = 0,risEdg = 0;
//    
//}
void restValues(){
    cptOut1=0,cptOut2=0,riseEdge=0,interval=0,ovrFlw=0,cnt=0,prev=0,k=0,fin=0,nn=0,nn_50=0;
    tenCount = 0,heartBeat = 0,bpmObt = 0,risEdg = 0;
	msbTmpy = 0,lsbTmpy = 0;intPart = 0;
	fFracPart = 0.0000;
	sign = 0;
	iFracPart =0;
	cnvCnt = 0;
}
void setTone(int i){
    OpenPWM2(song[i]);;//set PWM frequency according to entries in song array
    Delay1KTCYx(400*length[i]); //each note is played for 400ms*relative length
    OpenPWM2(1); //the PWM frequency set beyond audible range                         
    //in order to create a short silence between notes
    Delay10KTCYx(25);   //the silence is played for 50 ms

}
void mainSystem(char keyPress) {
    int bpmVal ;
    int hrvVal;
    int tempVal;
    int i = 0;
    
    restValues();
    
    intitPWM();
    initTimers();
    initInterrupts();
    //initUSART();
    

    WriteCmdXLCD(CLR_DISP);
    while (1) {
        SetDCPWM2(0);
        LATAbits.LATA0 = 0;
        LATAbits.LATA1 = 0;
        //intitADC();
        Delay1KTCYx(100);     // Delay for 50TCY
        //ConvertADC();         // Start conversion  
        //displayAdc();
        if (bpmObt == 0) {
            heartBeat = risEdg;
            //displayBpm(0);
            //displayHrv(0);

        }
        else {
            CloseTimer0();
            bpmVal = getBpm();
            if(bpmVal > 100){
                if(i == 2){
                    i = 0;
                }
                setTone(i);
                i++;
            }
            hrvVal = getHrv();
            

        }
      
        displayBpm(bpmVal);
            displayHrv(hrvVal);
            displayTemp();
        keyPress = getKeyPress();
        if(keyPress == 'A'){
            SetDCPWM2(0);
            PIE1bits.CCP1IE = 0; // CCP1 interrupt enabled 
            INTCONbits.INT0E = 0; // Enables the INT0 external interrupt
            INTCONbits.GIEH = 0;
            INTCONbits.GIE = 0; // enable interrupts 
                        break;


            }
  
    
          
        
        }
    }


// --------------------------TEMP------------

void getTemp(){
	
	ow_reset();  //reset 1822P
	ow_write_byte(0xCC); // Skip ROM Check
	ow_write_byte(0x44); //Temperature conversion 
	
	PORTBbits.RB2 = 1;  //Strong pullup to provide current that parasitic capacitance can't provide
	
	for(cnvCnt = 1; cnvCnt<=8;cnvCnt++){ //800ms (750ms is recommended conversion time))
	   Delay1KTCYx(100);
	}
	
	PORTBbits.RB2 = 0; //Turn off strong pullup
	
	//Read Dallas 1822P
	ow_reset(); //reset device
	ow_write_byte(0xCC); //skip ROM check
	ow_write_byte(0xBE); //Send read scratchpad on 1822P
	tmpyLSB = ow_read_byte(); //Read first byte, LS and store in tmpyLSB
	tmpyMSB = ow_read_byte(); //Read first byte, MS and store in tmpyMSB
	//Really don't care about the other bytes, stop reading and prep data for LCD
	
	
	//Acquire Integer
	lsbTmpy = tmpyLSB >> 4; 
	msbTmpy = tmpyMSB << 4;
	intPart = msbTmpy | lsbTmpy;
	
	//Acquire Fraction
	if(tmpyLSB & 0x01){fFracPart += 0.0625;}
	if(tmpyLSB & 0x02){fFracPart += 0.125;}
	if(tmpyLSB & 0x04){fFracPart += 0.25;}
	if(tmpyLSB & 0x08){fFracPart += 0.5;}
	iFracPart =fFracPart*1000;

	//Sign check
	sign = ((tmpyMSB >> 3 )& 0x3F);
	if(sign == 0){
		sprintf(tempResult,"Temp: +%d.%03d%cC",intPart,iFracPart,degree);
		
		intPart = 0;
		iFracPart= 0;
		fFracPart =0.0;
	}
	else{
		sprintf(tempResult,"Temp: -%d.%03d%cC",intPart,iFracPart,degree);
		intPart = 0;
		iFracPart= 0;
		fFracPart =0.0;
	}
}
//----------------------------------------------------------------------------------------
void main() {
    char keyPress;
    char typedKey[17];
    memset(typedKey, ' ', 16);
    typedKey[16] = '\0';
    
    initPorts();
    initLCD();
    /*initUSART();*/
    
    while (1) {
        keyPress = getKeyPress();
        if (keyPress != 0xFF){
            switch(keyPress){
                case 'A':
                   mainSystem(keyPress);
                   break; 
                    
                case 'B':
                    if(STORE.BPM == 1)
                    {
                        STORE.BPM = 0;
                    }
                    else
                    {
                        STORE.BPM = 1;
                    }
                    break;
                   
                 case 'C':
                    if(STORE.HRV == 1)
                    {
                        STORE.HRV = 0;
                    }
                    else
                    {
                        STORE.HRV = 1;
                    }
                   
                   
                   break;
                   
                case 'D':
                    if(STORE.TEMP == 1)
                    {
                        STORE.TEMP = 0;
                    }
                    else
                    {
                        STORE.TEMP = 1;
                    }
                   
                   
                   break;
                
            }
        }else{
            WriteCmdXLCD(CLR_DISP);
            prtStrLitLCD(1,"Group Project");
            prtStrLitLCD(2,"Mutex-7");
            prtStrLitLCD(3,"To Start");
            prtStrLitLCD(4,"Press A");
        }
    }
    Sleep();
}