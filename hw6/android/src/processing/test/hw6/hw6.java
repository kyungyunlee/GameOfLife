package processing.test.hw6;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ketai.ui.*; 
import ketai.sensors.*; 
import android.view.MotionEvent; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class hw6 extends PApplet {





KetaiGesture gesture;
KetaiSensor sensor;

int touch_i;
int touch_j;
int cellColor;

long lastTime;
long currentTime;
long gabOfTime;
float lastX;
float lastY;
float lastZ;
static final int SHAKE_THRESHOLD = 3000;

boolean mousedragged =true;

enum Mode
{
  FIRST, EDIT, START
};

Game game;

public void setup() {
  
  game = new Game();
  gesture = new KetaiGesture(this);
  sensor = new KetaiSensor(this);
  sensor.start();

  touch_i =-1;
  touch_j =-1;
}

public void draw() {
  background(0);
  game.play();
}

public void onPinch(float x, float y, float d)
{  
  float cellSize = 0;
  if (d>10) { 
    cellSize = map(d, 0, width, game.getOriginalGrid().getCellSize(), game.getOriginalGrid().getCellSize()*2);
    game.zoomInOut(cellSize);
  } else if (d<=-10) { 
    cellSize = map(d, -width, 0, 0, game.getOriginalGrid().getCellSize());
    game.zoomInOut(cellSize);
  }
}

class Game {
  //originalGrid contains old info
  //updatingGrid is the one that is drawn
  protected Grid originalGrid, updatingGrid;
  protected int startTime, currentTime;
  protected int refreshRate;
  protected int countDays;
  protected Mode mode;

  Game() {
    startTime = millis();
    originalGrid = new Grid(80);
    updatingGrid = new Grid(80);
    countDays = 0;
    refreshRate = 100;
    mode = Mode.FIRST;
  }

  public void play() {
    if (mode == Mode.EDIT) {
      currentTime = 0;
      originalGrid.draw(mode);
    } else if (mode == Mode.START) {
      currentTime = millis();
      originalGrid.draw(mode);
      if (timeToRefresh()) {
        countDays++;
        updatingGrid = new Grid(originalGrid);
        updatingGrid.update();
        originalGrid = new Grid(updatingGrid);
      }
    } else {
      currentTime = 0;
      originalGrid.draw(mode);
    }
    fill(255);
    textSize(40);
    text("Days : " + countDays, 10, height-10);
  }

  public void zoomInOut(float cellSize) {
    countDays = 0;
    originalGrid = new Grid(cellSize);
  }

  public void reset() {
    countDays = 0;
    originalGrid = new Grid(originalGrid.getCellSize());
  }

  public boolean timeToRefresh() {
    if ((currentTime-startTime)>refreshRate) {
      startTime = currentTime;
      return true;
    }
    return false;
  }
  
  public Grid getOriginalGrid() {
    return originalGrid;
  }
  
  public Mode getMode() {
    return mode;
  }
  
  public void setMode(Mode mode) {
    this.mode = mode;
  }
}


class Grid {
  protected float cellSize;
  protected int widthCellNum;
  protected int heightCellNum;

  protected Cell [][] cells;

  Grid(float cellSize) {
    this.cellSize = cellSize;
    widthCellNum = PApplet.parseInt(width/cellSize);
    heightCellNum = PApplet.parseInt(height/cellSize);

    cells = new Cell[widthCellNum][heightCellNum];
    for (int i=0; i<widthCellNum; i++) {
      for (int j=0; j<heightCellNum; j++) {
        cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
      }
    }
  }

  Grid(Grid other) {
    cellSize = other.cellSize;
    widthCellNum = other.widthCellNum;
    heightCellNum = other.heightCellNum;

    cells = new Cell[widthCellNum][heightCellNum];
    for (int i=0; i<widthCellNum; i++) {
      for (int j=0; j<heightCellNum; j++) {
        if (other.cells[i][j].isAlive) {
          cells[i][j] = new LiveCell((LiveCell)other.cells[i][j]);
        } else {
          cells[i][j] = new DeadCell((DeadCell)other.cells[i][j]);
        }
      }
    }
  }

  public void update() {
    for (int i=0; i<widthCellNum; i++) {
      for (int j=0; j<heightCellNum; j++) {
        int countLiveCell = 0;
        int col = cells[i][j].getColor();
        //first check surrounding cells and count liveCell
        try {
          countLiveCell = updateCountLiveCell(i, j, -1, 2, -1, 2, countLiveCell);
          col = updateCol(i, j, -1, 2, -1, 2, col);
        }
        //cells that are on the edges throw array index outofrange
        catch(Exception e) {
          //left top corner
          if (i==0 && j==0) {
            countLiveCell = updateCountLiveCell(i, j, 0, 2, 0, 2, countLiveCell);
            col = updateCol(i, j, 0, 2, 0, 2, col);
          }
          //right top corner
          else if (i==widthCellNum-1 && j==0) {
            countLiveCell = updateCountLiveCell(i, j, -1, 1, 0, 2, countLiveCell);
            col = updateCol(i, j, -1, 1, 0, 2, col);
          }
          //left bottom corner
          else if (i==0 && j==heightCellNum-1) {
            countLiveCell = updateCountLiveCell(i, j, 0, 2, -1, 0, countLiveCell);
            col = updateCountLiveCell(i, j, 0, 2, -1, 0, col);
          }
          //right bottom corner
          else if (i==widthCellNum-1 && j==heightCellNum-1) {
            countLiveCell = updateCountLiveCell(i, j, -1, 1, -1, 1, countLiveCell);
            col = updateCol(i, j, -1, 1, -1, 1, col);
          }
          //left most cells
          else if (i == 0 && j!= 0) {
            countLiveCell = updateCountLiveCell(i, j, 0, 2, -1, 2, countLiveCell);
            col = updateCol(i, j, 0, 2, -1, 2, col);
          }
          //right most cells
          else if (i==widthCellNum-1) {
            countLiveCell = updateCountLiveCell(i, j, -1, 1, -1, 2, countLiveCell);
            col = updateCol(i, j, -1, 1, -1, 2, col);
          }
          //upper most cells
          else if (j==0) {
            countLiveCell = updateCountLiveCell(i, j, -1, 2, 0, 2, countLiveCell);
            col = updateCol(i, j, -1, 2, 0, 2, col);
          }
          //bottom most cells
          else {
            countLiveCell = updateCountLiveCell(i, j, -1, 2, -1, 1, countLiveCell);
            col = updateCol(i, j, -1, 2, -1, 1, col);
          }
        }
        cells[i][j].setLiveNeighbor(countLiveCell);
        cells[i][j].setNextColor(col);
      }
    }

    for (int i=0; i<widthCellNum; i++) {
      for (int j=0; j<heightCellNum; j++) {
        //check if the cell is liveCell or deadCell

        if (cells[i][j].isAlive()) {
          cells[i][j].setLiveNeighbor(cells[i][j].getLiveNeighbor()-1); //remove one for liveCell because added self while counting surrounding cells
          if (cells[i][j].getLiveNeighbor()<2 || cells[i][j].getLiveNeighbor()>3) {
            cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
          } else {
            int col = cells[i][j].getNextColor();
            cells[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize, col);
          }
        } else {
          if (cells[i][j].getLiveNeighbor() ==3) {
            int col = cells[i][j].getNextColor();
            cells[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize, col);
          } else {
            cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
          }
        }
      }
    }
  }

  public int updateCountLiveCell(int i, int j, int a1, int a2, int b1, int b2, int countLiveCell) {
    for (int a=a1; a<a2; a++) {
      for (int b=b1; b<b2; b++) {
        if (cells[i+a][j+b].isAlive()) {
          countLiveCell++;
        }
      }
    }
    return countLiveCell;
  }
  
   public int updateCol(int i, int j, int a1, int a2, int b1, int b2, int col) {
    for (int a=a1; a<a2; a++) {
      for (int b=b1; b<b2; b++) {
        if (cells[i+a][j+b].isAlive()) {
          if (cells[i][j].isAlive()) {
            col = color((red(col)+red(cells[i+a][j+b].getColor()))/2, (green(col)+green(cells[i+a][j+b].getColor()))/2, (blue(col)+blue(cells[i+a][j+b].getColor()))/2);
          } else {
            if (red(col)+green(col)+blue(col) == 0) {
              col = cells[i+a][j+b].getColor();
            } else {
              col = color((red(col)+red(cells[i+a][j+b].getColor()))/2, (green(col)+green(cells[i+a][j+b].getColor()))/2, (blue(col)+blue(cells[i+a][j+b].getColor()))/2);
            }
          }
        }
      }
    }
    return col;
  }

  public void draw(Mode mode) {

    for (int j=0; j<heightCellNum; j++) {
      for (int i=0; i<widthCellNum; i++) {
        cells[i][j].draw();
      }
    }

    if (mode == Mode.EDIT) {
      stroke(255);
      strokeWeight(0.3f);
      //horizontal line
      for (int j=0; j<heightCellNum+1; j++) {
        line(0, j*cellSize, width, j*cellSize);
      }
      //vertical line
      for (int i=0; i<widthCellNum+1; i++) {
        line(i*cellSize, 0, i*cellSize, height);
      }
    }
  }
  
  public float getCellSize() {
    return cellSize;
  }
  
  public int getWidthCellNum(){
    return widthCellNum;
  }
  
  public int getHeightCellNum() {
    return heightCellNum;
  }
  
  public Cell[][] getCells() {
    return cells;
  }
  
}

abstract class Cell {
  protected float x, y;
  protected float cellSize;
  protected boolean isAlive;
  protected int liveNeighbor;
  protected int nextCol;
  protected int col;

  Cell(float x, float y, float cellSize, int col) {
    this.x=x;
    this.y=y;
    this.cellSize= cellSize;
    liveNeighbor = 0;
    this.col = col;
    this.nextCol = color(0);
  }

  Cell (Cell other) {
    x=other.x;
    y=other.y;
    cellSize= other.cellSize;
    isAlive=other.isAlive;
    col = other.col;
    nextCol = other.nextCol;
  }

  public boolean isAlive() {
    return isAlive;
  }

  //true when the user selects the cell????
  public boolean isSelected(int mx, int my) {
    if (mx>x && mx<x+cellSize && my>y && my<y+cellSize) {
      return true;
    }
    return false;
  }

  public int getColor() {
    return col;
  }

  public int getNextColor() {
    return nextCol;
  }

  public int getLiveNeighbor() {
    return liveNeighbor;
  }

  public float getCellSize() {
    return cellSize;
  }

  public void setColor(int col) {
    this.col = col;
  }

  public void setNextColor(int nextCol) {
    this.nextCol = nextCol;
  }

  public void setLiveNeighbor(int liveNeighbor) {
    this.liveNeighbor = liveNeighbor;
  }

  public void setCellSize(float cellSize) {
    this.cellSize = cellSize;
  }

  public abstract void draw();
}


class LiveCell extends Cell {

  LiveCell(float x, float y, float cellSize, int col) {
    super(x, y, cellSize, col);
    super.isAlive = true;
  }

  LiveCell(LiveCell other) {
    super(other);
  }

  public void draw() {
    //ranCol = color(random(0, 255), random(0, 255), random(0, 255));
    fill(super.col);
    noStroke();
    rect(super.x, super.y, super.cellSize, super.cellSize);
  }
}

class DeadCell extends Cell {

  DeadCell(float x, float y, float cellSize) {
    super(x, y, cellSize, color(0, 0, 0));
    super.isAlive = false;
  }

  DeadCell(DeadCell other) {
    super(other);
  }

  public void draw() {
    fill(super.col);
    noStroke();
    rect(super.x, super.y, super.cellSize, super.cellSize);
  }
}


public boolean surfaceTouchEvent(MotionEvent event) {

  if (event.getActionMasked() == 5 && event.getActionIndex()==4) {
    if (game.getMode() == Mode.EDIT ) {
      game.setMode(Mode.START);
    } else if (game.getMode() == Mode.START) {
      game.setMode(Mode.EDIT);
    } else {
      game.setMode(Mode.EDIT);
    }
    delay(100);
    return super.surfaceTouchEvent(event);
  }
  if (event.getActionMasked() == 5 && event.getActionIndex() ==1) {
    mousedragged = false;
  } 
  if (event.getActionMasked() == 6) {
    delay(100);
    mousedragged = true;
  } 

  super.surfaceTouchEvent(event);
  return gesture.surfaceTouchEvent(event);
}

public void mousePressed() {
  cellColor = color(random(0, 255), random(0, 255), random(0, 255));
}

public void mouseDragged() {
  if (!mousedragged) return;
  if (game.getMode() == Mode.EDIT) {
    for (int i=0; i<game.getOriginalGrid().getWidthCellNum(); i++) {
      for (int j=0; j<game.getOriginalGrid().getHeightCellNum(); j++) {
        if (game.getOriginalGrid().cells[i][j].isSelected(mouseX, mouseY)) {
          if (touch_i != i || touch_j != j) {
            float cellSize = game.getOriginalGrid().cells[i][j].getCellSize();
            if (!game.getOriginalGrid().getCells()[i][j].isAlive()) {
              game.getOriginalGrid().getCells()[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize, cellColor);
              touch_i = i;
              touch_j = j;
              break;
            } else {
              game.getOriginalGrid().getCells()[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
              touch_i = i;
              touch_j = j;
              break;
            }
          } else {
            break;
          }
        }
      }
    }
  }
}

public void onAccelerometerEvent(float x, float y, float z)
{
  long currentTime = System.currentTimeMillis();
  long gabOfTime = (currentTime - lastTime);
  if (gabOfTime > 100) {
    lastTime = currentTime;

    float speed = Math.abs(x + y + z - lastX - lastY - lastZ) / gabOfTime * 10000;

    if (speed > SHAKE_THRESHOLD) {
      game.reset();
    }

    lastX = x;
    lastY = y;
    lastZ = z;
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "hw6" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
