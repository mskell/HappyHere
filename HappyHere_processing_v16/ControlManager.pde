//Used for testing arduino inputs and night/day mode

class ControlManager{

  //data
  ControlP5 cp5;


 //function
 ControlManager(PApplet p){
     cp5 = new ControlP5(p);

     cp5.begin(cp5.addBackground("abc"));

     cp5.addSlider("v1")
        .setPosition(10, 20)
        .setSize(200, 20)
        .setRange(0, 4)
        .setValue(0)
        .setLabel("feeling optimistic")
        ;

     cp5.addSlider("v2")
        .setPosition(10, 50)
        .setSize(200, 20)
        .setRange(0, 4)
        .setValue(0)
        .setLabel("feeling useful")
        ;

     cp5.addSlider("v3")
        .setPosition(10, 80)
        .setSize(200, 20)
        .setRange(0, 4)
        .setValue(0)
        .setLabel("feeling relaxed")
        ;

     cp5.addSlider("v4")
        .setPosition(10, 110)
        .setSize(200, 20)
        .setRange(0, 4)
        .setValue(0)
        .setLabel("handling problems")
        ;

     cp5.addSlider("v5")
        .setPosition(10, 140)
        .setSize(200, 20)
        .setRange(0, 4)
        .setValue(0)
        .setLabel("thinking clearly")
        ;

        cp5.addSlider("v6")
        .setPosition(10, 170)
      .setSize(200, 20)
      .setRange(0, 4)
      .setValue(0)
      .setLabel("close to people")
      ;

      cp5.addSlider("v7")
      .setPosition(10, 200)
      .setSize(200, 20)
      .setRange(0, 4)
      .setValue(0)
      .setLabel("making up own mind")
      ;



  cp5.addBang("startPressed")
      .setPosition(50, 280)
      .setSize(80, 20)
      //.setTriggerEvent(Bang.RELEASE)
      .setLabel("start")
      ;


  cp5.addBang("sendDataPressed")
      .setPosition(50, 320)
      .setSize(80, 20)

      //.setTriggerEvent(Bang.RELEASE)
      .setLabel("send")
      ;

  cp5.addToggle("setNightTime")
      .setPosition(50, 370)
      .setSize(80, 20)
      //.setTriggerEvent(Bang.RELEASE)
      .setLabel("night mode")
      ;

  cp5.addToggle("setDayTimeDemo")
      .setPosition(50, 420)
      .setSize(80, 20)
      //.setTriggerEvent(Bang.RELEASE)
      .setLabel("day mode demo")
      ;

  cp5.end();
  }

  int[] getValues(){
    int values[] =  {v1, v2, v3, v4, v5, v6, v7};
    return values;
  }
}