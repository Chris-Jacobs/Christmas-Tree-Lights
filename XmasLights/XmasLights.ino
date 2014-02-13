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
        if(millis()-timeSleepStart>sleepTime){//if the sleep time is up
          sleepActive==false;//turns off sleep mode
          turnOffLights();//turns off all the lights
        }
      }
      if(sleepActive==false){
        if(analogRead(sleep)==0){//if the pentionter was reset
          delay(15000);//waits so they can reset the timer
          potentiometerToTime(); //after its set the sleep function is called
        }
      }
          
  }
}

void potentiometerToTime(){
  sleepValue=analogRead(sleep);
  if(sleepValue<=124)//if the value is close to zero
    sleepHours=0;    // there is no sleep active
    sleepActive=false;  
  else{              // otherwise
      sleepActive=true;  //sleep feature is on
      sleepValue-=124;    
      sleepTime=sleepValue/100*36000;// changes analog into milliseconds for timer
      timeSleepStart=getTime();  //gets the start time of the sleep timer
   }
}
void toggleOutput(int reference){ //toggles an output at a specfic spot in the outputs array
   if(outputsTF[reference]==false)
    outputsTF[reference]=true;
  else if(outputsTF[reference]==true)
    outputsTF[reference]=false;
  digitalWrite(outputs[reference], outputs[reference]);
}
void turnOffLights(){   //declared for to ease use
  toggleOutput(relay);
}
long getTime(){    //gets the time since the program started
  return millis();
}

