class NightModeManager{

  //01. Empty
  int emptyStartDuration = 2000;
  int emptyDuration = 1000;
  int emptyStopDuration = 500;

  //White - choose the colour of the white of transitions - 0 to 255
  int emptyWhite = 40;

  //02. Blobs
  int blobsDelayStartDuration = 0;
  int blobsStartDuration = 500;
  //testing is quick - actual is slow
  //int blobsDurationTime = 2000;
  int blobsDurationTime = 12000;
  
  //03. Blobsgrow
  //How fast is the growing transition
  int blobsGrowStartDuration = 1000;

  //How long does the solid colour last
  int blobsGrowDuration = 6000;

  //How long does the fade-out transition last
  int blobsStopDuration = 2000;

  //public
  NightModeManager(PApplet p){
    currentState = ModeState.NIGHTEMPTY;
    emptyAnimation = new WhiteColourAnimation(emptyWhite);
    blobsAnimation = new BlobsAnimation();
  }

  //When Nightmode starts
  void start(JSONArray _dayArray){
    dayArray = _dayArray;

    if (dayArray == null || dayArray.size() == 0){
      println("No values - cannot show day time");
      return;
    }else{
      currentDayItemIndex = 0;
      startBlob();
    }

  }

  void startBlob(){
    
    
    currentState = ModeState.BLOBS;
    
    JSONArray dayItemValues = dayArray.getJSONObject(currentDayItemIndex).getJSONArray("values");
    int data[] = new int[dayItemValues.size()];

    for (int i=0; i<dayItemValues.size(); i++){
      data[i] = dayItemValues.getJSONObject(i).getInt("id");
    }

    blobsStartTime = millis() + blobsDelayStartDuration;

    //Start blob
    blobsAnimation.start(blobsStartDuration, blobsDelayStartDuration, data);

    //stop empty animation
    emptyAnimation.stop(emptyStopDuration);

    currentDayItemIndex+=1;
    if (currentDayItemIndex == dayArray.size()) currentDayItemIndex = 0;


  }


  void draw(){

    background(40); // change this if DMX too white...?
    

    if (dayArray == null || dayArray.size() == 0){
      println("No values - cannot show day time");
      return;
    }

    noStroke();

    pushMatrix();
    
    translate(0,300);
    scale(0.5);
    translate(525,250); // move blob down to DMX pixels only in nightmode because of push / pop
    
    ///* LEO SUGGESTION - make the blob bigger*/
    //pushMatrix();
    //translate(525,225);
    ////scale(7);
    //translate(-525,-225);

    if (blobsAnimation.isActive()) blobsAnimation.draw();
    popMatrix();


    //popMatrix();
    pushMatrix();
    translate(525,525);
    if (emptyAnimation.isActive()) emptyAnimation.draw();
    popMatrix();
    
    
    
    updateStates();
    
    //pushMatrix();
    ////// draw permanent black rectangle over output box pixels in night mode
    //fill(10);
    //rect(315,25,420,400);
    //popMatrix();
    
    
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
        currentState = ModeState.NIGHTEMPTY;

        emptyStartTime = millis();

        blobsAnimation.stop(blobsStopDuration);

        emptyAnimation.start(emptyStartDuration,emptyDuration, emptyStopDuration);


      }
    }else if (currentState == ModeState.NIGHTEMPTY) {
      if (millis() > emptyDuration + emptyStartDuration + emptyStartTime) {
        startBlob();

      }
    }

  }

  //private
  BlobsAnimation blobsAnimation;
  WhiteColourAnimation emptyAnimation;

  private ModeState currentState;

  int blobsStartTime;
  int blobsGrowingStartTime;

  int emptyStartTime;

  JSONArray dayArray = null;
  int currentDayItemIndex = 0;

  OPC opc;


}
