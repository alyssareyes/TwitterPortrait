/* TWITTER PORTRAIT
A processing sketch which dynamicaly paints a user's portrait based on twitter 
The number of new tweets about hair, eyes, and face drive the color density of 

Created for ARTS444 at University of Illinois, Urbana-Champaign

Authored by Alyssa Reyes, 2014
*/

import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import com.temboo.core.*;
import com.temboo.Library.Twitter.Search.*;

// Temboo Data that needs to be populated based on individual account informati
// See https://www.temboo.com/library/Library/Twitter/ for details
Tweets twitterSearch;
TweetsResultSet tweetsResults;
TembooSession session = new TembooSession("", "", ""); 
String accessToken = "";
String accessTokenSecret = "";
String APIkey = "";
String APISecret = "";

// lastID will keep track of the last tweet ID we saw 
String lastID1 = "0";
String lastID2 = "0";
String lastID3 = "0";



OpenCV opencv;
Capture video;

PVector [] darkPoints;
PVector [] medPoints;
PVector [] lightPoints;

PVector [] darkPointsA;
PVector [] medPointsA;
PVector [] lightPointsA; 

PVector[] motionPixels;

boolean colorsSet = false;
boolean showPoints = false;

int newX = 0;
int newY = 0;
int jumpX = 7;
int jumpY = 7;
int size = jumpX;

// global variables for opencv face detection
int faceX;
int faceY;
int faceW;
int faceH;

color dark;
color med;
color light;
color darkA;
color medA;
color lightA;

int mode = 0;

color [] prevFrame;
float threshold = 100;

int timer;


