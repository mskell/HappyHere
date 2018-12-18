
//---PARAMETERS - Change these according to requirements ---//

//00. Use Test UI
//Set false or true if you want to show the testUI
boolean useTestingUI = false;
//boolean useTestingUI = true;

//01. Day time/Night time
//Written in minutes since midnight (8AM is 8*60; 1PM = 13*60; 1.30PM = 13*60 + 30)

//int startDayTime = 9*60; //9.00 AM 
int startDayTime = 30; //MIDNIGHT - due to residential neighbourhood
int startNightTime = 17*60;//5.00PM

//02. Night time - interval
//Interval between two colours displayed on the outside of the bothy
int outsideBothyChangingIntervalSec = 25;

OPC opc;

//-------------------------------------------------------//


//Input values
int v1, v2, v3, v4, v5, v6, v7;

//nightmode/daymode
boolean nightTime = false;

DataManager dataManager;
ControlManager testUI;
InputManager inputManager;
DayModeManager dayModeManager;
NightModeManager nightModeManager;

void setup() {

  size(750, 650);

  //set up OPC in one place
  setupOPC(this);

  //Setup testUI
  if (useTestingUI) testUI = new ControlManager(this);

  //Initiate app components
  dataManager = new DataManager(); //Save and load values to and from a file
  dayModeManager = new DayModeManager(this);
  nightModeManager = new NightModeManager(this);

  if (!useTestingUI) {
    //Initiate the inputManager (arduino) - setup is managed in the Input Manager class, while the serialEvent function is defined in this file
    //Change name of port to match rapsberrypi or mac
    inputManager = new InputManager(this, "/dev/ttyACM0");
  }
}

void draw() {


  if (!useTestingUI) {
    checkIfNightTime();
  }

  if (nightTime) {
    nightModeManager.draw();
  } else {
    dayModeManager.draw();
  }
}

//---HELP FUNCTIONS---//


void serialEvent(Serial myPort) {

  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString);
    String[] values = split(inString, ",");

    String command = values[7];

    if (command.indexOf("w") == 0) {
      //start
      dayModeManager.start();
    } else if (command.indexOf("s") == 0) {
      //send
      if (dayModeManager.isWaitingValues()) {
        v1 = parseInt(values[0]);
        v2 = parseInt(values[1]);
        v3 = parseInt(values[2]);
        v4 = parseInt(values[3]);
        v5 = parseInt(values[4]);
        v6 = parseInt(values[5]);
        v7 = parseInt(values[6]);

        sendDataPressed();
      } else {
        println("not on waiting mode");
      }
    } else if (command.indexOf("d") == 0) {

      //day (demo)
      setDayTimeDemo(true);
    } else if (command.indexOf("n") == 0) {
      //normal (demo off)
      setDayTimeDemo(false);
    }
  }
}

//Called when hw send button is pressed or by pressing the send button in the testUI (see ControlManager class)
void startPressed() {
  dayModeManager.start();
}

void sendDataPressed() {

  if (dayModeManager.isWaitingValues()) {
    int[] values = {v1, v2, v3, v4, v5, v6, v7};
    dataManager.saveCurrentValue(values);
    dayModeManager.send(values);
    println("Daymode - Show & save values:", v1, v2, v3, v4, v5, v6, v7 );
  } else {
    println("Not in wait values state - no data saved");
  }
}

void setNightTime(boolean newValue) {
  if (!nightTime) {
    nightModeManager.start(dataManager.getPastDayValues());
  }

  nightTime = newValue;
}

void setDayTimeDemo(boolean newValue) {

  //if true, set day time
  if (newValue) {
    useTestingUI = true;
    nightTime = false;
    dayModeManager.startIdle();
    println("demo mode - on day mode");
  } else {
    useTestingUI = false;
    println("demo mode - off day mode");
  }
}


void checkIfNightTime() {
  int currentMinutes = hour()*60 + minute();
  if (currentMinutes > startDayTime && currentMinutes < startNightTime) {
    nightTime = false;
  } else {

    //If switching to night time, start the nightModeManager
    if (!nightTime) {
      nightModeManager.start(dataManager.getPastDayValues());
    }

    nightTime = true;
  }
}

void setupOPC(PApplet p) {
  opc = new OPC(p, "127.0.0.1", 7890);
  opc.ledGrid(0, 50, 24, 525, 225, 8, 16, 0, false); // had to make this 24 strips even though we are using 23 strips of 50 RGB neopixel

  // 5 x 240 RGB LED Light Bar, Black -  (EQUINOX - RGB POWER BATTEN)
  // dmx lamps on p2 (4 channel dmx, addresses below)
  // DMX pixel locations drawn to screen
  opc.led(1540, 475, 525); //DMX roof lamp (FIXTURE A, address d001)
  opc.led(1541, 500, 540); //DMX top left corner (FIXTURE B, address d005) // moved near lamp 9
  opc.led(1542, 500, 550); //DMX bottom left corner (FIXTURE C, address d0009)
  opc.led(1543, 550, 500); //DMX top right corner (FIXTURE D, address d0013)
  opc.led(1544, 550, 550); //DMX bottom right corner (FIXTURE E, address d0017)
}