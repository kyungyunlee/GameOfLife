import ketai.ui.*;
import ketai.sensors.*;
import android.view.MotionEvent;

KetaiGesture gesture;
KetaiSensor sensor;

int touch_i;
int touch_j;
color cellColor;

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

void setup() {
  fullScreen();
  game = new Game();
  gesture = new KetaiGesture(this);
  sensor = new KetaiSensor(this);
  sensor.start();

  touch_i =-1;
  touch_j =-1;
}

void draw() {
  background(0);
  game.play();
}

void onPinch(float x, float y, float d)
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

  void play() {
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

  void zoomInOut(float cellSize) {
    countDays = 0;
    originalGrid = new Grid(cellSize);
  }

  void reset() {
    countDays = 0;
    originalGrid = new Grid(originalGrid.getCellSize());
  }

  boolean timeToRefresh() {
    if ((currentTime-startTime)>refreshRate) {
      startTime = currentTime;
      return true;
    }
    return false;
  }
  
  Grid getOriginalGrid() {
    return originalGrid;
  }
  
  Mode getMode() {
    return mode;
  }
  
  void setMode(Mode mode) {
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
    widthCellNum = int(width/cellSize);
    heightCellNum = int(height/cellSize);

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

  void update() {
    for (int i=0; i<widthCellNum; i++) {
      for (int j=0; j<heightCellNum; j++) {
        int countLiveCell = 0;
        color col = cells[i][j].getColor();
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
            color col = cells[i][j].getNextColor();
            cells[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize, col);
          }
        } else {
          if (cells[i][j].getLiveNeighbor() ==3) {
            color col = cells[i][j].getNextColor();
            cells[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize, col);
          } else {
            cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
          }
        }
      }
    }
  }

  int updateCountLiveCell(int i, int j, int a1, int a2, int b1, int b2, int countLiveCell) {
    for (int a=a1; a<a2; a++) {
      for (int b=b1; b<b2; b++) {
        if (cells[i+a][j+b].isAlive()) {
          countLiveCell++;
        }
      }
    }
    return countLiveCell;
  }
  
   color updateCol(int i, int j, int a1, int a2, int b1, int b2, color col) {
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

  void draw(Mode mode) {

    for (int j=0; j<heightCellNum; j++) {
      for (int i=0; i<widthCellNum; i++) {
        cells[i][j].draw();
      }
    }

    if (mode == Mode.EDIT) {
      stroke(255);
      strokeWeight(0.3);
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
  
  float getCellSize() {
    return cellSize;
  }
  
  int getWidthCellNum(){
    return widthCellNum;
  }
  
  int getHeightCellNum() {
    return heightCellNum;
  }
  
  Cell[][] getCells() {
    return cells;
  }
  
}

abstract class Cell {
  protected float x, y;
  protected float cellSize;
  protected boolean isAlive;
  protected int liveNeighbor;
  protected color nextCol;
  protected color col;

  Cell(float x, float y, float cellSize, color col) {
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

  boolean isAlive() {
    return isAlive;
  }

  //true when the user selects the cell????
  boolean isSelected(int mx, int my) {
    if (mx>x && mx<x+cellSize && my>y && my<y+cellSize) {
      return true;
    }
    return false;
  }

  color getColor() {
    return col;
  }

  color getNextColor() {
    return nextCol;
  }

  int getLiveNeighbor() {
    return liveNeighbor;
  }

  float getCellSize() {
    return cellSize;
  }

  void setColor(color col) {
    this.col = col;
  }

  void setNextColor(color nextCol) {
    this.nextCol = nextCol;
  }

  void setLiveNeighbor(int liveNeighbor) {
    this.liveNeighbor = liveNeighbor;
  }

  void setCellSize(float cellSize) {
    this.cellSize = cellSize;
  }

  abstract void draw();
}


class LiveCell extends Cell {

  LiveCell(float x, float y, float cellSize, color col) {
    super(x, y, cellSize, col);
    super.isAlive = true;
  }

  LiveCell(LiveCell other) {
    super(other);
  }

  void draw() {
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

  void draw() {
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

void mousePressed() {
  cellColor = color(random(0, 255), random(0, 255), random(0, 255));
}

void mouseDragged() {
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

void onAccelerometerEvent(float x, float y, float z)
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