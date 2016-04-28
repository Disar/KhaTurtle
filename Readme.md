# Kha Turtle

A simple implementation of turtle for Kha.

Lines and images are not drawn directly. Instead they are stored in a buffer first and then flushed once the render function is called. 
The lines and images aren't redrawn, instead the buffer isn't cleared until you tell it to.

### Initializing

    var walker:Turtle;

    public function new()
    {
        //Set's origin position at [20,500].
        //Creates an additional buffer to draw to.
        walker = new Turtle(20, 500, Image.createRenderTarget(800, 600));
    }
    
### Rendering

    public override function render(buffer:Image){

        buffer.g2.end(); // End the current buffer

        walker.start();  // prepair the buffer
        walker.render(); // render intermediate steps
        walker.end();    // done rendering

        buffer.g2.begin(false); //Continue previous buffer without clearing
        buffer.g2.drawImage(walker.buffer, 0, 0); // draw the drawn image to the buffer

    }
    
### Properties & functions

    penUp()          //Allows you to jump to a position without drawing a line.
    penDown()        //Allows lines and images to be drawn.
    turnLeft()       //Turns the heading -90 degrees.
    turnRight()      //Turns the heading +90 degrees.
    turn(degrees)    //Turns the heading with the given amount.
    forward(pixels)  //Draws a line of pixels given in the current heading.
    backwards(pixels)//Similar to forward just in the opposite direction.
    jumpTo(x,y)      //Moves to the specified position
    
    pushTrianglePoint()//Adds the current position as a triangle point.
                       //If 3 points are pushed a triangle is drawn 

    // Draws an image at the current position and heading.
    dropImage(image, scale, apply heading, offset)

    start()      //Prepares the buffer.
    clearBuffer()//Clears the buffer before drawing.
    end()        //Declares this buffer is done drawing.
    render()     //Draws the line and image buffer.
    reset()      //Places the drawing point back to its initial point.

    heading   //Directly adjust the heading
    color     //Color of the current line.
    triangleColor     //Color of the current line.
    thickness //The thickness of the current line.
    buffer    //The buffer to draw too.
    drawLines //Whether image should be drawn only.
   
### Example

    public function new()
    {
        //Set's origin position at [20,500].
        //Creates an additional buffer to draw to.
        walker = new Turtle(20, 500, Image.createRenderTarget(800, 600));
        kochSegment(20);
    }

    function kochSegment(stepSize:Int): Void{

        walker.forward(stepSize); // Move n amount in current direction
        walker.turnLeft();        // Turn left from current ortientation

        walker.forward(stepSize); 
        walker.turnRight();       // Turn right from current orientation

        walker.forward(stepSize);
        walker.turnRight();

        walker.forward(stepSize);
        walker.turnLeft();

        walker.forward(stepSize);   
    }
    
    public override function render(buffer:Image){

        buffer.g2.end(); // End the current buffer

        walker.start();  // prepair the buffer
        walker.render(); // render intermediate steps
        walker.end();    // done rendering

        buffer.g2.begin(false); //Continue previous buffer without clearing
        buffer.g2.drawImage(walker.buffer, 0, 0); // draw the drawn image to the buffer

    }