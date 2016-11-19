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
    Cell [][] cells;

    Grid(){

    }
    void draw(){

    }
}

class Cell{
    int x,y;
    float cellSize;


    Cell(int x, int y, float cellSize){
        this.x=x;
        this.y=y;
        this.cellSize= cellSize;

    }
    void draw(){
        fill(0);
        rect(this.x,this.y,this.cellSize,this.cellSize);
    }

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