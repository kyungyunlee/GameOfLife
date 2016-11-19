Game game;

void setup(){
    size(320,540);
    //fullsize();
    game = new Game();
}

void draw(){
    background(0);
    game.play();
}



class Game{
    Grid originalGrid, updatingGrid;

    Game(){
        originalGrid = new Grid();
        updatingGrid = new Grid();
    }

    void play(){
    }
}


class Grid{
    int width_cellNum = 20;
    float cellSize = width/width_cellNum;
    int height_cellNum = int(height/cellSize);

    Cell [][] cells;

    Grid(){
        for (int j=0; j<height_cellNum;j++){
            for(int i=0; i<width_cellNum;i++){
                cells[i][j] = new DeadCell(i, j, cellSize);
            }
        }
    }
    void draw(){
        for (int j=0; j<height_cellNum;j++){
            for(int i=0; i<width_cellNum;i++){
                cells[i][j].draw();
            }
        }
    }

    void checkAlive(){

    }
}

abstract class Cell{
    int x,y;
    float cellSize;

    Cell(int x, int y, float cellSize){
        this.x=x;
        this.y=y;
        this.cellSize= cellSize;
    }
    abstract void draw();

}


class LiveCell extends Cell{
    boolean isAlive;
    
    LiveCell(int x, int y, float cellSize){
        super(x,y,cellSize);
        isAlive = true;
    }

    void draw(){
        fill(0);
        rect(super.x*super.cellSize,super.y*super.cellSize,super.cellSize,super.cellSize);
    }

}

class DeadCell extends Cell{
    boolean isAlive;

    DeadCell(int x, int y, float cellSize){
        super(x,y,cellSize);
        isAlive = false;
    }
    void draw(){
        fill(0,255,0);
        rect(super.x*super.cellSize,super.y*super.cellSize,super.cellSize,super.cellSize);
    }

}