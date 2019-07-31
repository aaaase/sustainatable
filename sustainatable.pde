/////////keyboard WASD controllers X to restart

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;

Minim minim;

AudioPlayer playerStartBG;
AudioPlayer playerGameBG;
AudioPlayer playerEndBg;
AudioPlayer playerStartPressed;
AudioPlayer playerPlayerPoint;
AudioPlayer playerTeamPoint;

int bgColor=0;
int framerate = 24; 
int playerHole = 60;
int teamHole = 40;
int holeMargin = 60;
int ballSize = 30;
int[][] ballInitPosition; 
//int ballInitX = 20;
//int ballInitY = 20;
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

int gWidth=900;
int gHeight=900;
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
PGraphics container;


 void setup() {
size(900,900, P3D);

ks = new Keystone(this);
surface = ks.createCornerPinSurface(900, 900, 20);

gWidth = 900;
gHeight = 900;
bHeight = gHeight-2*pHeight;
bWidth = gWidth-2*pHeight;     
frameRate(framerate);

board = createGraphics(bWidth, bHeight);
pgNorth = createGraphics(gWidth, gHeight);
pgWest = createGraphics(gWidth, gHeight);
pgSouth = createGraphics(gWidth, gHeight);
pgEast = createGraphics(gWidth, gHeight);
font = createFont("OpenSans-ExtraBold.ttf", 42);

container = createGraphics(width, height, P3D);

minim = new Minim(this);

playerStartBG = minim.loadFile("startbg.mp3");
playerGameBG = minim.loadFile("game.mp3");
playerEndBg = minim.loadFile("end.mp3");
playerStartPressed = minim.loadFile("start_pressed.mp3");
playerPlayerPoint = minim.loadFile("point_player.mp3");
playerTeamPoint = minim.loadFile("point_team.mp3");


int[][] ballInitPosition1 = { 
{30,30},
{bWidth-30,30},
{30,bHeight-30},
{bWidth-30,bHeight-30}
};

ballInitPosition = ballInitPosition1;
resetCoord();
}

void draw() {
container.beginDraw();

container.background(bgColor);
if(state == start){
board.beginDraw();
board.background(bgColor);
drawGrid(board);
drawHoles(board, false);
board.endDraw();
container.image(board, pHeight, pHeight);
container.fill(255);
container.textSize(60);
container.rectMode(CENTER);
container.textAlign(CENTER, CENTER);
container.textFont(font);
container.textLeading(42);
//container.rotate(PI/2.0);
container.text("HIT ANY PEDAL TO START", gWidth/2, gHeight/2, bWidth/1.5, bHeight);
}else if(state == game){
drawBoard();
container.image(board, pHeight, pHeight);
drawScorePanels();
container.image(pgEast, 0, 0); 
container.image(pgNorth, 0, 0); 
container.image(pgWest, 0, 0); 
container.image(pgSouth, 0, 0); 
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
container.fill(255);
container.textSize(36);
container.rectMode(CENTER);
container.textAlign(CENTER, CENTER);
container.textFont(font);
container.textLeading(48); 
container.text("TOGETHER IS BETTER", gWidth/2, gHeight/2, bWidth/1.2, bHeight);
updateTime();
}

container.endDraw();
//image(container, 0, 0);
surface.render(container);
}


