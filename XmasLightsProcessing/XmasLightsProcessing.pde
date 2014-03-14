import controlP5.*;
import processing.serial.*;
import cc.arduino.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
Serial serial;
Arduino arduino;
Minim minim;
AudioInput in;
FFT fft;
ControlP5 cp5;
Textfield sleep;
//Arduino Variables
int relay1=2;
boolean relay1TF=false;
int relay2=3;
boolean relay2TF=false;
int outputs[]={relay1,relay2};
boolean outputsTF[]={relay1TF,relay2TF};
boolean audioActive=false;
boolean sleepActive=false;
//Audio Variables
float valScale = 1.0;
float maxVisible = 10.0;
float beatThreshold = 0.25;
float colorOffset = 30;
float autoColorOffset = 0.01;
float[] lastVal;
int buffer_size=1024;
float sample_rate=44100;
//Display Variables
int lastWidth=1000;
int lastHeight=600;
boolean fullscreen = false;
//Misc Variables
int counter=0;
int leftBorder()   {
  return int(.05 * width); 
}
int rightBorder()  {
  return int(.05 * width);
  }
int bottomBorder() {
  return int(.05 * width); 
}
int topBorder()    {
  return int(.05 * width); 
}
void setup() {
  size(1000,600);//creates a window size 1000x600
  PFont font = createFont("arial",20);
  cp5=new ControlP5(this);//sets a new controller for the gui
  cp5.addTextfield("Hours")
     .setPosition(200,100)
     .setSize(200,40)
     .setFont(font)
     .setFocus(true)
     .setText("00:");
     ;
     cp5.addTextfield("Minutes")
     .setPosition(200,100)
     .setSize(200,40)
     .setFont(font)
     .setFocus(true)
     .setText("00:");
     ;
     cp5.addTextfield("Seconds")
     .setPosition(200,100)
     .setSize(200,40)
     .setFont(font)
     .setFocus(true)
     .setText("00");
     ;
  frame.setResizable(true);//allows the size to be changed
   background(255,250,255);//sets background to white
   minim=new Minim(this);//creates a new audio objecy
   in = minim.getLineIn(Minim.MONO,buffer_size,sample_rate);//creates an audio input
   fft = new FFT(in.bufferSize(), in.sampleRate());//creates a frequency analyzer
   fft.logAverages(16, 2);//create a smallest average frequency of 8
   fft.window(FFT.HAMMING);
   lastVal = new float[fft.avgSize()];
  //Intializing Arduino
   //arduino = new Arduino(this, Arduino.list()[0], 57600); //creates a new arduino object so it can communicate with the physical arduino
   //serial=new Serial(this, Serial.list()[0],4800);//creats a serial object so it can read data to the serial
  //for (int i = 0; i <= 13; i++)
    //arduino.pinMode(i, Arduino.OUTPUT);
    
}

void draw() {
  
    // Detect resizes
    if(width != lastWidth || height != lastHeight)
    {
      lastWidth = width;
      lastHeight = height;
      background(0);
      initLasts();
      println("resized");
    }
    text("Hi",100,100);
  
    fft.forward(in.mix);//Steps forward int the audio
    if(audioActive)
      audioAnalyze();
     
    // Display the frame rate
    fill(16, 16, 16);
    if(!fullscreen)
    {
    frame.setTitle("Christmas Tree Lights");
    }

}
void audioAnalyze(){
  int iCount = fft.avgSize();//Number of Averages being calculated
    float biggestValChange = 0;//Biggest Change from pervious 
    
    for(int i = 0; i < iCount; i++) {//Loops through all the audio averages
      
      float iPercent = 1.0*i/iCount;//Percentage of Audio Analyzed
      
      float highFreqscale = 1.0 + pow(iPercent, 4) * 2.0;//Gets the Frequncy Range of the current step
      
      float val = sqrt(fft.getAvg(i)) * valScale * highFreqscale / maxVisible;
      float valDiff = val-lastVal[i];
      if(valDiff > beatThreshold && valDiff > biggestValChange)
      {
        biggestValChange = valDiff;
      }
      
      lastVal[i] = val;

    }
    
    // If we've hit a beat, bring the brightness of the bar up to full
    if(biggestValChange > beatThreshold)
    {
      toggleOutput(0);
      toggleOutput(1);
      print("Beat");
      if(counter==1){
      background(51);
      counter=0;
      }
      else{
        counter++;
        background(1000);
      }
    }
}
void initLasts(){
  for(int i = 0; i < fft.avgSize(); i++) {
    lastVal[i] = 0;
  }
  
}
void stop(){//properly closes the program 
  in.close();
  minim.stop();
  super.stop();
}
void toggleOutput(int reference){ //toggles an output at a specfic spot in the outputs array
   if(outputsTF[reference]==false)
    outputsTF[reference]=true;
  else if(outputsTF[reference]==true)
    outputsTF[reference]=false;
    arduino.digitalWrite(outputs[reference], outputs[reference]);
}

/*
Sensors and their value
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
*/