void setup() {
  size(1120, 720);
  // TODO: uncomment below to enable twitter drawing
  //  setupTwitterSearch();

  video = new Capture(this, 160, 120);
  opencv = new OpenCV(this, 160, 120);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  video.start();

  dark = color(#57504f);
  med = color(#4faac0);
  light = color(#f7fac5);

  darkA = color(#3d4d75);
  medA = color(#f2662f);
  lightA = color(#c8f0c2);

  prevFrame = new color[video.width * video.height];
  for (int i=0; i<prevFrame.length; i++)
    prevFrame[i] = color(255, 0, 0);

  background(200);
  timer = millis();
}


void draw() {
  drawPoints();

  if (colorsSet) {
      // TODO: uncomment to draw with twitter data
      //    thread("checkTimer");
    paintMotion();
  }

  // draw with mouse movement instead of twitter
  if (colorsSet && isInFace(mouseX, mouseY)) {
    int count = (int)random(20, 200);
    int type = (int)random(0, 3);
    for (int i=0; i<count; i++)
      getTriangle(type, mouseX, mouseY);
  }

//  saveFrame();
}


// Checks if a given coordinate is inside the face frame defined by openCV
boolean isInFace(int x, int y) {
  if (x > faceX && x < (faceX+faceW) && y > faceY && y < (faceY+faceH))
    return true;
  else 
    return false;
}

 
// checks if camera has finished initializing (i.e. image is not blacked out)
boolean checkIfCameraInit() {
  int loc = int(int(random(video.width-1)) + int(random(video.height-1)) * video.width);
  if ((red(video.pixels[loc])!=0 || green(video.pixels[loc])!=0 || blue(video.pixels[loc])!=0) &&
    (red(video.pixels[loc]) < 255)) {
    return true;
  }
  return false;
}


// utility to that draws captured camera image & value ranges captured
void drawPoints() {
  noStroke();
  if (colorsSet) {
    if (showPoints) {
      for (int i=0; i<darkPoints.length; i++) {
        fill(dark);
        ellipse(darkPoints[i].x, darkPoints[i].y, 5, 5);
      }
      for (int i=0; i<medPoints.length; i++) {
        fill(med);
        ellipse(medPoints[i].x, medPoints[i].y, 5, 5);
      }
      for (int i=0; i<lightPoints.length; i++) {
        fill(light);
        ellipse(lightPoints[i].x, lightPoints[i].y, 5, 5);
      }
      for (int i=0; i<darkPointsA.length; i++) {
        fill(darkA);
        ellipse(darkPointsA[i].x, darkPointsA[i].y, 5, 5);
      }
      for (int i=0; i<medPointsA.length; i++) {
        fill(medA);
        ellipse(medPointsA[i].x, medPointsA[i].y, 5, 5);
      }
      for (int i=0; i<lightPointsA.length; i++) {
        fill(lightA);
        ellipse(lightPointsA[i].x, lightPointsA[i].y, 5, 5);
      }
    }
  }
  else if (!colorsSet && checkIfCameraInit())
    populateData();
  else
    return;
}


void populateData() {
  
  // pixels must be populated and a face must be detected
  opencv.loadImage(video);
  Rectangle[] faces = opencv.detect();
  if (faces.length<=0)
    return;

  faceX = faces[0].x*jumpX - (faces[0].x*jumpX)/6;
  faceY = faces[0].y*jumpY - (faces[0].y*jumpY)/6;
  faceW = faces[0].width*jumpX + (faces[0].width*jumpX)/4;
  faceH = faces[0].height*jumpY + (faces[0].height*jumpY)/4;

  ArrayList <PVector> tempDarkPoints = new ArrayList <PVector>();
  ArrayList <PVector> tempLightPoints = new ArrayList <PVector>();
  ArrayList <PVector> tempMedPoints = new ArrayList <PVector>();

  ArrayList <PVector> tempDarkPointsA = new ArrayList <PVector>();
  ArrayList <PVector> tempLightPointsA = new ArrayList <PVector>();
  ArrayList <PVector> tempMedPointsA = new ArrayList <PVector>();

  for (int y=0; y<video.height; y++) {
    for (int x=0; x<video.width; x++) {
      int location = x + y * video.width;
      color c = video.pixels[location];

      //get accent colors
      if (brightness(c) < 100)
        tempDarkPoints.add(new PVector(newX + random(20), newY+random(20)));
      else if (brightness(c) >=100 && brightness(c) < 200)
        tempMedPoints.add(new PVector(newX+random(20), newY+random(20)));
      else
        tempLightPoints.add(new PVector(newX+random(20), newY+random(20)));

      // get accent colors
      if (brightness(c) < 50)
        tempDarkPointsA.add(new PVector(newX + random(20), newY+random(20)));
      else if (brightness(c) >=100 && brightness(c) < 110)
        tempMedPointsA.add(new PVector(newX+random(20), newY+random(20)));
      else if (brightness(c) > 230)
        tempLightPointsA.add(new PVector(newX+random(20), newY+random(20)));

      newX +=jumpX;
    } 
    newX =0;
    newY += jumpY;
  }  

  darkPoints = transferData(tempDarkPoints);
  medPoints = transferData(tempMedPoints);
  lightPoints = transferData(tempLightPoints);
  darkPointsA = transferData(tempDarkPointsA);
  medPointsA = transferData(tempMedPointsA);
  lightPointsA = transferData(tempLightPointsA);

  colorsSet = true;
}


// helper that transfers arrayList contents to an array
PVector[] transferData(ArrayList<PVector> temp) {
  PVector [] newArray = new PVector[temp.size()];
  for (int i=0; i<temp.size(); i++)
    newArray[i] = temp.get(i);

  return newArray;
}


// use point slope term to help create a gradual opacity gradient
float pointSlope(int x, int x1, int x2) {
  float slope = 1.0 / float(x1-x2);
  return slope*(x-x1) + 1;
}

// set painting opacity to be highest inside face area, and then gradually fade
int getOpacity(int x, int y ) {
  int opacity;

  if (isInFace(x, y)) {
    return 210;
  }
  else {
    if (x < faceX)
      opacity = (int)lerp(245, 0, pointSlope(x, 0, faceX)) ;
    else if (x > faceX + faceW)
      opacity = (int)lerp(245, 0, pointSlope(x, video.width*jumpY, faceX+faceW)) ;
    else if (y < faceY)
      opacity = (int)lerp(245, 0, pointSlope(y, 0, faceY));
    else 
      opacity = (int)lerp(245, 0, pointSlope(y, height, faceY+faceH)) ;
  }
  return opacity;
}


// scribble in values at a given x and y. type determines color of stroke
void getTriangle(int type, int x, int y) {
  PVector [] working;
  color workingColor;

  int opacity = getOpacity(x, y);

  if (type==0) {
    working = darkPoints;
    workingColor = color(dark, opacity);
  }
  else if (type==1) {
    working = medPoints;
    workingColor = color(med, opacity);
  }
  else if (type==2) {
    working = lightPoints;
    workingColor = color(light, opacity);
  }
  else if (type==3) {
    working = darkPointsA;
    workingColor = color(darkA, 10);
  }
  else if (type==4) {
    working = medPointsA;
    workingColor = color(medA, 10);
  }
  else {
    working = lightPointsA;
    workingColor = color(lightA, 10);
  }

  float minDist = 100;
  float secondDist = 101;
  int start = (int)random(working.length);
  for (int i=0; i<working.length; i++) {
    float currDist = dist(x, y, working[i].x, working[i].y);
    if (currDist < minDist) {
      start = i;
      minDist = currDist;
    }
  }

  minDist = 100;
  int point1 = (int)random(working.length);
  int point2 = (int)random(working.length);
  for (int i=0; i<working.length; i++) {
    float currDist = dist(x, y, working[i].x, working[i].y);
    if (currDist < minDist && i!=start) {
      point1 = i;
      minDist = currDist;
    }
    else if (currDist < secondDist && i!=point1 && i!=start) {
      point2 = i;
      secondDist = currDist;
    }
  }

  if (type < 3 && isInFace(x, y) && (minDist >=50 || secondDist >=50)) 
    return;
  else if (type < 3 && !isInFace(x, y) && (minDist >=100 || secondDist >=100))
    return;
  else if (type >=3 && (minDist >=100 || secondDist >=100))
    return;

  stroke(workingColor);
  if (type>=3)
    strokeWeight(4);
  else if (type < 3 &&  !isInFace(x, y))
    strokeWeight(int(random(0, 3)));
  else {
    strokeWeight(1);
  }
  float offset = random(10);
  line(working[start].x, working[start].y, working[point1].x+offset, working[point1].y);
  line(working[start].x, working[start].y, working[point2].x+offset, working[point2].y); 
  line(working[point2].x, working[point2].y, working[point1].x+offset, working[point1].y);
}



void captureEvent(Capture c) {
  c.read();
}

// http://www.learningprocessing.com/examples/chapter-16/example-16-13/
PVector[] getMotionLocation() {
  ArrayList <PVector> motionPix = new ArrayList<PVector>();

  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int loc = x + y*video.width;            
      color current = video.pixels[loc];    
      color previous = prevFrame[loc];

      float diff = dist(red(current), green(current), blue(current), red(previous), green(previous), blue(previous));
      if (diff > threshold) 
        motionPix.add(new PVector(x*jumpX, y*jumpY));

      prevFrame[loc] = current;
    }
  }
  return transferData(motionPix);
}


// fill in background and accent colors with limited movement interaction
void paintMotion() {
  PVector [] motion = getMotionLocation();
  opencv.loadImage(video);
  Rectangle[] faces = opencv.detect();

  for (int i=0; i<motion.length; i++) {
    int type = int(random(3, 6));
    if (motion.length < 100)
      getTriangle(type, int(motion[i].x), int(motion[i].y));

    if (motion.length < 50 && faces.length>0 && faces[0].width*jumpX + (faces[0].width*jumpX)/4 > faceW) {
      type = int(random(0, 3));
      int x = (int)random(0, width);
      int y = (int)random(0, height);
      if (!isInFace(x, y))
        getTriangle(type, x, y);
    }
  }
}



void checkTimer() {
  if (millis() > timer + 5000) {
    timer = millis();
    PVector results = search();
    println("results: " + results.x + ", " + results.y + ", " + results.z);

    for (int i=0; i<results.x; i++) 
      getTriangle(0, (int)random(faceX, faceX + faceW), (int)random(faceY, faceY + faceH));

    for (int i=0; i<results.y; i++) 
      getTriangle(1, (int)random(faceX, faceX + faceW), (int)random(faceY, faceY + faceH));

    for (int i=0; i<results.z; i++) 
      getTriangle(2, (int)random(faceX, faceX + faceW), (int)random(faceY, faceY + faceH));
  }
}




// -------------------- [TWITTER STUFF] -------------------
// based off code written by Ben Grosser

void setupTwitterSearch() {
  twitterSearch = new Tweets(session);
  twitterSearch.setAccessToken(accessToken);
  twitterSearch.setAccessTokenSecret(accessTokenSecret);
  twitterSearch.setConsumerSecret(APISecret);
  twitterSearch.setConsumerKey(APIkey);
}


PVector search() {
  ArrayList test = getTweetsResults("hair", 1);

  ArrayList test2 = getTweetsResults("eye", 2);

  ArrayList test3 = getTweetsResults("face", 3);

  println("You have "+tweetsResults.getRemaining()+" searches remaining today.");


  return (new PVector(test.size(), test2.size(), test3.size()));
}

ArrayList getTweetsResults(String q, int id) {
  twitterSearch.setQuery(q);
  twitterSearch.setCount("200");

  // setSinceId says to only get tweets SINCE lastID
  if (id==1)
    twitterSearch.setSinceId(lastID1);
  else if (id==2)
    twitterSearch.setSinceId(lastID2);
  else
    twitterSearch.setSinceId(lastID3);


  tweetsResults = twitterSearch.run();
  JSONObject searchResults = parseJSONObject(tweetsResults.getResponse());
  JSONArray statuses = searchResults.getJSONArray("statuses"); // Create a JSON array of the Twitter statuses in the object

  JSONObject tweets;

  try {
    tweets = statuses.getJSONObject(0); // Grab the first tweet and put it in a JSON object
  } 
  catch (Exception e) {
    tweets = null;
  }

  ArrayList results = new ArrayList();

  if (tweets != null) {
    // grab the lastID of the last tweet processed
    if (id==1)
      lastID1 = statuses.getJSONObject(0).getString("id_str");
    else if (id==2)
      lastID2 = statuses.getJSONObject(0).getString("id_str");
    else
      lastID3 = statuses.getJSONObject(0).getString("id_str");

    for (int i = 0; i < statuses.size(); i++) {
      String tweetText = statuses.getJSONObject(i).getString("text");
      results.add(tweetText);
    }
  }
  return results;
}  

