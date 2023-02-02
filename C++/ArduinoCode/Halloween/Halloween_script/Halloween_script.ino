// get servo online
#include <Servo.h>
Servo myservo;  // create servo object to control a servo
int pos = 0;  
//int servoPin = 8;

// define time lag for LED flickering red
int redFlicker = 100; // 100ms
int ledRed   = 2;
int ledWhite = 3;

// Scary dog and scary girl
int scaryGirl = 10;
int scaryDog  = 9;

void setup() {
  
  // format pin D10 for use
  pinMode(ledRed, OUTPUT);
  pinMode(ledWhite, OUTPUT); // LED
  pinMode(scaryGirl, OUTPUT);
  pinMode(scaryDog, OUTPUT);
  
  // initialize servo
  //myservo.attach(servoPin);
  
}

void loop() {

  //digitalWrite(ledRed, HIGH);
  digitalWrite(ledWhite,LOW);
  delay(1000);
  //digitalWrite(ledRed,LOW);
  digitalWrite(ledWhite,HIGH);
  delay(1000);

  // counter starts at 2, while its less than nine,
  // counter + 1, until >9, which it ends sequence
  for(counter = 2;counter <= 9;counter++) {
   //statements block will executed 10 times
   
  }

  // eratic flickering


  // if distance > __ do this

  // if distance < -- do this



  

}
