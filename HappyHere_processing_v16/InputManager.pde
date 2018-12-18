
class InputManager{
  Serial myPort;
  InputManager (PApplet p, String serialPort) {
    myPort = new Serial(p, serialPort, 115200);
    //// don't generate a serialEvent() unless you get a newline character:
    myPort.bufferUntil('\n');
    
  } 
}
