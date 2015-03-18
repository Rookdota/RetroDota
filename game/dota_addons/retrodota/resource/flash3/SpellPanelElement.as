package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import scaleform.clik.events.*;
	import flash.geom.Point;
	
	import ValveLib.*;
	import flash.text.TextFormat;
	
	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;	
	
	public class SpellPanelElement extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		public var iconName:String;
		
		public function SpellPanelElement() {
			// constructor code
		}
	
		public function setup(api:Object, globals:Object, spellName:String, first_elem:String, second_elem:String, third_elem:String)
		{
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
						
			//Image
			var spellIcon:MovieClip = new MovieClip;
			this.globals.LoadImage("images/spellicons/invoker_retro_" + this.name + ".png", spellIcon, false);
			spellIcon.scaleY = 0.19; //24px
			spellIcon.scaleX = 0.19; //24px
			this.addChild(spellIcon);
			
			this.iconName = "invoker_retro_"+this.name;
			this.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
			
			//Spell Text
			var txFormat:TextFormat = new TextFormat;
			txFormat.font = "$TextFont";

			this.spellName.text = spellName;
			this.spellName.setTextFormat(txFormat);
			
			//QWE Text
			//e1
			var txFormat1:TextFormat = new TextFormat;
			txFormat1.font = "$TextFont";
			
			var QuasColor:Number = 0x008A8A;
			var WexColor:Number = 0xCC0099;
			var ExortColor:Number = 0xE68A00;
									
			this.e1.text = first_elem;
			switch(first_elem){
				case "Q":
					txFormat1.color = QuasColor;
					break;			
				case "W":
					txFormat1.color = WexColor;
					break;		
				case "E":
					txFormat1.color = ExortColor;
					break;
			}			
			this.e1.setTextFormat(txFormat1);
			
			//e2
			var txFormat2:TextFormat = new TextFormat;
			txFormat2.font = "$TextFont";
									
			this.e2.text = second_elem;
			switch(second_elem){
				case "Q":
					txFormat2.color = QuasColor;
					break;			
				case "W":
					txFormat2.color = WexColor;
					break;		
				case "E":
					txFormat2.color = ExortColor;
					break;
			}			
			this.e2.setTextFormat(txFormat2);
			
			//e3
			var txFormat3:TextFormat = new TextFormat;
			txFormat3.font = "$TextFont";
									
			this.e3.text = third_elem;
			switch(third_elem){
				case "Q":
					txFormat3.color = QuasColor;
					break;			
				case "W":
					txFormat3.color = WexColor;
					break;		
				case "E":
					txFormat3.color = ExortColor;
					break;
			}			
			this.e3.setTextFormat(txFormat3);
			
			
			trace("Constructed spell element of "+this.iconName);
		}		
		
		public function onMouseRollOver(keys:MouseEvent){
       		
       		var s:Object = keys.target;
       		trace("roll over! " + s.iconName);

			// Workout where to put it
            var lp:Point = s.localToGlobal(new Point(0, 0));
			
            globals.Loader_heroselection.gameAPI.OnSkillRollOver(lp.x, lp.y, s.iconName);
       	}
		
		public function onMouseRollOut(keys:MouseEvent){
			
			globals.Loader_heroselection.gameAPI.OnSkillRollOut();
		}
		
	}
}
