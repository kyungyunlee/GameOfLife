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
    int height_cellNum = height/cellSize;

    Cell [][] cells;

    Grid(){
        for (int j=0; j<height_cellNum;j++){
            for(int i=0; i<width_cellNum;i++){
                cells[i][j] = new Cell(i*cellSize, j*cellSize, cellSize);
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
    int x,y;
    float cellSize;
    LiveCell(int x, int y, float cellSize){
        super(x,y,cellSize);
    }

    void draw(){
        fill(0);
        rect(this.x,this.y,this.cellSize,this.cellSize);
    }

}

class DeadCell extends Cell{
    int x,y;
    float cellSize;
    boolean isAlive =false;

    DeadCell(int x, int y, float cellSize){
        super(x,y,cellSize);
    }
    void draw(){
        fill(0,255,0);
        rect(this.x,this.y,this.cellSize,this.cellSize);
    }

}