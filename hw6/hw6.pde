Game game;

void setup(){
    game = new Game();
}

void draw(){
    game.play();
}



class Game{
    Game(){

    }

    void play(){

    }
}


class Grid{
    Grid(){

    }
    void draw(){

    }
}

class Cell{
    Cell(int x, int y, float cellSize){

    }
    void update(){} //check live or dead
    void draw(){}
    boolean isAlive(){}

}


class LiveCell extends Cell{
    LiveCell(int x, int y, float cellSize){
        super(x,y,cellSize);
    }


}


class DeadCell extends Cell{
    DeadCell(int x, int y, float cellSize){
        super(x,y,cellSize);
    }
}