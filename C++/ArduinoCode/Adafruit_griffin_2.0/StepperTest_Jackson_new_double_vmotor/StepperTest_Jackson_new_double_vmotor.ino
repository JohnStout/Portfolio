/* 
This is a test sketch for the Adafruit assembled Motor Shield for Arduino v2
It won't work with v1.x motor shields! Only for the v2's with built in PWM
control

For use with the Adafruit Motor Shield v2 
---->	http://www.adafruit.com/products/1438
*/


#include <Wire.h>
#include <Adafruit_MotorShield.h>

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS1 = Adafruit_MotorShield(0x61); 
Adafruit_MotorShield AFMS2 = Adafruit_MotorShield(0x61);

// Or, create it with a different I2C address (say for stacking)
// Adafruit_MotorShield AFMS = Adafruit_MotorShield(0x61); 

// Connect a stepper motor with 500 steps per revolution (1.8 degree)
// to motor port #2 (M3 and M4)
Adafruit_StepperMotor *myMotor1 = AFMS1.getStepper(500, 1);
Adafruit_StepperMotor *myMotor2 = AFMS2.getStepper(500, 2);


void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Stepper test!");

  AFMS1.begin();  // create with the default frequency 1.6KHz
  //AFMS1.begin(1000);  // OR with a different frequency, say 1KHz
   AFMS2.begin();  // create with the default frequency 1.6KHz
  //AFMS2.begin(1000);  // OR with a different frequency, say 1KHz
  
  myMotor1->setSpeed(100);  // 10 rpm 
  myMotor2->setSpeed(100);  // 10 rpm   
}

void loop() {
  Serial.println("single coil steps");
  myMotor1->step(100,BACKWARD,SINGLE);
  delay(2);
  Serial.println("single coil steps");
  myMotor2->step(100,BACKWARD,SINGLE);
  delay(2);
  /*
  myMotor->step(500,FORWARD,SINGLE);
  delay(2);
  Serial.println("Single coil steps");
  myMotor->step(100, FORWARD, SINGLE); 
  myMotor->step(100, BACKWARD, SINGLE); 

  Serial.println("Double coil steps");
  myMotor->step(100, FORWARD, DOUBLE); 
  myMotor->step(100, BACKWARD, DOUBLE);
  
  Serial.println("Interleave coil steps");
  myMotor->step(100, FORWARD, INTERLEAVE); 
  myMotor->step(100, BACKWARD, INTERLEAVE); 
*/
  /*
  Serial.println("Microstep steps");
  myMotor->step(50, FORWARD, MICROSTEP); 
  myMotor->step(50, BACKWARD, MICROSTEP);
  */
}
