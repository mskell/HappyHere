// Rotary encoder code from 'rotary encoder demo' by 'jurs' on the Arduino Forum - thank you! 
// HappyHere arduino code written by Martin Skelly December 2018

// prototcol for sending data serially to rpi running 
// 112500 baudrate

// 0,0,0,0,0,0,0,d - DEMO - override night mode to allow interaction
// 0,0,0,0,0,0,0,n - NORMAL
// 0,0,0,0,0,0,0,w - WAKE
// 0,0,0,0,0,0,0,s - SEND

struct rotary_t {
  byte pinA;
  byte pinB;
  int count;
};


// define 2 pins foreach rotary encoder
rotary_t encoder[] = { 
  {12, 13}, // encoder[0].pinA, encoder[0].pinB // optimistic
  {10, 11}, // encoder[1].pinA, encoder[1].pinB // useful
  {8, 9}, // encoder[2].pinA, encoder[2].pinB // relaxed
  {6, 7}, // encoder[3].pinA, encoder[3].pinB // problems
  {4, 5}, // encoder[4].pinA, encoder[4].pinB // clearly
  {2, 3}, // encoder[5].pinA, encoder[5].pinB // other people
  {14, 15}, // encoder[6].pinA, encoder[6].pinB // own mind

};


//define output pins for each led
int pinMatrix[7][5] = {
  {18, 19, 20, 21, 22},
  {23, 24, 25, 26, 27},
  {28, 29, 30, 31, 32},
  {33, 34, 35, 36, 37},
  {38, 39, 40, 41, 42},
  {43, 44, 45, 46, 47},
  {48, 49, 50, 51, 52}
};


#define NUMENCODERS (sizeof(encoder)/sizeof(encoder[0]))

volatile byte state_ISR[NUMENCODERS];
volatile int8_t count_ISR[NUMENCODERS];


unsigned long debounceDelay = 50;

const int sendButton = A13;
int sendbuttonState = 0;
int sendlastButtonState = HIGH;
unsigned long sendlastDebounceTime = 0;  

const int startButton = A14;
int startbuttonState = 0;
int startlastButtonState = HIGH;
unsigned long startlastDebounceTime = 0;  

const int modeButton = A15;
int modebuttonState = 0;
int modelastbuttonState = HIGH;
unsigned long modelastDebounceTime = 0;  



void beginEncoders()
{ // active internal pullup resistors on each encoder pin and start timer2
  for (int i = 0; i < NUMENCODERS; i++)
  {
    pinMode(encoder[i].pinA, INPUT_PULLUP);
    pinMode(encoder[i].pinB, INPUT_PULLUP);
    readEncoder(i); // Initialize start condition
  }
  startTimer2();
}



boolean updateEncoders()
{ // read all the 'volatile' ISR variables and copy them into normal variables
  boolean changeState = false;
  for (int i = 0; i < NUMENCODERS; i++)
  {
    if (count_ISR[i] != 0)
    {
      changeState = true;
      noInterrupts();
      encoder[i].count += count_ISR[i];

      //put counter back to 0 if over 5
      if (encoder[i].count >= 5) {
        for (int j = 0; j < 5; j++) { 
          digitalWrite(pinMatrix[i][j], LOW);
        }
        encoder[i].count = 0;
      }
      //int led_count = encoder[i].count;
      digitalWrite(pinMatrix[i][encoder[i].count], HIGH);
      
      for (int i = 0; i < 7; i++) {
        digitalWrite(pinMatrix[i][0], HIGH); // turn first row back on...
      }

      count_ISR[i] = 0;
      interrupts();
    }
  }
  return changeState;
}


void printEncoders()
{ // print current count of each encoder to Serial
  for (int i = 0; i < NUMENCODERS; i++)
  {
    Serial.print(encoder[i].count);
    // if loop below stops comma at very end
    if (i < 6)
    {
      Serial.print(','); // formatting for processing to listen
    }

  }
  Serial.print(',');
  Serial.print('s'); // s or send
  Serial.println(); // send new line for processing to detect end of sequence

  for (int i = 0; i < NUMENCODERS; i++)
  {
    encoder[i].count = 0;
  }
}

