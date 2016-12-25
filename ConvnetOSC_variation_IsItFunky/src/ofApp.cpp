
/*
Final exhibition version at SchoolOfMa
*/



#include "ofApp.h"

//--------------------------------------------------------------

void ofApp::setup() {
    ofSetFullscreen(false);
    
    gridX = ofGetWidth()/6;
    gridY = gridX;
    
    monoLineTextInput.setup();
    monoLineTextInput.text = "Funk?";
    monoLineTextInput.bounds.x = gridX*1.5;
    monoLineTextInput.bounds.y = gridY*3 + 50;
    monoLineTextInput.bounds.height = ofGetHeight() - (gridY*3 + 50 + 50);
    monoLineTextInput.bounds.width = gridX*3;
    font.loadFont(OF_TTF_SANS, 36);
    monoLineTextInput.setFont(font);
    
    ccv.setup("/Users/andreasrefsgaard/Documents/OpenFrameworks/of_v0.9.0_osx_release/apps/ml4a-ofx/apps/ConvnetOSC/bin/data/image-net-2012.sqlite3");
    if (!ccv.isLoaded()) return;
    
    oscPort = 6448;
    oscAddress = "/wek/inputs";
    oscHost = "localhost";
    
    osc.setup(oscHost, oscPort);
    sending = false;
    
    ofDirectory dir;
    
    nFiles = dir.listDir("/Users/andreasrefsgaard/Documents/OpenFrameworks/of_v0.9.0_osx_release/apps/ml4a-ofx/apps/ConvnetOSC_variation_IsItFunky/bin/data/googleImages");
    
    cout << nFiles;
    
    if(nFiles) {
        
        for(int i=0; i<dir.size()-1; i++) {
            // add the image to the vector
            //string filePath = dir.getPath(i);
            
            string filePath = "googleImages/Action_" + ofToString(i+1) + ".jpg";
            
            images.push_back(ofImage());
            images.back().load(filePath);
            
        }
    }
    else ofLog(OF_LOG_WARNING) << "Could not find folder";
    
    
    loadingImg.load("loadingImg.png");

    
}

//--------------------------------------------------------------

void ofApp::update() {
    if (loadingCounter == ofGetFrameNum()) {
        loading = true;
    } else {
        loading = false;
    }
    
    if (loadingCounter+1 == ofGetFrameNum()) {
        runScrapeScript();
    }
}


//--------------------------------------------------------------

void ofApp::draw() {
    
    ofBackground(0);
    
    if (!ccv.isLoaded()) {
        ofDrawBitmapString("Network file not found! Check your data folder to make sure it exists.", 20, 20);
        return;
    }
    
    
    int n = 18;
    for (int i = 0; i<n; i++) {
        images[i + nFiles - 20].draw((i%6)*gridX, floor(i/6)*gridY, gridX, gridY);
        }
   
    //Marked rectangle
    ofSetColor(0,255,0);
    ofNoFill();
    ofSetLineWidth(10);
    ofDrawRectangle((selectedImage%6)*gridX, 0 + floor(selectedImage/6.0)*gridY, gridX, gridY);
    
    
    //Input text
    ofSetColor(255);
    ofSetLineWidth(5);
    ofRect(monoLineTextInput.bounds);
    ofNoFill();
    monoLineTextInput.draw();

    
    
    //Debug selected image
    images[nFiles - 20 + selectedImage].draw(ofGetWidth()-25, ofGetHeight()-25, 25, 25);
    
    //Instruction text
    ofDrawBitmapString("INSTRUCTIONS: \nClick an image to get it \nclassified as funky or boring \n\nPress ENTER for new image search", gridX*4.75, gridY*3 + 50);
    
    ofSetColor(255);
    if (loading) loadingImg.draw(0, 0, gridX*6, gridY*3);
    ofSetColor(255);
}


//--------------------------------------------------------------

void ofApp::sendOsc() {
    
    //featureEncoding = ccv.encode(images[imgIndex], ccv.numLayers()-1);
    featureEncoding = ccv.encode(images[nFiles - 20 + selectedImage], ccv.numLayers()-1);
    
    msg.clear();
    msg.setAddress(oscAddress);
    for (int i=0; i<featureEncoding.size(); i++) {
        msg.addFloatArg(featureEncoding[i]);
    }
    osc.sendMessage(msg);
    
}


void ofApp::runScrapeScript() {
    
    string queryString = removeSpaces(monoLineTextInput.text); //Hacky way to solve space issue
    
    string scrapeScript = ofSystem("/anaconda/bin/python /Users/andreasrefsgaard/Documents/OpenFrameworks/of_v0.9.0_osx_release/apps/ml4a-ofx/apps/ConvnetOSC_variation_IsItFunky/bin/data/googleScrape.py --search " + queryString);
    
    
    cout << scrapeScript;
    
    for(int i=0; i<20; i++) {
        string filePath = "googleImages/Action_" + ofToString(i+nFiles) + ".jpg";
        images.push_back(ofImage());
        images.back().load(filePath);
    }
    nFiles +=20;
}


//--------------------------------------------------------------

void ofApp::keyPressed(int key) {
    
//    if(key == 's')    sendOsc();
    
    if(key == OF_KEY_RETURN){
        loading = true;
        loadingCounter = ofGetFrameNum();
        
        
        //runScrapeScript();
        
//        string queryString = removeSpaces(monoLineTextInput.text); //Hacky way to solve space issue
//        
//        string scrapeScript = ofSystem("/anaconda/bin/python /Users/andreasrefsgaard/Documents/OpenFrameworks/of_v0.9.0_osx_release/apps/ml4a-ofx/apps/ConvnetOSC_variation_IsItFunky/bin/data/googleScrape.py --search " + queryString);
//        
//        
//        cout << scrapeScript;
//        
//        for(int i=0; i<20; i++) {
//            string filePath = "googleImages/Action_" + ofToString(i+nFiles) + ".jpg";
//            images.push_back(ofImage());
//            images.back().load(filePath);
//        }
//        nFiles +=20;
        
    }
}

//--------------------------------------------------------------

void ofApp::mousePressed(int x, int y, int button){

    if (y > 0 && y< 0+gridY*1) {
        selectedImage = ceil(x/gridX);
    } else if (y > 0+gridY && y< 0+gridY*2) {
        selectedImage = ceil(x/gridX) + 6;
    } else if (y > 0+gridY && y< 0+gridY*3) {
        selectedImage = ceil(x/gridX) + 12;
    }
    
    cout << ofToString(selectedImage) + " ";
    
    
    if (y<gridY*3) {
        sendOsc();
    }
    
}

//-------------------------------------------------------------- //Hacky way to solve space issue
string ofApp::removeSpaces(string input){
    input.erase(std::remove(input.begin(),input.end(),' '),input.end());
    return input;
}
