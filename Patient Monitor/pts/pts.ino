#define POTENTIOMETER_PIN_1   36 // ESP32 pin GPIO36 (ADC0) connected to Potentiometer pin
#define POTENTIOMETER_PIN_2   39
#define POTENTIOMETER_PIN_3   34
// #define LED_PIN           21 // ESP32 pin GPIO21 connected to LED's pin
// #define ANALOG_THRESHOLD  1000

void setup()
{
  Serial.begin(9600);
  //pinMode(LED_PIN, OUTPUT); // set ESP32 pin to output mode
}

void loop()
{
  //digitalWrite(LED_PIN, HIGH);
  //int analogValue = analogRead(POTENTIOMETER_PIN); // read the input on analog pin
  //Serial.print(analogValue);
  int pt_1 = analogRead(POTENTIOMETER_PIN_1);
  int pt_2 = analogRead(POTENTIOMETER_PIN_2);
  int pt_3 = analogRead(POTENTIOMETER_PIN_3);
  int pt_1_value = pt_1 / 25.5;
  int pt_2_value = pt_2 / 41;
  int pt_3_value = pt_3 / 102;
  //int brightness = potentiometerValue / 25.5;
  Serial.print("Heart Rate: ");
  Serial.println(pt_1_value);
  delay(300);
  Serial.print("Oxygen: ");
  Serial.println(pt_2_value);
  delay(300);
  Serial.print("Temperature: ");
  Serial.println(pt_3_value);
  delay(300);
  //analogWrite(LED_PIN, brightness);

  // if (analogValue > ANALOG_THRESHOLD)
  //   digitalWrite(LED_PIN, HIGH); // turn on LED
  // else
  //   digitalWrite(LED_PIN, LOW);  // turn off LED
}

