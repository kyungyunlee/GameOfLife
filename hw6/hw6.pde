// import ketai.ui.*;
// import ketai.sensors.*;

// KetaiGesture gesture;

Game game;

void setup(){
    size(370,675);
    // gesture = new KetaiGesture(this);
    game = new Game();
}

void draw(){
    background(0);
    game.play();
}


void mousePressed(){
 //selecting cells
}



class Game{
    //originalGrid contains old info
    //updatingGrid is the one that is drawn
    Grid originalGrid, updatingGrid;
    int startTime, currentTime;
    int refreshRate=100;
    int countDays=0;

    Game(){
        startTime = millis();
        originalGrid = new Grid();
        updatingGrid = new Grid();
    }

    void play(){
        currentTime = millis();

        // originalGrid = updatingGrid;

        if(timeToRefresh()){

            //update grid
                // updatingGrid = this.updated();
            countDays++;
        }

        updatingGrid.draw();
        fill(255);
        text("Days : " + countDays, 10, height-10);

    }

    boolean timeToRefresh(){
        if((currentTime-startTime)>refreshRate){
            startTime = currentTime;
            return true;
        }
        return false;
    }

    Grid updated(){
        originalGrid.update();
        return originalGrid;
    }



}


class Grid{
    int width_cellNum = 20;
    float cellSize = width/width_cellNum;
    int height_cellNum = int(height/cellSize);

    Cell [][] cells;

    Grid(){
        cells = new DeadCell[width_cellNum][height_cellNum];
        for (int j=0; j<height_cellNum;j++){
            for(int i=0; i<width_cellNum;i++){
                cells[i][j] = new DeadCell(i*cellSize, j*cellSize, cellSize);
            }
        }
    }
    void update(){

        //the cells that are selected by the user's touch become liveCell
        for (int j=0; j<height_cellNum;j++){
            for(int i=0; i<width_cellNum;i++){
                if (this.isSelected(cells[i][j])){
                    cells[i][j] = new LiveCell(i*cellSize, j*cellSize, cellSize);
                }
            }
        }

        for (int j=0; j<height_cellNum;j++){
            for(int i=0; i<width_cellNum;i++){
                int countLiveCell = 0;

                //first check surrounding cells and count liveCell
                try{
                    for (int a=-1;a<2;a++){
                            for (int b=-1;b<2;b++){
                                if(cells[i+b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }

                }
                //cells that are on the edges throw array index outofrange
                catch(Exception e){
                    //left top corner
                    if (i==0 && j==0){
                        for (int a=0;a<2;a++){
                            for (int b=0;b<2;b++){
                                if(cells[i+b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }
                    }
                    //right top corner
                    else if(i==width_cellNum-1 && j==0){
                        for (int a=0;a<2;a++){
                            for (int b=-1;b<1;b++){
                                if(cells[i+b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }
                    }
                    //left bottom corner
                    else if(i==0 && j==height_cellNum-1){
                        for (int a=-1;a<1;a++){
                            for (int b=0;b<2;b++){
                                if(cells[i+b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }
                    }
                    //right bottom corner
                    else if(i==width_cellNum-1 && j==height_cellNum-1){
                        for (int a=-1;a<1;a++){
                            for (int b=-1;b<1;b++){
                                if(cells[i+b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }
                    }
                    //left most cells
                    else if(i == 0){
                        for (int a=-1;a<2;a++){
                            for (int b=0;b<2;b++){
                                if(cells[i+b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }
                    }
                    //right most cells
                    else if(i==width_cellNum-1){
                        for (int a=-1;a<2;a++){
                            for (int b=-1;b<1;b++){
                                if(cells[i+b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }
                    }
                    //upper most cells
                    else if(j==0){
                        for (int a=0;a<2;a++){
                            for (int b=-1;b<2;b++){
                                if(cells[i+ b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }
                    }
                    //bottom most cells
                    else{
                        for (int a=-1;a<1;a++){
                            for (int b=-1;b<2;b++){
                                if(cells[i+b][j+a] instanceof LiveCell){
                                    countLiveCell++;
                                }
                            }
                        }
                    }
                }

                //check if the cell is liveCell or deadCell
                if (cells[i][j] instanceof LiveCell){
                    countLiveCell -=1; //remove one for liveCell because added self while counting surrounding cells
                    if (countLiveCell<2 || countLiveCell>3){
                        cells[i][j] = new DeadCell(i*cellSize,j*cellSize,cellSize);
                    }
                    else {
                        cells[i][j] = new LiveCell(i*cellSize,j*cellSize,cellSize);
                    }
                }
                else{
                    if (countLiveCell ==3){
                        cells[i][j] = new LiveCell(i*cellSize,j*cellSize,cellSize);
                    }
                    else{
                        cells[i][j] = new DeadCell(i*cellSize,j*cellSize,cellSize);
                    }
                }

            }

        }
    }


    void draw(){

        for (int j=0; j<height_cellNum;j++){
            for(int i=0; i<width_cellNum;i++){
                cells[i][j].draw();
            }
        }


        stroke(255);
        strokeWeight(0.3);
        //horizontal line
        for (int j=0; j<height_cellNum;j++){
            line(0,j*cellSize,width,j*cellSize);
        }
        //vertical line
        for(int i=0; i<width_cellNum;i++){
            line(i*cellSize,0,i*cellSize,height);
        }
    }

//true when the user selects the cell????
    boolean isSelected(Cell c){
        if (mouseX>c.x && mouseX<c.x+cellSize && mouseY>c.y && mouseY<c.y+cellSize){
            return true;
        }
        return false;
    }

}

abstract class Cell{
    float x,y;
    float cellSize;

    Cell(float x, float y, float cellSize){
        this.x=x;
        this.y=y;
        this.cellSize= cellSize;
    }
    abstract void draw();

}


class LiveCell extends Cell{
    boolean isAlive;

    LiveCell(float x, float y, float cellSize){
        super(x,y,cellSize);
        isAlive = true;
    }

    void draw(){
        fill(0,255,0);
        noStroke();
        rect(super.x,super.y,super.cellSize,super.cellSize);
    }

}

class DeadCell extends Cell{
    boolean isAlive;

    DeadCell(float x, float y, float cellSize){
        super(x,y,cellSize);
        isAlive = false;
    }
    void draw(){
        fill(0);
        noStroke();
        rect(super.x,super.y,super.cellSize,super.cellSize);
    }

}