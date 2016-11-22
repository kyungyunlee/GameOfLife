import ketai.ui.*;
import ketai.sensors.*;
import android.view.MotionEvent;

KetaiGesture gesture;

int TouchEvents;
float xTouch[];
float yTouch[];
int currentPointerId=0;

enum Mode
{
  EDIT, START
};

Game game;

void setup() {
  fullScreen();
  gesture = new KetaiGesture(this);
  game = new Game();

  xTouch = new float[10];
  yTouch = new float[10];
}

void draw() {
  background(0);
  game.play();
}

void onPinch(float x, float y, float d)
{  //println("pinched");
  float cellSize = 0;
  if(d>10){ cellSize = map(d,0,width, game.originalGrid.cellSize, game.originalGrid.cellSize*2);}
  else if (d<=-10) { cellSize = map(d,-width,0, 0, game.originalGrid.cellSize);}
  game.zoomInOut(cellSize);

}
// void onDoubleTap(float x, float y){
//     if(game.mode == Mode.EDIT){
//         for (int i=0; i<game.originalGrid.width_cellNum-1; i++) {
//               for (int j=0; j<game.originalGrid.height_cellNum-1; j++) {
//                 if (game.originalGrid.cells[i][j].isSelected(mouseX, mouseY)) {
//                       float cellSize = game.originalGrid.cells[i][j].cellSize;
//                         game.originalGrid.cells[i][j] = new CancerCell(i*cellSize, j*cellSize, cellSize);
//                         game.originalGrid.cells[i+1][j] = new CancerCell((i+1)*cellSize, j*cellSize, cellSize);
//                     }
//                 }}
//     }
// }

void onTap(float x, float y){
  if (game.mode == Mode.EDIT) {
    for (int i=0; i<game.originalGrid.width_cellNum; i++) {
      for (int j=0; j<game.originalGrid.height_cellNum; j++) {
        if (game.originalGrid.cells[i][j].isSelected(mouseX, mouseY)) {
          float cellSize = game.originalGrid.cells[i][j].cellSize;
          if (!game.originalGrid.cells[i][j].isAlive()) {
            game.originalGrid.cells[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize);
          } else {
            game.originalGrid.cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
          }
        }
      }
    }
  }
}

void keyPressed() {
  switch (key)
  {
    case 'e' :
      if (game.mode == Mode.EDIT) game.mode = Mode.START;
      else if (game.mode == Mode.START) game.mode = Mode.EDIT;
  }
}

class Game {
  //originalGrid contains old info
  //updatingGrid is the one that is drawn
  Grid originalGrid, updatingGrid;
  int startTime, currentTime;
  int refreshRate;
  int countDays;
  Mode mode;

  Game() {
    startTime = millis();
    originalGrid = new Grid(80);
    updatingGrid = new Grid(80);
    countDays = 0;
    refreshRate = 100;
    mode = Mode.EDIT;
  }



  void play() {
    if (mode == Mode.EDIT) {
      currentTime = 0;
      originalGrid.draw(mode);
    } else {
      currentTime = millis();
      originalGrid.draw(mode);
      if (timeToRefresh()) {
        countDays++;
        updatingGrid = new Grid(originalGrid);
        updatingGrid.update();
        originalGrid = new Grid(updatingGrid);
      }
    }
    fill(255);
    text("Days : " + countDays, 10, height-10);
  }

  void zoomInOut(float cellSize){
      originalGrid = new Grid(cellSize);
    }

  boolean timeToRefresh() {
    if ((currentTime-startTime)>refreshRate) {
      startTime = currentTime;
      return true;
    }
    return false;
  }
}


class Grid {
  float cellSize;
  int width_cellNum;
  int height_cellNum;

  Cell [][] cells;

