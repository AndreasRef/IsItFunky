//To do:

//Rename counterfunction
//Switch between videos when a new scene starts / Make a newer/better video 
//Better score text
//More Glitch
//Less Stretch Scores

import oscP5.*;
import netP5.*;
import ddf.minim.*;
import glitchP5.*; // import GlitchP5
import processing.video.*;

//Movie stuff
GlitchP5 glitchP5;
Movie myMovie;
Movie noiseMovie;

float rotation = 0;
float rotationLerp;

//OSC related libraries
OscP5 oscP5;
NetAddress myRemoteLocation;

Minim minim;
AudioSample[] funkySounds;
AudioSample[] unfunkySounds;

//Ports defined by LiveOSC,cannot be changed
int inPort = 9001;
int outPort = 9000;

int classificationCounter = 0;
int currentScene = 0;

int currentScore = 10;
float currentScoreLerp = currentScore;

boolean lastReadingFunky;

PImage funkyCat;
PImage boringVacuum;

int scoreImageCounter = 0;

void setup() {
  //size(720, 480);
  fullScreen(2);

  minim = new Minim(this);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("localhost", outPort);

  glitchP5 = new GlitchP5(this); // initiate the glitchP5 instance;
  //myMovie = new Movie(this, "isItFunkyDance.mp4");
  myMovie = new Movie(this, "dance1.mov");
  myMovie.loop();
  
  
  noiseMovie = new Movie(this, "noiseVacuum.mp4");
  noiseMovie.loop();

  int sampleLength = 8;

  funkySounds = new AudioSample[sampleLength];
  unfunkySounds = new AudioSample[sampleLength];

  funkyCat = loadImage("funkyCat.png");
  boringVacuum = loadImage("boringVacuum.png");

  for (int i = 0; i<sampleLength; i++) {
    funkySounds[i] = minim.loadSample( "funky" + i +".mp3", 512 );
    unfunkySounds[i] = minim.loadSample( "unfunky" + i +".mp3", 512 );
    funkySounds[i].setGain(-10.0);
    unfunkySounds[i].setGain(-10.0);
  }
}

void draw() {
  background(0);

  //pushMatrix();
  //translate(width/2, height/2);
  //imageMode(CENTER);
  //rotate(rotation);
  //rotation = lerp(rotation, 0, 0.4);
  
  image(myMovie, width/4, height/4, width/4, height/4);
  image(myMovie, width/2, height/4, width/4, height/4);
  image(myMovie, width/2, height/2, width/4, height/4);
  image(myMovie, width/4, height/2, width/4, height/4);
  
  //image(myMovie, 0, 0, width/2, height/2);
  
  //image(myMovie, 0, 0, width/4, height/4);
  //image(myMovie, width/4, 0, width/4, height/4);
  //image(myMovie, 0, height/4, width/4, height/4);
  //image(myMovie, width/4, height/4, width/4, height/4);
  
  
  //popMatrix();
  glitchP5.run();

  myMovie.speed(0.0 + currentScore/10.0);
  noiseMovie.speed(0.0 + currentScore/10.0);

  fill(255);

  //text("lastReadingFunky: " + lastReadingFunky, 100, height - 65);
  pushStyle();
  textAlign(CENTER);
  textSize(48);
  text("FUNK SCORE: " + currentScore, width/2, height - 200);
  popStyle();
  
  pushStyle();
  textAlign(LEFT);
  textSize(10);
  text("lastReadingFunky: " + lastReadingFunky + " --- CurrentScene " + currentScene + " --- classificationCounter: " + classificationCounter, 10, height - 5);
  popStyle();

  sendOSC();

  if (random(30)>29 + currentScore/9) {
    glitch();
  }
    
  pushStyle();
  imageMode(NORMAL);
  ////blendMode(MULTIPLY);
  tint(255, map(currentScoreLerp, 10, 0, 0, 255));
  image(noiseMovie, width/4,height/4, 960, 770);
  popStyle();
  if (frameCount%10 == 0) println(frameRate);
  
    currentScoreLerp = lerp(currentScoreLerp, currentScore, 0.05);

  if (scoreImageCounter > 0) { 
    scoreImage(lastReadingFunky);
    scoreImageCounter --;
  }
  
}

void mousePressed() {

  glitch();
  if (mouseX > width/2) {
    lastReadingFunky = true;
  } else if (mouseX < width/2) {
    lastReadingFunky = false;
  }

  if (mouseX > width/2 && currentScore <= 9) {
    currentScore ++;
  } else if (mouseX < width/2 && currentScore > 0) {
    currentScore --;
  }

  counterFunction(lastReadingFunky);
  oscTrigScenes();
}

void counterFunction (boolean funky) {

  scoreImageCounter = 15;

  if (funky) {
    funkySounds[int(random(funkySounds.length))].trigger();
  } 

  if (!funky) {
    unfunkySounds[int(random(unfunkySounds.length))].trigger();
  }

  //Change scenes
  classificationCounter++;
  if (classificationCounter % 5 == 0) {
    currentScene++;
  }

  if (currentScene > 11) {
    currentScene =0;
  }
}

void movieEvent(Movie m) {
  m.read();
}

void glitch() {
  glitchP5.glitch(width/2, height/2, width/2-50, height/2-50, width/2-50, height/2-50, (int)map(currentScore, 0, 10, 4, 0), map(currentScore, 0, 10, 0.5, 0), int(random(20, 100)), int(random(2, 8)));
  //if (random(1)>0.5) rotation = random(-0.3, 0.3);
}

void scoreImage(boolean funky) {
  pushStyle();
  imageMode(CORNERS);
  if (funky) {
    image(funkyCat, width - width/3, height/4, width, height);
  } else {
    image(boringVacuum, 0, height/4, width/3, height);
  }
  popStyle();
}