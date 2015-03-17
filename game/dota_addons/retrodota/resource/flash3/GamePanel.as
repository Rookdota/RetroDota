package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import scaleform.clik.events.*;
	import scaleform.clik.data.DataProvider;
	
	import ValveLib.*;
	import flash.text.TextFormat;
	
	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;	
	
	public class GamePanel extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		
		var closeBtn:Object;
		
		public function GamePanel() {
			// constructor code
		}
		
		public function setup(api:Object, globals:Object)
		{
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
			
			this.closeBtn = replaceWithValveComponent(closeGamePanel, "s_closeBtn"); 
			this.closeBtn.addEventListener(ButtonEvent.CLICK, onCloseButtonClicked);
			
			trace("##SpellPanel Setup!");
		}
		
		public function onCloseButtonClicked(event:ButtonEvent)
        {
            trace("Close Game Panel");
            this.visible = false;
            return;
        }// end function
		
		//Parameters: 
		//	mc - The movieclip to replace
		//	type - The name of the class you want to replace with
		//	keepDimensions - Resize from default dimensions to the dimensions of mc (optional, false by default)
		public function replaceWithValveComponent(mc:MovieClip, type:String, keepDimensions:Boolean = false) : MovieClip {
			var parent = mc.parent;
			var oldx = mc.x;
			var oldy = mc.y;
			var oldwidth = mc.width;
			var oldheight = mc.height;
			
			var newObjectClass = getDefinitionByName(type);
			var newObject = new newObjectClass();
			newObject.x = oldx;
			newObject.y = oldy;
			if (keepDimensions) {
				newObject.width = oldwidth;
				newObject.height = oldheight;
			}
			
			parent.removeChild(mc);
			parent.addChild(newObject);
			
			return newObject;
		}
		
		//onScreenResize
		public function screenResize(stageW:int, stageH:int, xScale:Number, yScale:Number, wide:Boolean){
			
			trace("Stage Size: ",stageW,stageH);
						
			this.x = stageW/2 - 685*yScale;
			this.y = stageH/2 - 108*yScale;		
			
			this.width = this.width*yScale;
			this.height	 = this.height*yScale;
			
			trace("#Result Resize: ",this.x,this.y,yScale);
					 
			//Now we just set the scale of this element, because these parameters are already the inverse ratios
			this.scaleX = xScale*1.5;
			this.scaleY = yScale*1.5;
			
			trace("#Highscore Panel  Resize");
		}
	}
	
}
