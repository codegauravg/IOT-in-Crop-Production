#include <SPI.h> // needed in Arduino 0019 or later
#include <Ethernet.h>
#include <Twitter.h>
#include "DHT.h"
//DHT22 humidity and temperature sensor liberaries and initialisation definations. 
#define DHTPIN 8     // what pin we're connected to
#define DHTTYPE DHT22   // DHT 22  (AM2302)
#define fan 13

DHT dht(DHTPIN, DHTTYPE);

//trigger event static variables
int maxHum = 75;
int maxTemp = 45;
int trig_h = 10;
int trig_t = 2;
int msg_count = 5;
//static utility variables
long picker;
float prev_h=100.0,prev_t=100.0;


  //sentences set for temp increase
char incTmsg[][50]={
  "we going to be hot.",
  "be carefull of getting skin burn.",
  "tumhe garmi lagegi.",
  "you will need a hanky as you are going to sweat.",
  "its hot outside!"};
//sentences set for temp decrease
char decTmsg[][50]={
  "Finally it's getting cold.",
  "Man, it's freezing out here.",
  "I can't feel my leaves in this cold",
  "Abe AC kisne on ki!",
  "I can feel the freezing soil at my roots.",};
//sentences set for hum increase
char incHmsg[][50]={
  "It's too sweaty.",
  "Man, it's getting humid.",
  "Humidity MODE ON!",
  "I don't like being sweaty.",
  "it's to moisture outside."};
//sentences set for hum decrease
char decHmsg[][50]={
  "Finally, Humidity is gone.",
  "Humidity MODE OFF",
  "It's a good breeze outside.",
  "I miss being all sweaty.",
  "thank god, it's not humid anymore."};


// The includion of EthernetDNS is not needed in Arduino IDE 1.0 or later.
// Please uncomment below in Arduino IDE 0022 or earlier.
//#include <EthernetDNS.h>


// Ethernet Shield Settings
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED  };

// If you don't specify the IP address, DHCP is used(only in Arduino 1.0 or later).3694679955-1X9YzgVBgsTG1vQA3g6YJksypVDtXkgDbTIo20J //3694679955-4IT3HibxylI75f1JufKxSRJFzsy98YnM5CfKoQh
byte ip[] = { 172, 16, 200, 124 };
byte gateway[] = { 172, 16, 200, 1 }; //Manual setup only
byte subnet[] = { 255, 255, 255, 0 };//Manual setup only
byte mydns[] = { 172, 16, 100, 2 };

// Your Token to Tweet (get it from http://arduino-tweet.appspot.com/)
Twitter twitter("3694679955-4IT3HibxylI75f1JufKxSRJFzsy98YnM5CfKoQh");




void setup()
{ //physical pinMode configuration for directly stacking the sensor on the board.
  pinMode(9,OUTPUT);
  pinMode(8,INPUT_PULLUP);
  pinMode(7,OUTPUT);
  digitalWrite(9,HIGH);
  digitalWrite(7,LOW);
  pinMode(fan, OUTPUT);
  Serial.begin(9600); 
  dht.begin();

  
 // or you can use DHCP for autoomatic IP address configuration.
 // Ethernet.begin(mac);
  //Ethernet.begin(mac,ip);
  Ethernet.begin(mac, ip, mydns, gateway);
  Serial.println(Ethernet.localIP());

  
  // if analog input pin 0 is unconnected, random analog
  // noise will cause the call to randomSeed() to generate
  // different seed numbers each time the sketch runs.
  // randomSeed() will then shuffle the random function.
 
  randomSeed(analogRead(0));

}

void loop() // functions to execute repeatively here...
{  // Wait a few seconds between measurements.
  delay(2000);

  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  float h = dht.readHumidity();
  // Read temperature as Celsius
  float t = dht.readTemperature();
  
  // Check if any reads failed and exit early (to try again).
  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  
  
  //logic for triggering the twitter post if the change in humidity or temperature is considerable here...

  float change_h = h - prev_h;
  float change_t = t - prev_t;

  prev_h = h;
  prev_t = t;

  Serial.print("new prev_h value : ");
  Serial.print(prev_h);
  Serial.print("%\t");
  Serial.print("new prev_t value : ");
  Serial.print(prev_t);
  Serial.println();
  
  if(h > maxHum || t > maxTemp) {
      digitalWrite(fan, HIGH);
  } else {
     digitalWrite(fan, LOW); 
  }
  Serial.print("Humidity: "); 
  Serial.print(h);
  Serial.print(" %\t");
  Serial.print("Temperature: "); 
  Serial.print(t);
  Serial.println(" *C ");

  Serial.print("Changed Humidity: "); 
  Serial.print(change_h);
  Serial.print(" %\t");
  Serial.print("Changed Temperature: "); 
  Serial.print(change_t);
  Serial.println(" *C ");

      if(change_t >= (trig_t)){
    // statement for considerable increase in Temperature.
    picker = random(msg_count);
    doitbro(incTmsg[picker]);
    }  
    else if(change_t < -(trig_t)){
    // statement for considerable decrease in Temperature.
    picker = random(msg_count);
    Serial.print(" Picker value : ");
    Serial.print(picker);
    Serial.println();
    doitbro(decTmsg[picker]);
    }
     else if(change_h >= (trig_h)){
    // statement for considerable increase in humidity.
    picker = random(msg_count);
    
    doitbro(incHmsg[picker]);
    }  
    else if(change_h < -(trig_h)){
   // statement for considerable decrease in humidity.
    picker = random(msg_count);
    
    doitbro(decHmsg[picker]);
    }  
  
    else {}

    // Wait an 2hour between measurements.
    delay(1000*60*24*2);
    //delay(1000*5);

    
}

void doitbro(char msg[]){
 delay(1000*5);
        // Twitter message posting implementation code here... 
      Serial.println("connecting ...");
      if (twitter.post(msg)) {
        // Specify &Serial to output received response to Serial.
        // If no output is required, you can just omit the argument, e.g.
        // int status = twitter.wait();
        int status = twitter.wait(&Serial);
        if (status == 200) {
          Serial.println("OK.");
        }
        else {
          Serial.print("failed : code ");
          Serial.println(status);
        }
        
      }
      else {
        Serial.println("connection failed.");
       doitbro(msg);
      }
  }
