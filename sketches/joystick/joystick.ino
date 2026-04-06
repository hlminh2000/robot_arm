

void setup()
{
  Serial.begin(9600);
  Serial.print("Setup");
}

void loop()
{
  int VRx = analogRead(0);
  int VRy = analogRead(1);
  int SM = analogRead(2);

  Serial.print("VRx: ");
  Serial.print(VRx);
  Serial.print(", VRy: ");
  Serial.print(VRy);
  Serial.print(", SM: ");
  Serial.println(SM);
}