  Grid(float cellSize) {
    this.cellSize = cellSize;
    width_cellNum = int(width/cellSize);
    height_cellNum = int(height/cellSize);

    cells = new Cell[width_cellNum][height_cellNum];
    for (int i=0; i<width_cellNum; i++) {
      for (int j=0; j<height_cellNum; j++) {
        cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
      }
    }
  }

  Grid(Grid other) {
    cellSize = other.cellSize;
    width_cellNum = other.width_cellNum;
    height_cellNum = other.height_cellNum;

    cells = new Cell[width_cellNum][height_cellNum];
    for (int i=0; i<width_cellNum; i++) {
      for (int j=0; j<height_cellNum; j++) {
        if (other.cells[i][j].isAlive) {
          cells[i][j] = new LiveCell((LiveCell)other.cells[i][j]);
        } else {
          cells[i][j] = new DeadCell((DeadCell)other.cells[i][j]);
        }
      }
    }
  }

  void update() {
    for (int i=0; i<width_cellNum; i++) {
      for (int j=0; j<height_cellNum; j++) {
        int countLiveCell = 0;

        //first check surrounding cells and count liveCell
        try {
          for (int a=-1; a<2; a++) {
            for (int b=-1; b<2; b++) {
              if (cells[i+a][j+b].isAlive()) {
                countLiveCell++;
                println("count "+i+" "+j+"&"+i+a+" "+j+b);
              }
            }
          }
        }
        //cells that are on the edges throw array index outofrange
        catch(Exception e) {
          //left top corner
          if (i==0 && j==0) {
            for (int a=0; a<2; a++) {
              for (int b=0; b<2; b++) {
                if (cells[i+a][j+b].isAlive()) {
                  countLiveCell++;
                  println("count "+i+" "+j+"&"+i+a+" "+j+b);
                }
              }
            }
          }
          //right top corner
          else if (i==width_cellNum-1 && j==0) {
            for (int a=-1; a<1; a++) {
              for (int b=0; b<2; b++) {
                if (cells[i+a][j+b].isAlive()) {
                  countLiveCell++;
                  println("count "+i+" "+j+"&"+i+a+" "+j+b);
                }
              }
            }
          }
          //left bottom corner
          else if (i==0 && j==height_cellNum-1) {
            for (int a=0; a<2; a++) {
              for (int b=-1; b<0; b++) {
                if (cells[i+a][j+b].isAlive()) {
                  countLiveCell++;
                  println("count "+i+" "+j+"&"+i+a+" "+j+b);
                }
              }
            }
          }
          //right bottom corner
          else if (i==width_cellNum-1 && j==height_cellNum-1) {
            for (int a=-1; a<1; a++) {
              for (int b=-1; b<1; b++) {
                if (cells[i+a][j+b].isAlive()) {
                  countLiveCell++;
                  println("count "+i+" "+j+"&"+i+a+" "+j+b);
                }
              }
            }
          }
          //left most cells
          else if (i == 0) {
            for (int a=0; a<2; a++) {
              for (int b=-1; b<2; b++) {
                if (cells[i+a][j+b].isAlive()) {
                  countLiveCell++;
                  println("count "+i+" "+j+"&"+i+a+" "+j+b);
                }
              }
            }
          }
          //right most cells
          else if (i==width_cellNum-1) {
            for (int a=-1; a<1; a++) {
              for (int b=-1; b<2; b++) {
                if (cells[i+a][j+b].isAlive()) {
                  countLiveCell++;
                  println("count "+i+" "+j+"&"+i+a+" "+j+b);
                }
              }
            }
          }
          //upper most cells
          else if (j==0) {
            for (int a=-1; a<2; a++) {
              for (int b=0; b<2; b++) {
                if (cells[i+ a][j+b].isAlive()) {
                  countLiveCell++;
                  println("count "+i+" "+j+"&"+i+a+" "+j+b);
                }
              }
            }
          }
          //bottom most cells
          else {
            for (int a=-1; a<2; a++) {
              for (int b=-1; b<1; b++) {
                if (cells[i+a][j+b].isAlive()) {
                  countLiveCell++;
                  println("count "+i+" "+j+"&"+i+a+" "+j+b);
                }
              }
            }
          }
        }
        cells[i][j].liveNeighbor = countLiveCell;
      }
    }

    for (int i=0; i<width_cellNum; i++) {
      for (int j=0; j<height_cellNum; j++) {
    //check if the cell is liveCell or deadCell

        if (cells[i][j].isAlive()) {
          cells[i][j].liveNeighbor -=1; //remove one for liveCell because added self while counting surrounding cells
          println(cells[i][j].liveNeighbor);
          if (cells[i][j].liveNeighbor<2 || cells[i][j].liveNeighbor>3) {
            cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
          } else {
            cells[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize);
          }
        } else {
          if (cells[i][j].liveNeighbor ==3) {
            cells[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize);
          } else {
            cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
          }
        }
      }
    }
  }