void drawScorePanels(){

drawPanel(pgNorth, -PI, gWidth/2, pHeight/2, pHeight,pNScore, bgColor);
drawPanel(pgWest, PI/2, pHeight/2, gWidth/2, pHeight,pWScore, bgColor);
drawPanel(pgSouth, 0, gWidth/2, gHeight-pHeight/2, pHeight,pSScore, bgColor);
drawPanel(pgEast, -PI/2, gWidth-pHeight/2, gHeight/2, pHeight,pEScore, bgColor);


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
pg.textFont(font);
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


boolean isScored = false; 

void resetCoord(){
  int[] coord = getInitPosition(); 
x = coord[0];
y = coord[1];
}

void drawScoring(){
isScored = true;
resetCoord();

isScored = false;
//speeding up
speedX+=10;
speedY+=10;
}

int[] getInitPosition(){
   
int index=int(random(0,3));
int[] coordinates = ballInitPosition[index];
return coordinates;
}

void drawBall(PGraphics pg, float x, float y){
pg.stroke(255); //<>//
pg.strokeWeight(5);
pg.fill(255,0,255);
pg.ellipse(x,y, ballSize, ballSize);
//west
if(dist(holeMargin, bHeight/2, x, y)<playerHole/2 && isScored == false){
drawScoring();
pWScore++;
playerPlayerPoint.rewind();
playerPlayerPoint.play();
}else if(dist(bWidth-holeMargin,bHeight/2, x, y)<playerHole/2 && isScored == false){
//east
drawScoring();
pEScore++;
playerPlayerPoint.rewind();
playerPlayerPoint.play();
}else if(dist(bWidth/2,holeMargin, x, y)<playerHole/2 && isScored == false){
//north
drawScoring();
pNScore++;
playerPlayerPoint.rewind();
playerPlayerPoint.play();
}else if(dist(bWidth/2,bHeight-holeMargin, x, y)<playerHole/2 && isScored == false){
//south
drawScoring();
pSScore++;
playerPlayerPoint.rewind();
playerPlayerPoint.play();
}else if(dist(bWidth/2,bHeight/2, x, y)<playerHole/2 && isScored == false){
//center
drawScoring();
pWScore+=4;
pNScore+=4;
pEScore+=4;
pSScore+=4;
playerTeamPoint.rewind();
 playerTeamPoint.play();
}
}

boolean bounceX(float x){
return x>bWidth-ballSize/2 || x<ballSize;
} 


boolean bounceY(float y){
return y>bHeight-ballSize/2 || y<ballSize;
} 


////////////pedals
//void keyPressed() {
//println(key);
////-x
//if (keyCode == 38) {
//if (state == start) {
//changeState(game);
//playerGameBG.play();
//} else if (state == game) {
//speedX = -10;
//}
//}
////-y
//else if ( keyCode ==40) {
//if (state == start) {
//changeState(game);
//playerGameBG.play();
//} else if (state == game) {
//speedY = -10;
//}
//}
//// +x
//else if (keyCode == 39) {
//if (state == start) {
//changeState(game);
//playerGameBG.play();
//} else if (state == game) {
//speedX = 10;
//}
//}
////+y
//else if (keyCode == 37) {
//if (state == start) {
//changeState(game);
//playerGameBG.play();
//} else if (state == game) {
//speedY = 10;
//}
//}
////restart
//else if (keyCode == 120) {
//changeState(start);
//playerStartBG.play();
//}else if(keyCode == 75) {
// // enter/leave calibration mode, where surfaces can be warped
// // and moved
// ks.toggleCalibration();
// }
// else if(keyCode == 76)
// {
// // loads the saved layout
// ks.load();
// }
// else if( keyCode == 74)
// {
// // saves the layout
// ks.save();
// }
//return;
//}


/////////keyboard WASD controllers X to restart
void keyPressed() {
println(key);
//-x
if (key == 97) {
if (state == start) {
changeState(game);
playerGameBG.play();
} else if (state == game) {
speedX = -10;
}
}
//-y
else if ( key ==119) {
if (state == start) {
changeState(game);
playerGameBG.play();
} else if (state == game) {
speedY = -10;
}
}
// +x
else if (key == 100) {
if (state == start) {
changeState(game);
playerGameBG.play();
} else if (state == game) {
speedX = 10;
}
}
//+y
else if (key == 115) {
if (state == start) {
changeState(game);
playerGameBG.play();
} else if (state == game) {
speedY = 10;
}
}
//restart
else if (key == 120) {
changeState(start);
playerGameBG.play();
}else if(key == 75) {
 // enter/leave calibration mode, where surfaces can be warped
 // and moved
 ks.toggleCalibration();
 }
 else if(key == 76)
 {
 // loads the saved layout
 ks.load();
 }
 else if( key == 74)
 {
 // saves the layout
 ks.save();
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
{//60000 for 60 seconds
if(millis()-startTime>30000 && state == game){
changeState(end); 
 if ( playerGameBG.isPlaying() )
{
playerGameBG.pause();
playerEndBg.rewind();
playerEndBg.play();
}


//end screen time
}else if(millis()-startTime>5000 && state == end){
changeState(start);
 pWScore = 0;
pNScore = 0;
pEScore = 0;
 pSScore = 0;
 if ( playerStartBG.isPlaying() )
{
playerStartBG.pause();
playerGameBG.play();
}

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
