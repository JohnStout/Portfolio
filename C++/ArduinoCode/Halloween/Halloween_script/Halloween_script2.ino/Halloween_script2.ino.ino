/*
  Blink

  Turns an LED on for one second, then off for one second, repeatedly.

  Most Arduinos have an on-board LED you can control. On the UNO, MEGA and ZERO
  it is attached to digital pin 13, on MKR1000 on pin 6. LED_BUILTIN is set to
  the correct LED pin independent of which board is used.
  If you want to know what pin the on-board LED is connected to on your Arduino
  model, check the Technical Specs of your board at:
  https://www.arduino.cc/en/Main/Products

  modified 8 May 2014
  by Scott Fitzgerald
  modified 2 Sep 2016
  by Arturo Guadalupi
  modified 8 Sep 2016
  by Colby Newman

  This example code is in the public domain.

  https://www.arduino.cc/en/Tutorial/BuiltInExamples/Blink
*/
// LEDs
int ledRed   = 2;
int ledWhite = 3;

// some numbers for looping
int randNumber;
int minNum = 50;
int maxNum = 250;
int i = 0;

// Scary dog and scary girl
int scaryGirl = 10;
int scaryDog  = 9;

// ultrasonic sensor pins
const int trigPin = 6;
const int echoPin = 5;
long duration;
int distance;
#include <NewPing.h>
#define trigPin 6
#define echoPin 5
#define maxDistance 200
NewPing sonar(trigPin, echoPin, maxDistance);

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(ledRed, OUTPUT);
  pinMode(ledWhite, OUTPUT); // LED
  pinMode(scaryGirl, OUTPUT);
  pinMode(scaryDog, OUTPUT);

  // set up ultrasonic sensor
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
}

// the loop function runs over and over again forever
void loop() {
  
  // Clear the trigPin by setting it LOW:
  digitalWrite(trigPin, LOW);
  delayMicroseconds(5);

  // Trigger the sensor by setting the trigPin high for 10 microseconds:
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // Read the echoPin, pulseIn() returns the duration (length of the pulse) in microseconds:
  duration = pulseIn(echoPin, HIGH);
  // Calculate the distance:
  distance = duration * 0.034 / 2;

  // Print the distance on the Serial Monitor (Ctrl+Shift+M):
  Serial.print("Distance = ");
  Serial.print(distance);
  Serial.println(" cm");

  if (distance < 6 ){
    digitalWrite(ledRed, HIGH);
    digitalWrite(ledWhite, LOW);
    //delay(1000);
  }
  else if (distance > 8){
    digitalWrite(ledWhite, HIGH);
    digitalWrite(ledRed, LOW);
    //delay(1000);
  }
  
  delay(50);
  

  // comment out for now
  /*
  randNumber = random(minNum, maxNum);
  digitalWrite(ledWhite, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(randNumber);                       // wait for a second
  randNumber = random(minNum, maxNum) ;
  digitalWrite(ledWhite, LOW);    // turn the LED off by making the voltage LOW
  delay(randNumber);                       // wait for a second

  // measure duration of scaryGirl sequence
  digitalWrite(scaryGirl, HIGH);
  digitalWrite(ledRed, HIGH);
  delay(12000);
  digitalWrite(scaryGirl, LOW);
  digitalWrite(ledRed, LOW);
  */
}
