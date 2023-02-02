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
const int baselineAir2 = 606; // defined by placing capacitative device in air
const int baselineH202 = 289; // defined by placing in water

// define integers for recording devices
int MoistureValue1   = 0; // used for mapping
int MoisturePercent1 = 0;
int MoistureValue2   = 0;
int MoisturePercent2 = 0;

// define relay values
const int RELAY_ENABLE = 2;

void setup() {
  // put your setup code here, to run once:
  pinMode(RELAY_ENABLE, OUTPUT);

  // baudrate
  Serial.begin(9600);
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
  
  
  if ((MoisturePercent1 < 40) || (MoisturePercent2 < 40))
    {
      // put your main code here, to run repeatedly:
      Serial.println("Water Garden; RELAY ON"); 
      digitalWrite(RELAY_ENABLE, LOW); // relay is active low, so it turns on when we set the pin to low      
    }
  else if ((MoisturePercent1 > 40) || (MoisturePercent2 > 40))
    {
    Serial.println("Turn off hose; RELAY OFF");
    digitalWrite(RELAY_ENABLE, HIGH); 
    }

  delay(200);
}
