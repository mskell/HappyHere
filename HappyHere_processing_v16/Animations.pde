public enum ModeState {
  IDLE, WAITVALUES, BLOBS, BLOBSGROW, NIGHTEMPTY
}


  class Animation {

  // float
  protected int startTimeDurationMs, stopTimeDurationMs;
  int startDelayDurationMs;
  protected int startTime, stopTime;

  float easing;
  boolean delay = true;
  boolean starting = false;
  boolean stopping = false;
  boolean active = false;

  Animation() {
    easing = 0;
  }

  boolean isStarting() {
    return starting;
  }

  boolean isStopping() {
    return stopping;
  }

  boolean isActive() {
    return active;
  }

  void start(int _startTimeDurationMs, int _startDelayDurationMs) {
    startTime = millis();
    startDelayDurationMs = _startDelayDurationMs;
    startTimeDurationMs = _startTimeDurationMs;
    delay = true;
    starting = true;
    active = true;
    stopping = false;
  }

  void stop(int _stopTimeDurationMs) {
    stopTime = millis();
    stopTimeDurationMs = _stopTimeDurationMs;
    stopping = true;
  }

  void updateEasing() {

    //start easing
    if (delay) {
      if (millis() - startTime > startDelayDurationMs) {
        delay = false;
      }
    } else {
      if (millis() - (startTime+startDelayDurationMs) < startTimeDurationMs) {
        easing = map(millis() - (startTime+startDelayDurationMs), 0, startTimeDurationMs, 0, 100); //from 0 to 255
      } else {
        if (starting) {
          starting = false;
          easing = 100;
        }
      }
    }

    // stop easing
    if (millis() - stopTime < stopTimeDurationMs) {
      easing = map(millis() - stopTime, 0, stopTimeDurationMs, 100, 0); //from 0 to 255
    } else {
      if (stopping) {
        active = false;
        stopping = false;
        easing = 0;
      }
    }
  }

  void draw() {
  }
}


class IdleAnimation extends Animation {
  IdleAnimation() {
  }

  void draw() {

    updateEasing();

    pushStyle();
    float opacity = map(easing, 0, 100, 0, 255);
    fill(235, 235, 235, opacity);

    float radius = 100 + 90*sin(millis()*.002);
    
    ellipse(0, 0, radius, radius);
    //ellipse(0, 300,radius+100, radius+100);
    popStyle();
    
    //// this turns off the DMX for after midnight and during wait mode
    //fill(0);
    //rect(-100, 250, 150, 80);  

  }
}


class WaitValuesAnimation extends Animation {
  WaitValuesAnimation() {
  }


  void draw() {
    updateEasing();
    pushStyle();

    color orange = color(234, 99, 0, 255);
    color paleblue = color(0, 206, 189, 255);

    color currentStroke;
    float loopStep;
    float animStep;
    int left = -225;
    int right = 225;
    animStep = abs(sin(frameCount * 0.035666667)); // this 0.01xxxxxxx number is linked to multiplyer below for equal colour spread


          for (int i = -350; i <= 375; i += 1) {
      loopStep = map(i, 100, 0, 0.0, 1.0);
      currentStroke = lerpColor(orange, paleblue, (loopStep + animStep) * 0.55, RGB);
      stroke(currentStroke);
      line(left, i-10, right, i-10); // the int here is the offset for when colour stops top and bottom
    }

   popStyle();
  }
}

class nightFadeAnimation extends Animation {
  nightFadeAnimation() {
  }


  void draw() {
    updateEasing();
    pushStyle();

    color orange = color(234, 99, 0, 255);
    color paleblue = color(0, 206, 189, 255);

    color currentStroke;
    float loopStep;
    float animStep;
    int left = -225;
    int right = 225;
    
    animStep = abs(sin(frameCount * 0.005666667)); // this 0.01xxxxxxx number is linked to multiplyer below for equal colour spread


    for (int i = -40; i <= 40; i += 1) {
      loopStep = map(i, width, 0, 0.0, 1.0);
      currentStroke = lerpColor(orange, paleblue, (loopStep + animStep) * 0.35, RGB);
      stroke(currentStroke);
      line(-150, i-10, 150, i-10); // the int here is the offset for when colour stops top and bottom
    }
   popStyle();
  }
}

class WhiteColourAnimation extends Animation {
  int brightness = 100;
  int stopTimeDurationMs = 0;
  int timeDurationMs = 0;
  WhiteColourAnimation(int _brightness) {
    brightness = _brightness;
  }

  void start(int _startTimeDurationMs, int _timeDurationMs, int _stopTimeDurationMs) {
    super.start(_startTimeDurationMs, 0);
    stopTimeDurationMs = _stopTimeDurationMs;
    timeDurationMs = _timeDurationMs;
  }

  void draw() {

    updateEasing();

    if (!isStopping() && (millis() > startTimeDurationMs + timeDurationMs + startTime)) stop(stopTimeDurationMs);

    pushStyle();
    fill(brightness, map(easing, 0, 100, 0, 255));
    rect(-width, -height, 2*width, 2*height);

    popStyle();
  }
}