#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>

#define WIFI_SSID "STUDBME2"
#define WIFI_PASSWORD "BME2Stud"
#define API_KEY "AIzaSyD3zTa3r_nKHegRafG4mAdmC-XRHkX3sQg"
#define DATABASE_URL "https://esp32thirdtrial-default-rtdb.europe-west1.firebasedatabase.app/"

#define POTENTIOMETER_PIN_1 36
#define POTENTIOMETER_PIN_2 39
#define POTENTIOMETER_PIN_3 34

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
bool signupOK = false;

// Declaration of tokenStatusCallback
void tokenStatusCallback(token_info_t info);

void setup()
{
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  if (Firebase.signUp(&config, &auth, "", ""))
  {
    Serial.println("Authentication successful");
    signupOK = true;
  }
  else
  {
    Serial.printf("Authentication failed: %s\n", config.signer.signupError.message.c_str());
  }

  config.token_status_callback = tokenStatusCallback;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop()
{
  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0))
  {
    sendDataPrevMillis = millis();

    int pt_1 = analogRead(POTENTIOMETER_PIN_1);
    int pt_2 = analogRead(POTENTIOMETER_PIN_2);
    int pt_3 = analogRead(POTENTIOMETER_PIN_3);

    float pt_1_value = pt_1 / 25.5;
    float pt_2_value = pt_2 / 41.0;
    float pt_3_value = pt_3 / 102.0;

    if (Firebase.RTDB.setFloat(&fbdo, "potentiometers/pot_1", pt_1_value) &&
        Firebase.RTDB.setFloat(&fbdo, "potentiometers/pot_2", pt_2_value) &&
        Firebase.RTDB.setFloat(&fbdo, "potentiometers/pot_3", pt_3_value))
    {
      Serial.println("Data sent to Firebase successfully");
      Serial.println("Path: " + fbdo.dataPath());
      Serial.println("Data type: " + fbdo.dataType());
    }
    else
    {
      Serial.println("Failed to send data to Firebase");
      Serial.println("Reason: " + fbdo.errorReason());
    }
  }
}

// Implementation of tokenStatusCallback
void tokenStatusCallback(token_info_t info)
{
  int status = info.status;

  Serial.print("Token generation status: ");
  switch (status)
  {
  case 0:
    Serial.println("Token generation success");
    break;
  case -1:
    Serial.println("Token generation failed: Generic error");
    break;
  case -2:
    Serial.println("Token generation failed: Authentication error");
    break;
  case -3:
    Serial.println("Token generation failed: Network error");
    break;
  case -4:
    Serial.println("Token generation failed: Timeout");
    break;
  default:
    Serial.println("Unknown status");
    break;
  }

  if (status == 0)
  {
    // Print or use other relevant information from the info structure
    // For example, you can use info.token_type and info.expires to get additional information
    // Serial.println("Generated Token Type: " + String(info.token_type));
    // Serial.println("Token Expires: " + String(info.expires));
  }
  else
  {
    // Handle errors or retry logic here
  }
}
