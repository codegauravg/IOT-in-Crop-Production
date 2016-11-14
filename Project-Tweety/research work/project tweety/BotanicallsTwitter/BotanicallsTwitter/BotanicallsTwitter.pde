// Botanicalls allews plants to ask for human help.
// Rob Faludi  http://www.faludi.com with additional code from various public examples
// and from LadyAda's Twitter and Software Serial examples
// http://www.botanicalls.com
// Botanicalls is a project with Kati London, Rob Faludi, Kate Hartman and Rebecca Bray

#define VERSION "2.03" // this version uses an XPort Shield directly


///// BOTANICALLS DEFINTIONS ////////
#define USERNAMEPASS "username:password"  // your twitter username and password, seperated by a :

#define MOIST 450 // minimum level of satisfactory moisture
#define DRY 350  // maximum level of tolerable dryness
#define SOAKED 600 // minimum desired level after watering
#define WATERING_CRITERIA 100 // minimum change in value that indicates watering

#define MOIST_SAMPLE_INTERVAL 30 // seconds over which to average moisture samples
#define WATERED_INTERVAL 60 // seconds between checks for watering events

#define TWITTER_INTERVAL 1// minimum seconds between twitter postings

#define MOIST_SAMPLES 10 //number of moisture samples to average

int moistValues[MOIST_SAMPLES];

#define LEDPIN 13 // generic status LED
#define MOISTPIN 0 // moisture input is on analog pin 0
#define MOISTLED 9  // LED that indicates the plant needs water

unsigned long lastMoistTime=0; // storage for millis of the most recent moisture reading
unsigned long lastWaterTime=0; // storage for millis of the most recent watering reading
unsigned long lastTwitterTime=0; // storage for millis of the most recent Twitter message

int lastMoistAvg=0;
int lastWaterVal=0;

///// TWITTER DEFINITIONS ///////
#include <AFSoftSerial.h>
#include <avr/io.h>
#include <string.h>
#include <avr/pgmspace.h>

// defines for putstring function that saves RAM memory
#define putstring(x) ROM_putstring(PSTR(x), 0)
#define putstring_nl(x) ROM_putstring(PSTR(x), 1)
#define putstringSS(x) ROM_putstringSS(PSTR(x), 0)
#define putstringSS_nl(x) ROM_putstringSS(PSTR(x), 1)

#define IPADDR "128.121.146.100"  // twitter.com
#define PORT 80                   // HTTP
#define HTTPPATH "/statuses/update.xml"      // the person we want to follow

#define TWEETLEN 141
char linebuffer[256]; // oi
int lines = 0;

#define XPORT_RXPIN 3 // pin definitions for connection to XPort Sheild
#define XPORT_TXPIN 2 
#define XPORT_RESETPIN 4
#define XPORT_DTRPIN 5
#define XPORT_CTSPIN 6
#define XPORT_RTSPIN 7

#define ERROR_NONE 0 // defines numbers for error messages

#define ERROR_TIMEDOUT 2
#define ERROR_BADRESP 3
#define ERROR_DISCONN 4
uint8_t errno;

AFSoftSerial mySerial =  AFSoftSerial(XPORT_RXPIN, XPORT_TXPIN); // start up Lady Ada version of software serial

uint32_t laststatus = 0, currstatus = 0;


void setup()  { 

  uint8_t ret;

  pinMode(LEDPIN, OUTPUT);
  pinMode(MOISTLED, OUTPUT);

  for(int i = 0; i < MOIST_SAMPLES; i++) { // initialize moisture value array
    moistValues[i] = 0; 
  }

  Serial.begin(9600);   // set the data rate for the hardware serial port
  mySerial.begin(9600);   // set the data rate for the software serail port
  Serial.println("");   // begin printing to debug output
  Serial.println("Botanicalls starting...");

  // xport
  pinMode(XPORT_RESETPIN, OUTPUT); // set input and output properly for XPort shield
  if (XPORT_DTRPIN) {
    pinMode(XPORT_DTRPIN, INPUT);
  }
  if (XPORT_CTSPIN) {
    pinMode(XPORT_CTSPIN, OUTPUT);
  }
  if (XPORT_RTSPIN) {
    pinMode(XPORT_RTSPIN, INPUT);
  }

 // uint8_t response = posttweet("Botanicalls!");  // send a startup message to Twitter
 // notify(response);
}


void loop()       // main loop of the program     
{

  moistureCheck(); // check to see if moisture levels require Twittering out
  wateringCheck(); // check to see if a watering event has occured to report it

}



