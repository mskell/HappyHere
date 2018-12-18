

class DayModeManager{

  //01. Idle
  int idleDelayStartDuration = 4000;
  int idleStartDuration = 1000;
  int idleStopDuration = 1000;

  //02. WaitValues
  int waitValuesDelayStartDuration = 1000;
  int waitValuesStartDuration = 1000;
  int waitValuesStopDuration = 1000;

  //03. Blobs
  int blobsDelayStartDuration = 2000;
  int blobsStartDuration = 2000;

  //The blobDurationTime is determined by data[5] (thinking clearly) - here it's possible to set the range
  int blobDurationTimeMin = 3000;
  int blobDurationTimeMax = 5000;

  //04. Blobsgrow
  //How fast is the growing transition
  int blobsGrowStartDuration = 200;
  //6000

  //How long does the solid colour last
  int blobsGrowDuration = 5000;
  //1000
  
  //How long does the fade-out transition last
  int blobsStopDuration = 2000;

  //EXTRA
  //White - choose the colour of the white of transitions - 0 to 255
  int transitionWhite = 40;


  //public
  DayModeManager(PApplet p){
    currentState = ModeState.IDLE;
    idleAnimation = new IdleAnimation();
    waitValuesAnimation = new WaitValuesAnimation();
    blobsAnimation = new BlobsAnimation();
    whiteColourAnimation = new WhiteColourAnimation(transitionWhite);

    idleAnimation.start(0, 0);


  }

  //Set to idle
  void startIdle(){
    currentState = ModeState.IDLE;
    idleAnimation.start(0, 0);

  }

  //Start Button
  void start(){
    if (currentState == ModeState.IDLE){
      currentState = ModeState.WAITVALUES;
      idleAnimation.stop(idleStopDuration);
      waitValuesAnimation.start(waitValuesStartDuration, waitValuesDelayStartDuration);
    }
  }

  //Send values - from wait to blobs
  void send(int[] _data){

    data = _data;

    if (currentState == ModeState.WAITVALUES){
      currentState = ModeState.BLOBS;

      blobsAnimation.start(blobsStartDuration, blobsDelayStartDuration, data);

      blobsStartTime = millis() + blobsDelayStartDuration;
      blobsDurationTime = blobsAnimation.getBlobsDuration();

      waitValuesAnimation.stop(waitValuesStopDuration);

      whiteColourAnimation.start(waitValuesStopDuration, max(0, blobsDelayStartDuration - waitValuesStopDuration), blobsStartDuration);
    }
  }

  boolean isWaitingValues(){
    return (currentState == ModeState.WAITVALUES);
  }


  void draw(){

    background(70);
    noStroke();

    if (blobsAnimation.isActive()) blobsAnimation.draw();

    pushMatrix();
    translate(525,225);
    if (idleAnimation.isActive()) idleAnimation.draw();
    if (waitValuesAnimation.isActive()) waitValuesAnimation.draw();

    //white on top - this is for the transitions
    if (whiteColourAnimation.isActive()) whiteColourAnimation.draw();

    popMatrix();

    updateStates();
  }

  void updateStates(){
    //From Blobs to solid
    if (currentState == ModeState.BLOBS) {

      if (millis() > blobsDurationTime + blobsStartDuration + blobsStartTime ) {
        currentState = ModeState.BLOBSGROW;

        blobsGrowingStartTime = millis();

        blobsAnimation.grow(blobsGrowStartDuration, blobsGrowDuration);

      }
    }

    else if (currentState == ModeState.BLOBSGROW) {

      if (millis() > blobsGrowDuration + blobsGrowStartDuration + blobsGrowingStartTime) {

        currentState = ModeState.IDLE;

        blobsAnimation.stop(blobsStopDuration);

        idleAnimation.start(idleStartDuration, idleDelayStartDuration);

        whiteColourAnimation.start(blobsStopDuration, max(0, idleDelayStartDuration - blobsStopDuration), idleStartDuration);

      }
    }

  }

  //private
  IdleAnimation idleAnimation;
  WaitValuesAnimation waitValuesAnimation;
  BlobsAnimation blobsAnimation;
  WhiteColourAnimation whiteColourAnimation;

  private ModeState currentState;

  int blobsStartTime;
  float blobsDurationTime;
  int blobsGrowingStartTime;

  int[] data;

  OPC opc;


}
