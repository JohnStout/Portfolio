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

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(ledRed, OUTPUT);
  pinMode(ledWhite, OUTPUT); // LED
  pinMode(scaryGirl, OUTPUT);
  pinMode(scaryDog, OUTPUT);
}

// the loop function runs over and over again forever
void loop() {
  i = i+1;
  randNumber = random(minNum, maxNum);
  digitalWrite(ledWhite, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(randNumber);                       // wait for a second
  randNumber = random(minNum, maxNum) ;
  digitalWrite(ledWhite, LOW);    // turn the LED off by making the voltage LOW
  delay(randNumber);                       // wait for a second

  if (i > 10) {
    digitalWrite(scaryGirl, HIGH);
    for(int counter = 2;counter <= 20;counter++) {
      randNumber = random(minNum, maxNum) ;
      digitalWrite(ledRed, HIGH);   // turn the LED on (HIGH is the voltage level)
      delay(randNumber);                       // wait for a second
      randNumber = random(minNum, maxNum) ;
      digitalWrite(ledRed, LOW);    // turn the LED off by making the voltage LOW
      delay(randNumber);                       // wait for a second      
    }
    delay(1000);
    i = 0;
  }
  
}
