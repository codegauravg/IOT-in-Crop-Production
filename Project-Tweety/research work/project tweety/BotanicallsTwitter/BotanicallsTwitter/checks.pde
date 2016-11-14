//function for checking soil moisture against threshold
void moistureCheck() {
  static int counter = 1;//init static counter
  int moistAverage = 0; // init soil moisture average
  if((millis() - lastMoistTime) / 1000 > (MOIST_SAMPLE_INTERVAL / MOIST_SAMPLES)) {
    for(int i = MOIST_SAMPLES - 1; i > 0; i--) {
      moistValues[i] = moistValues[i-1]; //move the first measurement to be the second one, and so forth until we reach the end of the array.   
    }
    moistValues[0] = analogRead(MOISTPIN);//take a measurement and put it in the first place
    lastMoistTime = millis();
    int moistTotal = 0;//create a little local int for an average of the moistValues array
    for(int i = 0; i < MOIST_SAMPLES; i++) {//average the measurements (but not the nulls)
      moistTotal += moistValues[i];//in order to make the average we need to add them first 
    }
    if(counter<MOIST_SAMPLES) {
      moistAverage = moistTotal/counter;
      counter++; //this will add to the counter each time we've gone through the function
    }
    else {
      moistAverage = moistTotal/MOIST_SAMPLES;//here we are taking the total of the current light readings and finding the average by dividing by the array size
    } 
    //lastMeasure = millis();
    Serial.print("moist: ");
    Serial.println(moistAverage,DEC); 

    ///return values
    if ((moistAverage < DRY)  &&  (lastMoistAvg >= DRY)  &&  (millis() > (lastTwitterTime + TWITTER_INTERVAL)) ) {
      uint8_t response = posttweet("URGENT! Water me!");   // announce to Twitter
      notify(response); 
    }
    else if  ((moistAverage < MOIST)  &&  (lastMoistAvg >= MOIST)  &&  (millis() > (lastTwitterTime + TWITTER_INTERVAL)) ) {
      uint8_t response = posttweet("Water me please");   // announce to Twitter
      notify(response); 
    }
    lastMoistAvg = moistAverage; // record this moisture average for comparision the next time this function is called
  }
}


//function for checking for watering events
void wateringCheck() {
  int moistAverage = 0; // init soil moisture average
  if((millis() - lastWaterTime) / 1000 > WATERED_INTERVAL) {

    int waterVal = analogRead(MOISTPIN);//take a moisture measurement
    lastWaterTime = millis();

    Serial.print("watered: ");
    Serial.println(waterVal,DEC);
    if (waterVal >= lastWaterVal + WATERING_CRITERIA) { // if we've detected a watering event
      if (waterVal >= SOAKED  &&  lastWaterVal < MOIST &&  (millis() > (lastTwitterTime + TWITTER_INTERVAL))) {
        uint8_t response = posttweet("Thank you for watering me!");  // announce to Twitter
        notify(response); 
      }
      else if  (waterVal >= SOAKED  &&  lastWaterVal >= MOIST  &&  (millis() > (lastTwitterTime + TWITTER_INTERVAL)) ) {
        uint8_t response = posttweet("You over watered me");   // announce to Twitter
        notify(response); 
      }
      else if  (waterVal < SOAKED  &&  lastWaterVal < MOIST  &&  (millis() > (lastTwitterTime + TWITTER_INTERVAL)) ) {
        uint8_t response = posttweet("You didn't water me enough");   // announce to Twitter
        notify(response); 
      }
    }    
    lastWaterVal = waterVal; // record the watering reading for comparison next time this function is called
  }
}


// function that prints twitter results to debug port
void notify( uint8_t resp) {
  if (resp)
  Serial.println("twitter sent");
  else {
    Serial.println("twitter failed");
  }
}
