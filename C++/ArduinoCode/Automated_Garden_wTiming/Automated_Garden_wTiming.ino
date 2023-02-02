/* Automate watering the garden
 *  This code was adapted from two sources
 *  For the solenoid valve: https://www.youtube.com/watch?v=ioSYlxHlYdI
 *  For the moisture sensor: https://www.youtube.com/watch?v=9h3JKwUsn2A
 *  
 *  This code interfaces with arduino hardware and a relay module that has optocouplers
*/

// define moisture recording values
const int baselineAir1 = 610; // defined by placing capacitative device in air
const int baselineH201 = 339; // defined by placing in water
const int baselineAir2 = 608; // defined by placing capacitative device in air
const int baselineH202 = 289; // defined by placing in water

// define integers for recording devices
int MoistureValue1   = 0; // used for mapping
int MoisturePercent1 = 0;
int MoistureValue2   = 0;
int MoisturePercent2 = 0;

// define startTime variable
int startTime   = 0;
int currentTime = 0;
int detectTime  = 0;
int timeDiff1   = 0; // for tracking time difference
int timeDiff2   = 0; // for tracking time difference
int timeWater   = 0;
int timeDetec   = 0;
int varStart    = 0; // for tracking whether this was the first time the arduino turned on

// define sine constants for timing the automation
const int timeElapse = 1;                  // in hours
const int timeWait   = 60*(60*timeElapse); // 60 sec/1min * ((60min / 1hour) * Nhour) = M seconds

// define how long to water guarden
const int waterTime = 15; // number of seconds

// define relay values
const int RELAY_ENABLE = 2;

void setup() {
  // put your setup code here, to run once:
  pinMode(RELAY_ENABLE, OUTPUT);

  // baudrate
  Serial.begin(9600);

  // variable start - this means the machine turned on for the first time
  varStart = 0;
}

void loop() {

  // read moisture estimates
  MoistureValue1 = analogRead(A0);
  MoistureValue2 = analogRead(A2);

  Serial.print(MoistureValue1);
  Serial.println(" moisture value 1");
  Serial.print(MoistureValue2);
  Serial.println(" moisture value 2");

  // get percentage
  MoisturePercent1 = map(MoistureValue1, baselineAir1, baselineH201, 0, 100);
  MoisturePercent2 = map(MoistureValue2, baselineAir2, baselineH202, 0, 100);

  // print  
  Serial.print(MoisturePercent1);
  Serial.println("% Moisture1 ");
  Serial.print(MoisturePercent2);
  Serial.println("% Moisture2 ");

  // print data to screen

  // get current timestamp
  unsigned long currentTime = millis();
  currentTime = currentTime/1000; // convert to seconds
  
  // time difference - use this to determine if solenoid opens
  timeDiff1 = currentTime-startTime;  // for detection of watering
  timeDiff2 = currentTime-detectTime; // for general detection

  // print out timestamps in minutes
  timeWater  = timeDiff1/60; 
  timeDetec  = timeDiff2/60;
  Serial.print(timeWater);
  Serial.println(" minutes since last watering ");
  Serial.print(timeDetec);
  Serial.println(" minutes since last moisture reading ");

  // turn on if moisture criteria is met for both devices, and if you are beyond the waiting limit OR if the time difference is 0 (a restart of arduino)
  if (((MoisturePercent1 < 40) || (MoisturePercent2 < 40)) && ((timeDiff1 > timeWait) || (varStart == 0)))
    {
      // put your main code here, to run repeatedly:
      Serial.println("Water Garden; RELAY ON"); 
      digitalWrite(RELAY_ENABLE, LOW); // relay is active low, so it turns on when we set the pin to low

      // create a timestamp
      unsigned long startTime  = millis(); 
      unsigned long detectTime = millis();
      startTime  = startTime/1000;  // convert to seconds
 
      // water the guarden for about 15 seconds
      delay(waterTime*1000);
      digitalWrite(RELAY_ENABLE, HIGH); // close 
    }
  else if (((MoisturePercent1 > 40) || (MoisturePercent2 > 40)) && ((timeDiff1 > timeWait) || (varStart == 0)))
    {
      // print
      Serial.println("Turn off hose; RELAY OFF");
      digitalWrite(RELAY_ENABLE, HIGH); 
      delay(1000);
      
      // time from detection
      unsigned long detectTime = millis();
      detectTime = detectTime/1000; // sec
    }
  // delay
  delay(200);

  // set variable to 1 - this tracks whether it was the first time the machine turned on
  varStart = 1;
}
