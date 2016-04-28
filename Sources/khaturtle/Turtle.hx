package khaturtle;

import kha.Color;
import kha.math.Vector2;
import kha.Image;
import haxe.ds.GenericStack;
import kha.FastFloat;

class Turtle{
    
    var lastPosition:Vector2;
    var currentPosition:Vector2;
    var originPoint:Vector2;
	
	var lineBuffer:Array<LineSegment> = new Array<LineSegment>();
	var imageDropBuffer:Array<ImageDrop> = new Array<ImageDrop>();
	var trianglePoints:Array<Vector2> =  new Array<Vector2>();
	var triangleSides:Array<Vector2> =  new Array<Vector2>();
	
	var linePool:Pool<LineSegment> = new Pool<LineSegment>();
	var imagePool:Pool<ImageDrop> = new Pool<ImageDrop>();
	
	var clear:Bool = false;
    var iterateTriangle:Bool = false;
	var shouldDraw:Bool = true;
	
	var trianglePosition:Int = 0;
	var triangleLowerPosition:Int = 0;
	var triangleSide:Int = 0;
	
	public var color(default,default) : Color  = Color.White;
	public var triangleColor(default,default) : Color  = Color.White;
	public var thickness(default,default) : Float  = 1;
	public var buffer(default,default):Image;
	public var drawLines(default,default):Bool = true;
	
	
	public function new(x:Float, y:Float, buffer:Image){
        currentPosition = new Vector2(x,y);
        lastPosition = new Vector2(x,y);
        originPoint = new Vector2(x,y);
        this.buffer = buffer;
    }
	
	public function penUp(){
		shouldDraw = false;
	}
	
	public function penDown(){
		shouldDraw = true;
	}
	
	public var heading(default, default) : Float;
	
	public function forward(pixels:Float){
		lastPosition.x = currentPosition.x;
		lastPosition.y = currentPosition.y;
		//pushTrianglePoint();
		currentPosition.x += pixels * Math.sin(heading * (Math.PI/180));
		currentPosition.y += pixels * -Math.cos(heading * (Math.PI/180));
		pushLine();
		
	}
	
	public function backwards(pixels:Float){
		forward(-pixels);
	}
	
	public function jumpTo(x:Int, y:Int){
		lastPosition.y = currentPosition.y;
		lastPosition.x = currentPosition.x;
		//pushTrianglePoint();
		currentPosition.y = y;
		currentPosition.x = x;
		pushLine();
		
	}
	
	public function turn(degrees:Float){
		heading = (heading + degrees) % 360;
	}
	
	public function turnLeft(){
		turn(-90);
	}
	
	public function turnRight(){
		turn(90);
	}
	
	public function startTriangle(){
		iterateTriangle = true;
		//pushTriangleLine();
	}
	
	public function dropImage(img:Image, scale:FastFloat = 1, useHeading:Bool = true, headingOffset:FastFloat = 0 ){
		
		if(!shouldDraw) return;
		
		var d = imagePool.get();
		d.position.x = currentPosition.x;
		d.position.y = currentPosition.y;
		d.heading = useHeading ? (heading + headingOffset):0;
		d.img = img;
		d.scale = scale;
		imageDropBuffer.push(d);
	}
	
	function pushLine() 
	{
		if(!drawLines || !shouldDraw) return;
		
		var l:LineSegment = linePool.get();
		l.start = new Vector2(lastPosition.x, lastPosition.y);
		l.end = new Vector2(currentPosition.x, currentPosition.y);
		
		lineBuffer.push(l);
	}
	
	public function pushTrianglePoint(){
		 	
			if(triangleSides[triangleSide] == null) {
				triangleSides.push(new Vector2());
			}
			
			triangleSides[triangleSide].x = currentPosition.x;
			triangleSides[triangleSide].y = currentPosition.y;
			
			triangleSide++;
			if(triangleSide == 3){
				triangleSide = 0;
				
				for(i in 0...3){
					
					if(trianglePoints[trianglePosition] == null) {
						trianglePoints.push(new Vector2());
					}
							
					trianglePoints[trianglePosition].x = triangleSides[i].x;
					trianglePoints[trianglePosition].y = triangleSides[i].y;
					trianglePosition++;
				}
				
			}
	}
    
	public function start() {
		buffer.g2.begin(false);
	}
    public function clearBuffer(){
       clear = true;
    }
	public function end() {
		buffer.g2.end();	
	}
    
    public function reset(){
		currentPosition.x = originPoint.x;
		currentPosition.y = originPoint.y;
        lastPosition.x = currentPosition.x;
        lastPosition.y = currentPosition.y;
		trianglePosition = 0;
		lineBuffer = [];
		imageDropBuffer = [];
		
    }
    
    public function render() {
	
        if(clear){
            buffer.g2.clear();
            clear = false;
        }
    
		 buffer.g2.color = triangleColor;
	
		var triangleCount:Int =  Math.floor((trianglePosition+1)/3);
		
		 
		if(triangleCount > 0){
			
			var v:Vector2;
			var v1:Vector2;
			var v2:Vector2;
			
			for(i in 0...triangleCount){

				v = trianglePoints[i*3];
				v1 = trianglePoints[3*i+1];
				v2 = trianglePoints[3*i+2];
				
				buffer.g2.fillTriangle(
					v.x, v.y,
					v1.x, v1.y,
					v2.x,v2.y);
			}
			trianglePosition = 0;
		}
		
		buffer.g2.color = color;
		
		var l:LineSegment;
		for (i in 0...lineBuffer.length) 
		{
			 l = lineBuffer[i];
			  buffer.g2.drawLine(l.start.x, l.start.y, l.end.x, l.end.y,thickness);
			  linePool.recycle(l);
		}
		
		lineBuffer = [];
		
		buffer.g2.color = Color.White;
		
		var di:ImageDrop;
		var halfWidth;
		var halfHeight;
		for (i in 0...imageDropBuffer.length) 
		{
			  di = imageDropBuffer[i];
			  
			  halfWidth = (di.img.width*0.5) * di.scale;
			  halfHeight = (di.img.height*0.5) * di.scale;
			  
			  if(di.heading != 0)
			  buffer.g2.pushRotation(
				di.heading * (Math.PI/180), 
			 	di.position.x , 
			  	di.position.y 
			  );
			  
			  if(di.scale != 1)
			 	buffer.g2.drawScaledImage(
					 di.img,di.position.x - halfWidth,
					 di.position.y - halfHeight,
					 di.img.width * di.scale,
					 di.img.height * di.scale
				);
				else{
					buffer.g2.drawImage(
					 di.img,di.position.x - halfWidth,
					 di.position.y - halfHeight);
				}
				
				if(di.heading != 0)
				buffer.g2.popTransformation();
				
			  imagePool.recycle(di);
		}
    	 imageDropBuffer = [];
      
    }
    
}

class ImageDrop{
	public function new(){}
	public var img:Image;
	public var heading:Float;
	public var position:Vector2 = new Vector2();
	public var scale:FastFloat;
}

 @:generic
class Pool<T:haxe.Constraints.Constructible<Void->Void>>{
	var list:GenericStack<T> = new GenericStack<T>();
	
	public function new(){}
	
	public function get() : T{
		if(list.isEmpty()){
			var t = new T();
			return t;
		}
		else{
			return list.pop();
		}
		
	}
	
	public function recycle(item:T) : Void
	{
		list.add(item);
	}
}

class LineSegment {
	public function new() { }
	public var start:Vector2;
	public var end:Vector2;
}