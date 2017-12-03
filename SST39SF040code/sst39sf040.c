#include <p18cxxx.h>
#include <usart.h>
#include <delays.h>

#include "sst39sf040.h"
#define S1 PORTBbits.RB5
#define S0 PORTBbits.RB4


void initUSART()
{
	OpenUSART(USART_RX_INT_ON & USART_EIGHT_BIT & USART_ASYNCH_MODE & USART_BRGH_HIGH
			& USART_SINGLE_RX, 25); //9600 baud
}

void addressMode(void)
{
	S1 = 0;
	S0 = 0;
}
void writeMode(void)
{
	S1 = 0;
	S0 = 1;
}
void readMode(void)
{
	S1 = 1;
	S0 = 0;
}


void writeAddress(char ad2, char ad1, char ad0)
{
	addressMode();
	putcUSART(ad0);
	while (BusyUSART());
	putcUSART(ad1);
	while (BusyUSART());
	putcUSART(ad2);
	while (BusyUSART());
}


void writeData ( char ad2, char ad1, char ad0, char data)
{
	writeAddress(0x00 , 0x55, 0x55);
	writeMode();
	putcUSART(0xAA);
	while (BusyUSART());
	writeAddress(0x00 , 0x2A, 0xAA);
	writeMode();
	putcUSART(0x55);
	while (BusyUSART());
	writeAddress(0x00 , 0x55, 0x55);
	writeMode();
	putcUSART(0xA0);
	while (BusyUSART());
	writeAddress(ad2 , ad1, ad0);
	writeMode();
	putcUSART(data);
	while (BusyUSART());	
}

void readData(char ad2, char ad1, char ad0) // OR we can make a void function ere instead and th ISR will dealwith the har
{
	
	writeAddress(ad2, ad1, ad0);
	readMode();
	putcUSART(0x00);// drive module to read state
	//insert delay here
	//return readUSART();// we can read on interrupt
}

void eraseSector(char sct2, char sct1, char sct0)
{
	writeAddress(0x00 , 0x55, 0x55);
	writeMode();
	putcUSART(0xAA);
	while (BusyUSART());
	writeAddress(0x00 , 0x2A, 0xAA);
	writeMode();
	putcUSART(0x55);
	while (BusyUSART());
	writeAddress(0x00 , 0x55, 0x55);
	writeMode();
	putcUSART(0x80);
	while (BusyUSART());
	writeAddress(0x00 , 0x55, 0x55);
	writeMode();
	putcUSART(0xAA);
	while (BusyUSART());
	writeAddress(0x00 , 0x2A, 0xAA);
	writeMode();
	putcUSART(0x55);
	while (BusyUSART());
	writeAddress(sct2 , sct1, sct0);
	writeMode();
	putcUSART(0x30);
	// 100ms delay here
	while (BusyUSART());
}

void storeTemp(char * address, struct sav flags, float* data)
{

    if(flags.TEMP = 1)
    {
        eraseSector(address[0],address[1],address[2]);
        writeTemp(data);// function to write foating point number
    }
}

float recallTemp(char * address, struct sav flags)
{
	float temp;
    if(flags.TEMP = 1)
    {
       temp = readTemp(address);// fucntion to read floating piont umber
       return temp;
    }
}

void storeHRV(char * address, struct sav flags, int * data)
{

    if(flags.HRV = 1)
    {
        eraseSector(address[0],address[1],address[2]);
        writeHRV(data);// function to write foating point number
    }
}

int recallHRV(char * address, struct sav flags)
{
	int HRV;
    if(flags.HRV = 1)
    {
       HRV = readTemp(address);// fucntion to read floating piont umber
       return HRV;
    }
}

void storeBPM(char * address, struct sav flags, int * data)
{

    if(flags.BPM = 1)
    {
        eraseSector(address[0],address[1],address[2]);
        writeBPM(data);// function to write foating point number
    }
}

float recallTemp(char * address, struct sav flags)
{
	float BPM;
    if(flags.BPM = 1)
    {
       BPM = readBPM(address);// fucntion to read integer // address is chacter array of address frames
       return BPM;
    }
}