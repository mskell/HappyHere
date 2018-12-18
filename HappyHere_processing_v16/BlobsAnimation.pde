class BlobsAnimation extends Animation {

  //brightness - 0 to 255
  //optimistic
  float brightnessMin = 230;
  float brightnessMax = 255;

  //saturation - 0 to 100
  //feeling useful
  float saturationMin = 80;
  float saturationMax = 100;

  //jitteriness - 0 to 100
  //feeling relaxed
  float jitterinessMin = 3;
  float jitterinessMax = 5;

  //circleSize - 0 to 500
  //dealing with problems
  float circleSizeMin = 300;
  float circleSizeMax = 200;

  //hue variation - 0 to 360
  //thinking clearly
  float hueVariationMin = 300;
  float hueVariationMax = 180;

  //blobbiness - 0 to 100
  //close to other people
  float blobbinessMin = 20;
  float blobbinessMax = 8;

  //blobInterval (ms) - 0 to 10000
  //this is set by transition
  //making up own mind
  float blobIntervalMin = 14000;
  float blobIntervalMax = 8000;

  //hue - 0 to 360 (circular, min value can be bigger than max value )
  float hueMin = 170;
  float hueMax = 90;

  float brightness;
  float jitteriness;
  float hueVariation;
  float saturation;
  float blobbiness;
  float blobInterval;
  float circleSize;

  float increment = .03;

  float incrementt = .026;
  float xoff = 0;  //size of circle
  float yoff = 0;  //position of circle
  float toff=0;

  int[] data;

  int finalHue;

  float selectedColour;
  float[] selectedHSV = {0, 0, 0};

  float growTimeDurationMs = 1000;
  float growStartTimeDurationMs = 1000;
  int blobsGrowingStartTime;
  float growScale = 1;
  boolean growing;


  BlobsAnimation() {
  }


  public void start(int _startTimeDurationMs, int _startDelayDurationMs, int[] _data) {

    super.start(_startTimeDurationMs, _startDelayDurationMs);
    growing = false;
    growScale = 1;

    data = _data;

    brightness = map(data[0], 0, 4, brightnessMin, brightnessMax);
    saturation = map(data[1], 0, 4, saturationMin, saturationMax);
    jitteriness = map(data[2], 0, 4, jitterinessMax, jitterinessMin);
    incrementt = map(jitteriness, 0, 100, 0.0005, 0.2);
    circleSize = map(data[3], 0, 4, circleSizeMin, circleSizeMax);
    hueVariation = map(data[4], 0, 4, hueVariationMin, hueVariationMax);
    blobbiness = map(data[5], 0, 4, blobbinessMin, blobbinessMax);
    blobInterval = map(data[6], 0, 4, blobIntervalMin, blobIntervalMax);

    println(blobInterval);
  }

  public void stop(int _stopTimeDurationMs) {
    super.stop(_stopTimeDurationMs);

    growing = false;
  }

  public void grow(int _growStartTimeDurationMs, int _growTimeDurationMs) {
    growStartTimeDurationMs = _growStartTimeDurationMs;
    growTimeDurationMs = _growTimeDurationMs;
    growing = true;
    blobsGrowingStartTime = millis();
  }

  float getBlobsDuration() {
    return blobInterval;
  }

  float[] getSelectedHSV() {
    return selectedHSV;
  }

  public void draw() {

    updateEasing();

    if (delay) return;

    //For start andstop
    float opacityMult = map(easing, 0, 100, 0, 1);

    //just for growing
    if (growing) {
      growScale = min(100, map(millis() - blobsGrowingStartTime, 0, growStartTimeDurationMs, 1, 100));
    }
    float circleSizeScaled = circleSize*growScale;

    pushStyle();

    noStroke();
    colorMode(HSB, 360, 100, 100);

    //Main Hue
    float valuesSum = 0;
    for (int i=0; i<7; i++) valuesSum+=data[i];
    selectedColour = 0;
    float hueMaxScaled = hueMax;
    if (hueMax < hueMin) {
      hueMaxScaled = hueMax+360;
    }
    selectedColour = map(valuesSum, 0, 28, hueMin, hueMaxScaled)%360;

    selectedHSV[0] = selectedColour;
    selectedHSV[1] = saturation;
    selectedHSV[2] = brightness;


    xoff=0;                     // line(0,200-d,200,200-d
    toff += incrementt;

    int areaSize = (int)blobbiness;

    int areaInc = (areaSize*2)/6; // this changes how far apart each new shape is drawn 

    // this is to get the middle of the visualisation in the centre of OPC grid
    int centrex = 525;
    int centrey = 225;

    int i = 0;

    for (int x=(centrex-areaSize); x<(centrex+areaSize); x+=areaInc) {
      xoff += increment*2;
      yoff=0;
      for (int y=(centrey-areaSize); y<(centrey+areaSize); y+=areaInc) {
        yoff +=increment*2;

        float selectedColourRandomness = hueVariation*max(0, map(dist(centrex, centrey, x, y), areaInc, areaSize, 0, 1));
        if (centrex < x) selectedColourRandomness*=-1;

        float selectedColourVariation;
        if (i%2 == 0) selectedColourVariation = selectedColour;
        else selectedColourVariation = (selectedColour + selectedColourRandomness)%360;
        i+=1;

        //------------ different alpha values for day / night time as the DMX always looks washed out

        if (nightTime == true) {
          fill(selectedColourVariation, saturation, brightness, 230); // change alpha value here to tweak based on colour of DMX v neopixels
        } else { 
          fill(selectedColourVariation, saturation, brightness, 48); // change alpha value here to tweak based on ambient light levels in bothy space
        }

        float d = noise(xoff, yoff, toff)*circleSizeScaled; 
        ellipse((x), (y), d, d);
      }
    }

    //uncomment for complementary colour on DMX 
    //fill(selectedColour, saturation, brightness, 100);

    //uncomment for contrast colour on DMX 
    fill(selectedColour+180, saturation, brightness, 255);

    //draw colour on DMX only during day mode 
    if (nightTime == false) {
      rect(350, 480, 350, 80);
    }

    // slows down app, useful to see diffusion without hardware
    //filter(BLUR, 3);

    popStyle();
  }
}