int8_t readEncoder(byte i)
{ // this function is called within timer interrupt to read one encoder!
  int8_t result = 0;
  byte state = state_ISR[i];
  state = state << 2 | (byte)digitalRead(encoder[i].pinA) << 1 | (byte)digitalRead(encoder[i].pinB);
  state = state & 0xF;  // keep only the lower 4 bits
  // next two lines is code to read 'full steps'
  if (state == 0b0001) result = -1;
  else if (state == 0b0010) result = 1;
  state_ISR[i] = state;
  return result;
}


void startTimer2()  // start TIMER2 interrupts
{
  noInterrupts();
  // Timer 2 CTC mode
  TCCR2B = (1 << WGM22) | (1 << CS22)  | (1 << CS20);
  TCCR2A = (1 << WGM21);
  OCR2A = 124;   // 249==500,  124==1000 interrupts per second
  TIMSK2 = (1 << OCIE2A); // enable Timer 2 interrupts
  interrupts();
}

void stopTimer2() // stop TIMER2 interrupts
{
  noInterrupts();
  TIMSK2 = 0;
  interrupts();
}


ISR(TIMER2_COMPA_vect)  // handling of TIMER2 interrupts
{
  for (int i = 0; i < NUMENCODERS; i++)
  {
    count_ISR[i] += readEncoder(i);
  }
}

void startFunction()
{
  Serial.print("0,0,0,0,0,0,0,");
  Serial.print('w'); // w for wake
  Serial.println();


  for (int i = 0; i < 7; i++) {
    for (int j = 0; j < 6; j++) {
      digitalWrite(pinMatrix[i][j], LOW); // turn all leds off
    }
  }
  for (int i = 0; i < 7; i++) {
    digitalWrite(pinMatrix[i][0], HIGH); // turn first row back on...
  }
}

#define BAUDRATE 115200L // serial baud rate

void setup() {
  Serial.begin(BAUDRATE);
  beginEncoders();

  for (int i = 0; i < 7; i++) {
    for (int j = 0; j < 5; j++) {
      pinMode(pinMatrix[i][j], OUTPUT);
    }
  }

  // initialize the pushbutton pin as an input:
  pinMode(sendButton, INPUT);
  pinMode(startButton, INPUT);
  pinMode(modeButton, INPUT);

}

void loop() {
  //uncomment to print full serial readings
  //if (updateEncoders()) printEncoders();

  // uncomment to update but not print
  if (updateEncoders()); // this is true if at least one encoder count has changed since last call of updateEncoders()

  // read the state of the pushbutton value:
  int sendreading = digitalRead(sendButton);
  int startreading = digitalRead(startButton);
  int modereading = digitalRead(modeButton);


  // If the switch changed, due to noise or pressing:
  if (sendreading != sendlastButtonState) {
    // reset the debouncing timer
    sendlastDebounceTime = millis();
  }

  if ((millis() - sendlastDebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (sendreading != sendbuttonState) {
      sendbuttonState = sendreading;

      // only toggle the LED if the new button state is HIGH
      if (sendbuttonState == LOW) {

        printEncoders();
        //Serial.println("send button pressed");

        for (int i = 0; i < 7; i++) {
          for (int j = 0; j < 5; j++) {
            digitalWrite(pinMatrix[i][j], LOW);
          }
        }


      }
    }
  }

  // If the switch changed, due to noise or pressing:
  if (startreading != startlastButtonState) {
    // reset the debouncing timer
    startlastDebounceTime = millis();
  }

  if ((millis() - startlastDebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (startreading != startbuttonState) {
      startbuttonState = startreading;

      // only toggle the LED if the new button state is HIGH
      if (startbuttonState == LOW) {

        startFunction();
      }
    }
  }

  // If the switch changed, due to noise or pressing:
  if (modereading != modelastbuttonState) {
    // reset the debouncing timer
    modelastDebounceTime = millis();
  }

  if ((millis() - modelastDebounceTime) > debounceDelay) {

    // if the button state has changed:
    if (modereading != modebuttonState) {
      modebuttonState = modereading;

      // only toggle the LED if the new button state is HIGH
      if (modebuttonState == LOW) {
        Serial.print("0,0,0,0,0,0,0,");
        Serial.print('d'); // d for demo mode

        Serial.println();

      }
      else {
        Serial.print("0,0,0,0,0,0,0,");
        Serial.print('n'); // n for normal mode
        Serial.println();
      }
    }
  }

  // save the reading. Next time through the loop, it'll be the lastButtonState:
  sendlastButtonState = sendreading;
  startlastButtonState = startreading;
  modelastbuttonState = modereading;


}
