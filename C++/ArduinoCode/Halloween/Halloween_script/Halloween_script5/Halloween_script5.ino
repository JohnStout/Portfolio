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
int scaryGirlOn = 0;

// PIR motion sensor
int calibrationTime = 10; //the time we give the sensor to calibrate (10-60 secs according to the datasheet)
int pirPin = 7;
int state = LOW;             // by default, no motion detected
int val = 0;                 // variable to store the sensor status (value)

// get servo
#include <Servo.h>
Servo myservo;  // create servo object to control a servo
int pos = 0;  
int servoHand = 6;

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(ledRed, OUTPUT);
  pinMode(ledWhite, OUTPUT); // LED
  pinMode(scaryGirl, OUTPUT);
  pinMode(scaryDog, OUTPUT);

  // attach servo
  myservo.attach(servoHand);

  // set up ultrasonic sensor
  Serial.begin(9600);
  Serial.print("calibrating sensor ");
  delay(1000*calibrationTime);
  pinMode(pirPin, INPUT);
  //delay(60000); // 1min to configure 
}

// begin with a timer
uint32_t endT = millis(); 

// the loop function runs over and over again forever
void loop() {
  
  // default
  randNumber = random(minNum, maxNum);
  digitalWrite(ledWhite, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(randNumber);                       // wait for a second
  randNumber = random(minNum, maxNum) ;
  digitalWrite(ledWhite, LOW);    // turn the LED off by making the voltage LOW
  delay(randNumber); 
  
  // read sensor
  val = digitalRead(pirPin);
  if ((val == HIGH) &&  ((millis()-endT)/1000 > 1*30)){
    //static uint32_t endT = millis(); 
    
    // run a for loop to flicker lights, but when a certain amount of time passes, exit
    // flicker lights
    Serial.print("triggering scary dog");
    digitalWrite(scaryDog, HIGH);
  
    //digitalWrite(scaryDog, LOW); // reset
    uint32_t tStart = millis();
    while ( ((millis()-tStart)/1000) < 1*30 ) {
      //Serial.println((millis()-tStart) / 1000.0, 3);
      //Serial.println("sec");
      randNumber = random(50, 150);
      digitalWrite(ledRed, HIGH);   // turn the LED on (HIGH is the voltage level)
      delay(randNumber);                       // wait for a second
      randNumber = random(50, 150) ;
      digitalWrite(ledRed, LOW);    // turn the LED off by making the voltage LOW
      delay(randNumber);  

      
      // after 15s, but before 16s, trigger scary girl
      if ( ((millis()-tStart)/1000) > 1*10 ) { 
        Serial.print("Triggering scary girl"); 
        digitalWrite(scaryGirl, HIGH);
        //digitalWrite(scaryDog, LOW); 
        delay(1000);
        digitalWrite(servoHand, HIGH); 
        myservo.write(180);
        // store time
        scaryGirlOn = 1;
        
      }
    }
    // reset
    digitalWrite(scaryDog, LOW);
    digitalWrite(scaryGirl, LOW); 
    digitalWrite(servoHand, LOW); 
    myservo.write(0);
    //uint32_t tStart = 0;

  }
  Serial.println((millis()-endT)/1000);

/*
  uint32_t ttStart = millis();
  while ( ((millis()-ttStart)/1000) < 1*30 ) {  
    // default
    randNumber = random(minNum, maxNum);
    digitalWrite(ledWhite, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(randNumber);                       // wait for a second
    randNumber = random(minNum, maxNum) ;
    digitalWrite(ledWhite, LOW);    // turn the LED off by making the voltage LOW
    delay(randNumber); 
  }
  */
}
