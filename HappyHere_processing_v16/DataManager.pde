class DataManager {
  
  DataManager(){}
  
  public void saveCurrentValue(int data[]){
    
    int dayItemId = -1;
    JSONArray dayArray;
    ////1. if there's a file with current date, open and read and get array, if not create it
    String currentDayFilename = year()+"-"+month()+"-"+day()+".json";
    if (fileExists(currentDayFilename)){
      dayArray = loadJSONArray(currentDayFilename); //get object
      dayItemId = dayArray.size();
    }else{
      dayArray = new JSONArray(); //get object
      dayItemId = 0;
    }
    
    ////2. add new entry 
    JSONObject dayItem = new JSONObject();
    
    Date d = new Date();
    dayItem.setString("time",""+d.getTime()); 
    
    JSONArray dayItemValues = new JSONArray();
    for (int i = 0; i < data.length; i++) {
      JSONObject value = new JSONObject();
      value.setInt("id", data[i]);
      dayItemValues.setJSONObject(i, value);
    }
    dayItem.setJSONArray("values", dayItemValues);
    
    dayArray.setJSONObject(dayItemId, dayItem);
   
   
    ////3. save updated file
    saveJSONArray(dayArray, "data/"+currentDayFilename);
 
  }
  
  public JSONArray getPastDayValues(){
    
    String todayFilename = year()+"-"+month()+"-"+day()+".json";     
    String yesterdayFilename = getYesterdayDateString()+".json"; 
     
    String filename;
        
    //Get latest file (today's date or yesterday's date)
    if (fileExists(todayFilename)) filename = todayFilename;
    else if (fileExists(yesterdayFilename)) filename = yesterdayFilename;
    else {
      JSONArray jsonArrayEmpty = new JSONArray();
      return jsonArrayEmpty;
    }
    
    JSONArray dayArray = loadJSONArray(filename);
        
    return dayArray;
    
    
  }
  
  private boolean fileExists(String filename){
        
    File f = new File(dataPath(filename));
    if (f.exists()){
      return true;
    }else{
      return false;
    }
  }
  
  private Date yesterday() {
    final Calendar cal = Calendar.getInstance();
    cal.add(Calendar.DATE, -1);
    return cal.getTime();
  }
  
  private String getYesterdayDateString() {
    DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    return dateFormat.format(yesterday());
}
    
  
}
