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

// PIR motion sensor
int calibrationTime = 30; //the time we give the sensor to calibrate (10-60 secs according to the datasheet)
int pirPin = 7;
int state = LOW;             // by default, no motion detected
int val = 0;                 // variable to store the sensor status (value)

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(ledRed, OUTPUT);
  pinMode(ledWhite, OUTPUT); // LED
  pinMode(scaryGirl, OUTPUT);
  pinMode(scaryDog, OUTPUT);

  // set up ultrasonic sensor
  Serial.print("calibrating sensor ");
  //delay(1000*calibrationTime);
  pinMode(pirPin, INPUT);
  Serial.begin(9600);
  delay(15000);
}

// the loop function runs over and over again forever
void loop() {
  val = digitalRead(pirPin);   // read sensor value
  if (val == HIGH) {           // check if the sensor is HIGH
    digitalWrite(ledRed, HIGH);   // turn LED ON
    digitalWrite(ledWhite, LOW);
    delay(500);                // delay 100 milliseconds 
    
    if (state == LOW) {
      Serial.println("Motion detected!"); 
      state = HIGH;       // update variable state to HIGH
    }
    
    // trigger scary dog
    Serial.print("Scary dog");
    digitalWrite(scaryDog, HIGH);
    digitalWrite(scaryDog, LOW);
    delay(5000);

    // trigger scary girl 
    Serial.print("Scary girl");
    digitalWrite(scaryGirl, HIGH);
    digitalWrite(scaryGirl, LOW);

    // begin light flickering
    
    
  } 
  else {
      digitalWrite(ledRed, LOW); // turn LED OFF
      digitalWrite(ledWhite, HIGH);
      delay(500);             // delay 200 milliseconds 
      
      if (state == HIGH){
        Serial.println("Motion stopped!");
        state = LOW;       // update variable state to LOW
    }

    //i = i+1;


    uint32_t period = .25 * 60000L;       // 5 minutes
    
    for( uint32_t tStart = millis();  (millis()-tStart) < period;  ){            
      randNumber = random(minNum, maxNum);
      digitalWrite(ledWhite, HIGH);   // turn the LED on (HIGH is the voltage level)
      delay(randNumber);                       // wait for a second
      randNumber = random(minNum, maxNum) ;
      digitalWrite(ledWhite, LOW);    // turn the LED off by making the voltage LOW
      delay(randNumber);   
    }
  }  

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
