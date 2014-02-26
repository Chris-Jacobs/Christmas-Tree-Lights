/*
arduino_output

Demonstrates the control of digital pins of an Arduino board running the
StandardFirmata firmware.  Clicking the squares toggles the corresponding
digital pin of the Arduino.  

To use:
* Using the Arduino software, upload the StandardFirmata example (located
  in Examples > Firmata > StandardFirmata) to your Arduino board.
* Run this sketch and look at the list of serial ports printed in the
  message area below. Note the index of the port corresponding to your
  Arduino board (the numbering starts at 0).  (Unless your Arduino board
  happens to be at index 0 in the list, the sketch probably won't work.
  Stop it and proceed with the instructions.)
* Modify the "arduino = new Arduino(...)" line below, changing the number
  in Arduino.list()[0] to the number corresponding to the serial port of
  your Arduino board.  Alternatively, you can replace Arduino.list()[0]
  with the name of the serial port, in double quotes, e.g. "COM5" on Windows
  or "/dev/tty.usbmodem621" on Mac.
* Run this sketch and click the squares to toggle the corresponding pin
  HIGH (5 volts) and LOW (0 volts).  (The leftmost square corresponds to pin
  13, as if the Arduino board were held with the logo upright.)
  
For more information, see: http://playground.arduino.cc/Interfacing/Processing
*/

import processing.serial.*;
import cc.arduino.*;
Arduino arduino;

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioInput in;
FFT fft;
float[] lastY;
float[] lastVal;
int buffer_size=1024;
float sample_rate=44100;

int[] values = { Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW,
 Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW,
 Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW, Arduino.LOW };
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
  frame.setResizable(true);//allows the size to be changed
   background(255,250,255);//sets background to white
   minim=new Minim(this);//creates a new audio objecy
   in = minim.getLineIn(Minim.MONO,buffer_size,sample_rate);//creates an audio input
   fft = new FFT(in.bufferSize(), in.sampleRate());//creates a frequency analyzer
   fft.logAverages(16, 2);//
   fft.window(FFT.HAMMING);
   lastY = new float[fft.avgSize()];
   lastVal = new float[fft.avgSize()];
  //println(Arduino.list());
  //Intializing Arduino
   arduino = new Arduino(this, Arduino.list()[0], 57600);     
  for (int i = 0; i <= 13; i++)
    arduino.pinMode(i, Arduino.OUTPUT);
    
}

void draw() {
   
    colorMode(RGB);
  
    // Detect resizes
    if(width != lastWidth || height != lastHeight)
    {
      lastWidth = width;
      lastHeight = height;
      background(0);
      initLasts();
      println("resized");
    }
  
    colorMode(HSB, 100);
  
    fft.forward(in.mix);
    smooth();
    noStroke();
    
    
    int iCount = fft.avgSize();
    float barHeight =  0.03*(height-topBorder()-bottomBorder());
    float barWidth = (width-leftBorder()-rightBorder())/iCount;
    
    float biggestValChange = 0;
    
    for(int i = 0; i < iCount; i++) {
      
      float iPercent = 1.0*i/iCount;
      
      float highFreqscale = 1.0 + pow(iPercent, 4) * 2.0;
      
      float val = sqrt(fft.getAvg(i)) * valScale * highFreqscale / maxVisible;
      float h = 100 - (100.0 * iPercent + colorOffset) % 100;
      float s = 70 - pow(val, 3) * 70;
      float b = 100;
      float valDiff = val-lastVal[i];
      if(valDiff > beatThreshold && valDiff > biggestValChange)
      {
        biggestValChange = valDiff;
        beatH = h;
        beatS = s;
        beatB = b;
      }
      
      lastY[i] = y;
      lastVal[i] = val;

    }
    
    // If we've hit a beat, bring the brightness of the bar up to full
    if(biggestValChange > beatThreshold)
    {
      arduinoBeatB = 100;
    }  
    
    // calculate the arduino beat color
    color c_hsb = color(beatH, 90, constrain(arduinoBeatB, 1, 100));
    
    int r = int(red(c_hsb) / 100 * 255);
    int g = int(green(c_hsb) / 100 * 255);
    int b = int(blue(c_hsb) / 100 * 255);
   
    // clear out the message area
    fill(0);
    rect(0, height - 0.8*bottomBorder(), width, height);
    
    // draw the beat bar
    colorMode(RGB, 255);
    fill(r, g, b);
    rect(leftBorder(), height - 0.8*bottomBorder(), width-rightBorder(), height - .5*bottomBorder());

    // Tell the arduino to draw
    if (arduinoConnected)
    {
      try
      {
        arduino.analogWrite(redPin, r);
        arduino.analogWrite(greenPin, g);
        arduino.analogWrite(bluePin, b);
        fill(16,16,16);
        textAlign(CENTER, BOTTOM);
        text(arduinoMessage, width/2, height);
      }
      catch (Exception e) {
        arduinoConnected = false;
        arduinoMessage = "Lost connection!  Press TAB to reconnect.";
        arduinoIndex--; // Pressing TAB advances, but we want to retry the same index
        println(e);
      }
    }
    // Decay the arduino beat brightness (based on 60 fps)
    arduinoBeatB *= 1.0 - 0.10 * 60/frameRate;
    
    // Automatically advance the color
    colorOffset += autoColorOffset;
    colorOffset %= 100;

    // Show the scale if it was adjusted recently
    if(showscale)
    {
      fill(255,255,255);
      textAlign(RIGHT, TOP);
      text("scale:"+nf(valScale,1,1), width-rightBorder(), topBorder());
      showscale=false;
    }
    
    // Show the beat threshold if it was adjusted recently
    if(showBeatThreshold)
    {
      fill(255,255,255);
      textAlign(RIGHT, TOP);
      text("beat threshold:"+nf(beatThreshold,1,2), width-rightBorder(), topBorder());
      showBeatThreshold=false;
    }
     
    // Show the help
    if(showHelp)
    {
      fill(255,255,255);
      textAlign(RIGHT, TOP);
      text("Help:\nUP/DOWN arrows = Scale Visualizer\n" + 
           "LEFT/RIGHT arrows = Temporarily shift colors\n" + 
           "+/- = Beat Detection Sensitivity\n" + 
           "TAB = Use Next Arduino Port\n" + 
           "SPACE = Toggle full-screen\n" + 
           "Anything Else = Show this help", width-rightBorder(), topBorder());
      showHelp=false;
    }
     
    // Display the frame rate
    fill(16, 16, 16);
    textAlign(RIGHT, BOTTOM);
    text(nf(frameRate,2,1) + " fps", width - rightBorder(), topBorder());
    if(!fullscreen)
    {
    frame.setTitle("This Is Your Brain On Music ("+nf(frameRate,2,1)+" fps)");
    }

}
void initLasts(){
  for(int i = 0; i < fft.avgSize(); i++) {
    lastY[i] = height - bottomBorder();
    lastVal[i] = 0;
  }
  
}
void mousePressed(){
}
void stop(){//properly closes the program 
  in.close();
  minim.stop();
  super.stop();
}
