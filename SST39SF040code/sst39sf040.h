/* 
 * File:   sst39sf040.h
 * Author: Luther
 *
 * Created on November 27, 2017, 10:42 AM
 */

#ifndef SST39SF040_H
#define	SST39SF040_H

#ifdef	__cplusplus
extern "C" {
#endif





#ifdef	__cplusplus
}
#endif

#endif	/* SST39SF040_H */

volatile struct sav {
    unsigned TEMP : 1;
    unsigned HRV : 1;
    unsigned BPM : 1;
   /* unsigned GLU : 1;*/
}; // data structire for save/recall status

char address = {, , , 
				, , ,
				, , ,
				, , ,
				, , ,
				, ,
}// character array of flash ram adress frames


void initUSART(void);
void addressMode(void);
void writeMode(void);
void readMode(void);
void writeAddress(char , char, char);
void writeData(char, char, char, char);
void readData(char, char, char);
void eraseSector(char, char, char);
void storeValues(char *, struct sav, char );
void storeTemp(char *, struct sav, float *);
float recallTemp(char *, struct sav);
void storeHRV(char *, struct sav, int *);
int recallHRV(char *, struct sav );
void storeBPM(char * , struct sav int *);
int recallHRV(char *, struct sav );
int readBPM(char *);
int readHRV(char *);
float readTemp(char *);


