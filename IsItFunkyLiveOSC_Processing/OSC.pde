void sendOSC() {
  //phoneFilterMessage dry/wet 0-100 (parameter4 from 0-100)
  OscMessage phoneFilterMessage = new OscMessage("/live/device"); //(int track, int device, int parameter, int value) 
  phoneFilterMessage.add(0);
  phoneFilterMessage.add(0);
  phoneFilterMessage.add(4);
  phoneFilterMessage.add(70 - currentScoreLerp*7);
  oscP5.send(phoneFilterMessage, myRemoteLocation);


  //Turnado control parameter 3 + 4 values from 0-1) 
  OscMessage turnadoMessage3 = new OscMessage("/live/device"); //(int track, int device, int parameter, int value) 
  turnadoMessage3.add(0);
  turnadoMessage3.add(1);
  turnadoMessage3.add(3);
  if (currentScore <= 7) {
    turnadoMessage3.add(random(currentScoreLerp*5.0));
  } else {
    turnadoMessage3.add(0);
  }
  oscP5.send(turnadoMessage3, myRemoteLocation);


  OscMessage turnadoMessage4 = new OscMessage("/live/device"); //(int track, int device, int parameter, int value) 
  turnadoMessage4.add(0);
  turnadoMessage4.add(1);
  turnadoMessage4.add(4);
  if (currentScore <= 8) {
    turnadoMessage4.add( (10-currentScoreLerp)/10);
  } else {
    turnadoMessage4.add(0);
  }
  oscP5.send(turnadoMessage4, myRemoteLocation);
}

void oscTrigScenes() {
  if (classificationCounter % 5 == 0) {
    OscMessage sceneMessage = new OscMessage("/live/play/scene");
    sceneMessage.add(currentScene); 
    //myMessage.add(0); 
    oscP5.send(sceneMessage, myRemoteLocation);
  }
}


//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
  println("received message");
  if (theOscMessage.checkAddrPattern("/wek/outputs") == true) {
    if (theOscMessage.checkTypetag("f")) {
      float f = theOscMessage.get(0).floatValue();
      println("received1: " + f);

      if (f == 1.0) {
        lastReadingFunky = true;
      } else if (f == 2.0) {
        lastReadingFunky = false;
        glitch();
      }

      if (f == 1.0 && currentScore <= 9) {
        currentScore ++;
      } else if ( f == 2.0 && currentScore > 0) {
        currentScore --;
      }

      counterFunction(lastReadingFunky);
      oscTrigScenes();
    }
  }
}