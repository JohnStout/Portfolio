/* Automate watering the garden
 *  This code was adapted from two sources
 *  For the solenoid valve: https://www.youtube.com/watch?v=ioSYlxHlYdI
 *  For the moisture sensor: https://www.youtube.com/watch?v=9h3JKwUsn2A
 *  
 *  This code interfaces with arduino hardware and a relay module that has optocouplers
*/

// define moisture recording values
const int baselineAir = 605; // defined by placing capacitative device in air
const int baselineH20 = 309; // defined by placing in water

int MoistureValue   = 0; // used for mapping
int MoisturePercent = 0;

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
  MoistureValue = analogRead(A0);

  // get percentage
  MoisturePercent = map(MoistureValue, baselineAir, baselineH20, 0, 100);
  //Serial.print(MoisturePercent);
  //Serial.println("% Moisture ");
  Serial.print(MoistureValue);

  if (MoisturePercent < 60)
    {
      // put your main code here, to run repeatedly:
      Serial.println("Water Garden; RELAY ON"); 
      digitalWrite(RELAY_ENABLE, LOW); // relay is active low, so it turns on when we set the pin to low      
    }
  else if (MoisturePercent > 60)
    {
    Serial.println("Turn off hose; RELAY OFF");
    digitalWrite(RELAY_ENABLE, HIGH); 
    }

  delay(200);
}
