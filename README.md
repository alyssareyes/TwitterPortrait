# Twitter Portrait
*A processing sketch which dynamicaly paints a user's portrait based on twitter. The number of new tweets about hair, eyes, and face drive the color density of.*  
*Alternatively this can also be run as a portrait painting application that is driven by mouse movement and physical movement detected by a web camera.* 

## Setup
1. install [Processing](https://processing.org/download/)
2. download [OpenCV for Processing](https://github.com/atduskgreg/opencv-processing) and place in /Documents/Processing/libraries folder
3. Open sentientMirror.pde in Processing
4. Run with Sketch > Present (Shft + Ctrl/Cmd + R)

### Additional Setup to enable Twitter Drawing
1. Sign up for [Temboo](https://www.temboo.com/) and [Twitter](https://twitter.com/signup)
2. Register your application in Twitter to obtain API keys. (Instructions [here](https://www.temboo.com/library/Library/Twitter/Search/))
3. Populate the lines 10-14 in TwitterPortrait.pde (shown below) with your Temboo and Twitter keys  
    
        TembooSession session = new TembooSession("", "", "");  
        String accessToken = "";  
        String accessTokenSecret = "";  
        String APIkey = "";  
        String APISecret = "";  
4. Uncomment lines 79 and 108 in TwitterPortrait.pde (shown below)  
         79: setupTwitterSearch();  
        ...
        108: thread("checkTimer");

## Screenshot
![SCREENSHOT](https://40.media.tumblr.com/768f22e39e9fa2fbdc36645b2d793260/tumblr_n791cbBd6n1tez6lno2_540.png)

*Twitter Portrait was written for ARTS444 at University of Illinois, Urbana-Champaign by Alyssa Reyes in Spring 2014*

