int bgColor=0;
  int framerate = 24; 
  int playerHole = 40;
  int teamHole = 30;
  int holeMargin = 60;
  int ballSize = 20;
  int ballInitX = 20;
  int ballInitY = 20;
  int t = 5;
  float x = 0;
  float y = 0;

  float speedX = 10;
  float speedY = 3;
  
  PGraphics board;
  PGraphics pgNorth;
  PGraphics pgWest;
  PGraphics pgSouth;
  PGraphics pgEast;

  int gWidth=600;
  int gHeight=600;
  int pHeight = 90;
  int bHeight = gHeight-2*pHeight;
  int bWidth = gWidth-2*pHeight;
  int pWScore = 0;
  int pNScore = 0;
  int pEScore = 0;
  int pSScore = 0;
  int gridUnit = 60;
  int start = 1;
  int game = 2;
  int end = 3;
  int state = start;
  int startTime;
  PFont font;
    
//PGraphics pg;

 void setup() {
    size(600,600);
    gWidth = 600;
    gHeight = 600;
    bHeight = gHeight-2*pHeight;
    bWidth = gWidth-2*pHeight;     
    frameRate(framerate);
    x = ballInitX;
    y = ballInitY;
    board = createGraphics(bWidth, bHeight);
    pgNorth = createGraphics(gWidth, gHeight);
    pgWest = createGraphics(gWidth, gHeight);
    pgSouth = createGraphics(gWidth, gHeight);
    pgEast = createGraphics(gWidth, gHeight);
    font = createFont("OpenSans-ExtraBold", 42);
  
  }

  void draw() {
    background(bgColor);
    if(state == start){
      board.beginDraw();
      board.background(bgColor);
      drawGrid(board);
      drawHoles(board, false);
      board.endDraw();
      image(board, pHeight, pHeight);
      fill(255);
      textSize(60);
      rectMode(CENTER);
      textAlign(CENTER, CENTER);
      textFont(font);
      textLeading(42);
      text("HIT ANY PEDAL TO START", gWidth/2, gHeight/2, bWidth/1.5, bHeight);
    }else if(state == game){
      drawBoard();
      drawScorePanels();
      updateTime();
      //speed increase
      float newX = x+speedX;
      float newY = y+speedY;
      //air hockey
       speedX = speedX*0.9;
       speedY = speedY*0.9;

      if (bounceX(newX)){
        speedX = -speedX;
      }else{
        x = newX;
      }
      if (bounceY(newY)){
        speedY = -speedY;
      }else{
        y = newY;
      }
    }else if(state == end){
      drawScorePanels();      
      fill(255);
      textSize(36);
      rectMode(CENTER);
      textAlign(CENTER, CENTER);
      textFont(font);
      textLeading(48); 
      text("END MESSAGE ABOUT HOW WORKING IN A TEAM BRINGS BENEFITS FOR ALL", gWidth/2, gHeight/2, bWidth/1.2, bHeight);
      updateTime();
    }


  }


  void drawScorePanels(){

    drawPanel(pgNorth, -PI, gWidth/2, pHeight/2, pHeight,pNScore, bgColor);
    drawPanel(pgWest, PI/2, pHeight/2, gWidth/2, pHeight,pWScore, bgColor);
    drawPanel(pgSouth, 0, gWidth/2, gHeight-pHeight/2, pHeight,pSScore, bgColor);
    drawPanel(pgEast, -PI/2, gWidth-pHeight/2, gHeight/2, pHeight,pEScore, bgColor);
    image(pgEast, 0, 0); 
    image(pgNorth, 0, 0); 
    image(pgWest, 0, 0); 
    image(pgSouth, 0, 0); 

  }

  void drawPanel(PGraphics pg, float rotation, int x, int y, int pHeight, int pScore, int col){
    pg.beginDraw();
    pg.pushMatrix();
    pg.noStroke();
    pg.rectMode(CENTER);
    pg.translate(x, y);
    pg.rotate(rotation);
    pg.fill(col);
    pg.rect(0, 0, height, pHeight);
    pg.textSize(32);
    pg.fill(255);
    pg.text(pScore, -10, 15); 


    pg.popMatrix();
    pg.endDraw();

  }
  void drawBoard(){
    board.beginDraw();
    board.background(bgColor);
    board.stroke(255);
    board.strokeWeight(5);
    board.fill(0);
    drawGrid(board);
    drawHoles(board, true);
    drawBall(board, x, y );
    board.endDraw();
    image(board, pHeight, pHeight);

  }

  void drawHoles(PGraphics pg, boolean drawCentedHole){
    pg.fill(0);

    pg.strokeWeight(5);
    //players holes
    //west
    pg.stroke(246,105,33);
    pg.ellipse(holeMargin,bHeight/2, playerHole, playerHole);
    //east
    pg.stroke(194,27,49);
    pg.ellipse(bWidth-holeMargin,bHeight/2, playerHole, playerHole);
    //north
    pg.stroke(43,156,241);
    pg.ellipse(bWidth/2,holeMargin, playerHole, playerHole);
    //south
    pg.stroke(255,242,0);
pg.ellipse(bWidth/2,bHeight-holeMargin, playerHole, playerHole);
    //center hole
    if(drawCentedHole){
      pg.stroke(27,194,81);
      pg.ellipse(bWidth/2,bHeight/2, teamHole, teamHole);
    }
  }

  // void drawHole(PGraphics pg, int x, int y){
  //   pg.ellipse(x,y, playerHole, playerHole);
  // }
  boolean isScored = false; 

  void drawScoring(){
    isScored = true;
    x = ballInitX;
    y = ballInitY;
    isScored = false;
    //speeding up
    speedX+=5;
    speedY+=5;
  }
  void drawBall(PGraphics pg, float x, float y){

    // pg.noStroke();
    pg.stroke(255);
    pg.strokeWeight(5);
    pg.fill(255,0,255);
    pg.ellipse(x,y, ballSize, ballSize);
    //west
    if(dist(holeMargin, bHeight/2, x, y)<playerHole/2 && isScored == false){
      drawScoring();
      pWScore++;
    }else if(dist(bWidth-holeMargin,bHeight/2, x, y)<playerHole/2 && isScored == false){
      //east
      drawScoring();
      pEScore++;
    }else if(dist(bWidth/2,holeMargin, x, y)<playerHole/2 && isScored == false){
      //north
      drawScoring();
      pNScore++;
    }else if(dist(bWidth/2,bHeight-holeMargin, x, y)<playerHole/2 && isScored == false){
      //south
      drawScoring();
      pSScore++;
    }else if(dist(bWidth/2,bHeight/2, x, y)<playerHole/2 && isScored == false){
      //center
      drawScoring();
      pWScore+=4;
      pNScore+=4;
      pEScore+=4;
      pSScore+=4;
    }
  }

  boolean bounceX(float x){
    return x>bWidth-ballSize/2 || x<ballSize;
  } 


  boolean bounceY(float y){
    return y>bHeight-ballSize/2 || y<ballSize;
  } 



  void keyPressed() {
    println(key);
    //-x
    if (key == 97) {
      if (state == start){
        changeState(game);
      }else if(state == game){
        speedX = -10;  
      }
    }
    //-y
    else if ( key ==119) {
      if (state == start){
        changeState(game);
      }else if(state == game){
        speedY = -10;  
      }
    }
    // +x
    else if(key == 100) {
      if (state == start){
        changeState(game);
      }else if(state == game){
        speedX = 10;  

      }
    }
    //+y
    else if(key == 115) {
      if (state == start){
        changeState(game);
      }else if(state == game){
        speedY = 10;  
      }
    }
    //restart
    else if(key == 120){
      changeState(start);
    }
    return;
  }


  void startTimeRec(){
    startTime = millis();
  }

  void changeState(int newState){
    state = newState;
    startTimeRec();
    // if(newState == game) {
    //   startTimeRec();
    // }else if(newState == end){
    //   startTimeRec();
    // }
  }

  void updateTime()
  {//60000
    if(millis()-startTime>3000 && state == game){
      changeState(end); 
      //10000
    }else if(millis()-startTime>3000 && state == end){
      changeState(start);
    }
  }

  void drawGrid(PGraphics pg){

    pg.stroke(130);
    pg.strokeWeight(1);

    for(int i = 0; i < bWidth; i = i + gridUnit  )
      pg.line( i, 0, i, bHeight );

    for(int i = 0; i < bHeight; i = i + gridUnit )
      pg.line( 0, i, bWidth, i );

    pg.stroke(255);
    pg.noFill();
    pg.strokeWeight(5);
    pg.rect(0,0,bWidth,bHeight);
  }
