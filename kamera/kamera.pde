/* Webcam captures video input and uses Scalifier to generate live audio. */


import processing.video.*;
import ddf.minim.*;
import ddf.minim.signals.*;

// Webcam objects and settings.
Capture cam;
int dimW = 320; // Must match camera.
int dimH = 240; // Must match camera.

// Sensitivity parameters.
int minDiffAdd = (int)(dimW*dimH*255*.02);
int minDiffUpdate = minDiffAdd*1;
int portamentoTime = 10;
int minUpdateWait = 30;

// Webcam diff state variables.
int[] lastPixels;
int[] currPixels;

// Sound synthesis objects.
Minim minimBacking;
Minim minimSynth;
AudioOutput audioOut;
Oscillator waveform;
AudioPlayer audioPlayer;
Scalifier scalifier;

// Sound update state variables.
int note = 35;
int sumL = 0;
int sumR = 0;
long lastChangeTime = 0;


void setup() {
  size(dimW,dimH);
  cam = new Capture(this, 320, 240, 30);
  cam.start();
  lastPixels = new int[dimW*dimH];
  currPixels = new int[dimW*dimH];
  minimBacking = new Minim(this);
  minimSynth = new Minim(this);
  audioPlayer = minimBacking.loadFile("backing_track_organ.mp3",8192);
  audioOut = minimSynth.getLineOut(minimSynth.STEREO, 16384);
  waveform = new SineWave(440, 0, audioOut.sampleRate());
  waveform.portamento(portamentoTime);
  audioOut.addSignal(waveform);
  audioPlayer.play();
  scalifier = new Scalifier(waveform);
}

void notifyPitchUp() {
  for (int i=dimW-1; i>dimW-1-10; i--) {
    for (int j=0; j<10; j++) {
      set(i,j,color(255,0,0));
    }
  }
}

void notifyPitchDown() {
  for (int i=0; i<10; i++) {
    for (int j=0; j<10; j++) {
      set(i,j,color(0,0,255));
    }
  }
}

void pitchUpdate() {
  if (sumL + sumR > minDiffUpdate && System.currentTimeMillis() > lastChangeTime+minUpdateWait) {
    //println("Pitch update");
    if (sumL > sumR) {
      note = max(note-1, 20);
      scalifier.noteOnStep(note);
      //println(note);
      notifyPitchDown();
    } else {
      note  = min(note+1, 40);
      scalifier.noteOnStep(note);
      //println(note);
      notifyPitchUp();
    }
    sumL = 0;
    sumR = 0;
    lastChangeTime = System.currentTimeMillis();
  }
}

void draw() {
  scalifier.tick();
  if(cam.available()) {
    cam.read();
    set(0,0,cam);
    int sumRCurr = 0;
    int sumLCurr = 0;
    for (int i=0; i<dimW; i++) {
      for (int j=0; j<dimH; j++) {
        color c = get(i,j);
        int grey = (int)((red(c)+green(c)+blue(c))/3);
        int diff = abs(grey - lastPixels[j*dimW+i]);
        lastPixels[j*dimW+i] = grey;
        currPixels[j*dimW+i] = diff;
        if (i<dimW/2) {
          sumRCurr += diff;
        } else {
          sumLCurr += diff;
        }
      }
    }
    for (int i=0; i<dimW; i++) {
      for (int j=0; j<dimH; j++) {
        int diff = currPixels[j*dimW+i];
        set(dimW-1-i,j,color(256-diff,256-diff,256-diff));
      }
    }
    if (sumRCurr > minDiffAdd) {
      sumR += sumRCurr;
    }
    if (sumLCurr > minDiffAdd) {
      sumL += sumLCurr;
    }
    pitchUpdate();
  }
}

void stop() {
  audioOut.close();
  audioPlayer.close();
  minimBacking.stop();
  minimSynth.stop();
  super.stop();
}

/* I call him MC Beep Boop */

