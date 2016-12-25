#pragma once

#include "ofxCcv.h"
#include "ofxOsc.h"
#include "ofxTextInputField.h"


class ofApp : public ofBaseApp {
public:
    void setup();
    void update();
    void draw();
    
    void sendOsc();
    void keyPressed(int key);
    void mousePressed(int x, int y, int button);
    string removeSpaces (string input);
    void runScrapeScript();
    
    ofxOscSender osc;
    ofxOscMessage msg;
    
    ofxCcv ccv;
    
    vector<float> classifierEncoding;
    vector<float> featureEncoding;
    
    string oscHost, oscAddress;
    int oscPort;
    
    bool sending;
    
    vector <ofImage> images;
    
    int imgIndex = 0;
    int nFiles;
    
    int currentInput = 1;
    ofColor selectedInputColor = (255,0,255);
    
    bool imagePlayback = false;
    
    ofxTextInputField monoLineTextInput;
    ofTrueTypeFont font;
    
    int selectedImage = 0;
    
    int gridX;
    int gridY;
    
    ofImage loadingImg;
    
    Boolean loading = false;
    long loadingCounter = -1;
    
};