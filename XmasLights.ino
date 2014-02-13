//Outputs and their state
int relay1=2;
boolean relay1TF=false;
int relay2=3;
boolean relay2TF=false;
//Sensors and their value
int sleep=0;
int sleepValue=0;
long sleepTime=0;
long timeSleepStart;
boolean sleepActive=false;
int mode=1;
int modeValue=0;
//Groups of outputs and their states and sensors and their values
int outputs[]={relay1,relay2};
boolean outputsTF[]={relay1TF,relay2TF};
int sensors[]={};
int sensorsValue[]={};
void setup() {
  for(int i=2;i<=11;i++){
    pinMode(i,OUTPUT);
  } 

}

void loop() {
      if(sleepActive==true){
        if(millis()-timeSleepStart>sleepTime){
          sleepActive==false;
          turnOffLights();
        }
      }
      if(sleepActive==false){
        if(analogRead(sleep)==0){
          delay(15000);//waits so they can reset the timer
          potentiometerToTime();
        }
      }
          
  }
}

void potentiometerToTime(){
  sleepValue=analogRead(sleep);
  if(sleepValue<=124)//if the value is close to zero
    sleepHours=0;    // there is no sleep active
    sleepActive=false;
  else{
      sleepActive=true;
      sleepValue-=124;
      sleepTime=sleepValue/100*36000;
      timeSleepStart=getTime();
   }
}
void toggleOutput(int reference){
   if(outputsTF[reference]==false)
    outputsTF[reference]=true;
  else if(outputsTF[reference]==true)
    outputsTF[reference]=false;
  digitalWrite(outputs[reference], outputs[reference]);
}
void turnOffLights(){
  toggleOutput(relay);
}
long getTime(){
  return millis();
}

