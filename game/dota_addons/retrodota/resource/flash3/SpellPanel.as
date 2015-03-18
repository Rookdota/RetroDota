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
		
	public class SpellPanel extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		
		var closeBtn:Object;
		
		public function SpellPanel() {
			// constructor code
		}
		
		public function setup(api:Object, globals:Object)
		{
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
			
			this.closeBtn = replaceWithValveComponent(closeSpellPanel, "s_closeBtn");
			this.closeBtn.addEventListener(ButtonEvent.CLICK, onCloseButtonClicked);
			
			// Icon Setups
			this.icy_path.setup(this.gameAPI, this.globals, "Icy Path","Q","Q","Q");
			this.portal.setup(this.gameAPI, this.globals, "Portal","Q","Q","W");
			this.frost_nova.setup(this.gameAPI, this.globals, "Frost Nova","Q","Q","E");
			
			this.betrayal.setup(this.gameAPI, this.globals, "Betrayal","Q","W","Q");
			this.tornado_blast.setup(this.gameAPI, this.globals, "Tornado Blast","Q","W","W");
			this.levitation.setup(this.gameAPI, this.globals, "Levitation","Q","W","E");
			
			this.power_word.setup(this.gameAPI, this.globals, "Power Word","Q","E","Q");
			this.invisibility_aura.setup(this.gameAPI, this.globals, "Invisibility Aura","Q","E","W");
			this.shroud_of_flames.setup(this.gameAPI, this.globals, "Shroud of Flames","Q","E","E");
			
			this.mana_burn.setup(this.gameAPI, this.globals, "Mana Burn","W","Q","Q");
			this.emp.setup(this.gameAPI, this.globals, "EMP","W","Q","W");
			this.soul_blast.setup(this.gameAPI, this.globals, "Soul Blast","W","Q","E");
			
			this.telelightning.setup(this.gameAPI, this.globals, "Telelightning","W","W","Q");
			this.shock.setup(this.gameAPI, this.globals, "Shock","W","W","W");
			this.arcane_arts.setup(this.gameAPI, this.globals, "Arcane Arts","W","W","E");
			
			this.scout.setup(this.gameAPI, this.globals, "Scout","W","E","Q");
			this.energy_ball.setup(this.gameAPI, this.globals, "Energy Ball","W","E","W");
			this.lightning_shield.setup(this.gameAPI, this.globals, "Lightning Shield","W","E","E");
			
			this.chaos_meteor.setup(this.gameAPI, this.globals, "Chaos Meteor","E","Q","Q");
			this.confuse.setup(this.gameAPI, this.globals, "Confuse","E","Q","W");
			this.disarm.setup(this.gameAPI, this.globals, "Disarm","E","Q","E");
			
			this.soul_reaver.setup(this.gameAPI, this.globals, "Soul Reaver","E","W","Q");
			this.firestorm.setup(this.gameAPI, this.globals, "Firestorm","E","W","W");
			this.incinerate.setup(this.gameAPI, this.globals, "Incinerate","E","W","E");
			
			this.deafening_blast.setup(this.gameAPI, this.globals, "Deafening Blast","E","E","Q");
			this.inferno.setup(this.gameAPI, this.globals, "Inferno","E","E","W");
			this.firebolt.setup(this.gameAPI, this.globals, "Firebolt","E","E","E");
			
			
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
						
			this.x = stageW/2 + 685*yScale;
			this.y = stageH/2 - 95*yScale;		
			
			this.width = this.width*yScale;
			this.height	 = this.height*yScale;
			
			trace("#Result Resize: ",this.x,this.y,yScale);
					 
			//Now we just set the scale of this element, because these parameters are already the inverse ratios
			this.scaleX = xScale;
			this.scaleY = yScale;
			
			trace("#Highscore Panel  Resize");
		}
	}
	
}
