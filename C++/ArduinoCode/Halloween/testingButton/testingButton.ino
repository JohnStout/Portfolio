// get servo online
#include <Servo.h>
Servo myservo;  // create servo object to control a servo
int pos = 0;  

// define time lag for LED flickering red
int redFlicker = 100; // 100ms

void setup() {
  // format pin D10 for use
  pinMode(10, OUTPUT);
  pinMode(6, OUTPUT); // LED
  pinMode(9, OUTPUT);
  
  // initialize servo
  myservo.attach(2);
}

void loop() {

  digitalWrite(6, HIGH);
  // start wiggling hand
    for (pos = 0; pos <= 90; pos += 1) { // goes from 0 degrees to 180 degrees
    // in steps of 1 degree
    myservo.write(pos);              // tell servo to go to position in variable 'pos'    
    delay(10);                       // waits 15 ms for the servo to reach the position
    }
    

  //digitalWrite(10, HIGH);
  //delay(2);
  digitalWrite(9, HIGH);
  
  digitalWrite(6, LOW);
  for (pos = 90; pos >= 0; pos -= 1) { // goes from 180 degrees to 0 degrees
    myservo.write(pos);              // tell servo to go to position in variable 'pos'
    delay(10);                       // waits 15 ms for the servo to reach the position
    }  
  
}
