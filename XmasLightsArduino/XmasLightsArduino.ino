//Sensors and their value
int sleep=0;
int pattern=1;
void setup() {
  Serial.begin(4800);
}

void loop() {  
  Serial.println("Sleep"+analogRead(sleep));
  Serial.println("Pattern"+analogRead(pattern));
}
