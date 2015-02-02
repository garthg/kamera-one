/** Scalifier
 *
 * Converts scalar input into audio output using music theory rules.
 *
 */

import ddf.minim.signals.*;

public class Scalifier {
  
  // Scale definition
  public int[] pitchClasses = {0,3,5,7,10}; // Scale as pitch classes
  public int pitchClassOffset = 4; // Key of the scale
  
  // Settings
  private final float amplitude = (float)0.2; // range 0 to 1
  private final int minNoteDuration = 0; // milliseconds
  private final int maxNoteDuration = 1000; // milliseconds
  
  // Instance variables
  public Oscillator osc;
  private long noteOnTime;
  //private long playbackStartTime = -1;
  
  public Scalifier(Oscillator oscillator) {
    this.osc = oscillator;
    this.osc.setAmp(0);
  }
  
  private float midiToFreq(int midi) {
    return (float)(Math.pow(2, (midi-69)/12.0)*440.0);
  }
  
  public void noteOnFreq(float freq) {
    if (System.currentTimeMillis() > this.noteOnTime + this.minNoteDuration) {
      this.osc.setAmp(this.amplitude);
      this.osc.setFreq(freq);
      this.noteOnTime = System.currentTimeMillis();
      //System.out.println("Note on: "+freq);
    }
  }
  
  public void noteOff() {
    this.osc.setAmp(0);
  }
  
  public void noteOnMidi(int midi) {
    this.noteOnFreq(this.midiToFreq(midi));
  }
  
  public void noteOnStep(int step) {
    //System.out.println("Step "+step);
    int octave = (int)Math.floor(step / this.pitchClasses.length);
    int offset = (int)Math.floor(step % this.pitchClasses.length);
    int note = octave*12 + this.pitchClasses[offset] + this.pitchClassOffset;
    this.noteOnMidi(note);
  }
  
  public void updateScale(float[] scale) {
  }
  
  public void tick() {
    if (System.currentTimeMillis() > this.noteOnTime + this.maxNoteDuration) {
      this.noteOff();
    }
    //if (this.playbackStartTime >= 0) {
    //  long elapsed = System.currentTimeMillis() - this.playbackStartTime;
    //}
  }
  
}