  void draw(Mode mode) {

    for (int j=0; j<height_cellNum; j++) {
      for (int i=0; i<width_cellNum; i++) {
        cells[i][j].draw();
      }
    }

    if (mode == Mode.EDIT) {
      stroke(255);
      strokeWeight(0.3);
      //horizontal line
      for (int j=0; j<height_cellNum; j++) {
        line(0, j*cellSize, width, j*cellSize);
      }
      //vertical line
      for (int i=0; i<width_cellNum; i++) {
        line(i*cellSize, 0, i*cellSize, height);
      }
    }
  }
}

abstract class Cell {
  float x, y;
  float cellSize;
  boolean isAlive;
  int liveNeighbor;

  Cell(float x, float y, float cellSize) {
    this.x=x;
    this.y=y;
    this.cellSize= cellSize;
    liveNeighbor = 0;
  }

  Cell (Cell other) {
    x=other.x;
    y=other.y;
    cellSize= other.cellSize;
    isAlive=other.isAlive;
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

  abstract void draw();
}


class LiveCell extends Cell {

  LiveCell(float x, float y, float cellSize) {
    super(x, y, cellSize);
    super.isAlive = true;
  }

  LiveCell(LiveCell other) {
    super(other);
  }

  void draw() {
    fill(0, 255, 0);
    noStroke();
    rect(super.x, super.y, super.cellSize, super.cellSize);
  }
}

class DeadCell extends Cell {

  DeadCell(float x, float y, float cellSize) {
    super(x, y, cellSize);
    super.isAlive = false;
  }

  DeadCell(DeadCell other) {
    super(other);
  }

  void draw() {
    fill(0);
    noStroke();
    rect(super.x, super.y, super.cellSize, super.cellSize);
  }
}




// public boolean surfaceTouchEvent(MotionEvent event) {
//   //Call this to keep mouseX and mouseY updated
//   super.surfaceTouchEvent(event);

//   //Forward the event to the class for processing
//   return gesture.surfaceTouchEvent(event);
// }


public boolean surfaceTouchEvent(MotionEvent event){
    // if (true){
        super.surfaceTouchEvent(event);

    // }


    // TouchEvents = event.getPointerCount();
    // for (int i=0; i<TouchEvents;i++){
    //     int pointerId = event.getPointerId(i);
    //     xTouch[pointerId] = event.getX(i);
    //     yTouch[pointerId] = event.getY(i);
    //     float siz = event.getSize(i);
    // }

    if(event.getActionMasked() == 5 && event.getActionIndex()==4){
        print("Secondary pointer detected: ACTION_POINTER_DOWN");
        print("Action index: " +str(event.getActionIndex()));
        if (game.mode == Mode.EDIT ) {
            game.mode = Mode.START;
        }
        else if (game.mode == Mode.START){
            game.mode = Mode.EDIT;
        }
        // return true;
        return super.surfaceTouchEvent(event);
    }



    // else{

    // }

    return gesture.surfaceTouchEvent(event);


}


