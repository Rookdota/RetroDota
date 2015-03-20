package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import scaleform.clik.events.*;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.data.DataProvider;
	
	import ValveLib.*;
	import flash.text.TextFormat;
	
	//import some stuff from the valve lib
	import ValveLib.Globals;
	import ValveLib.ResizeManager;	
	
	public class SpellPanelToggle extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		var spellPanel:Object;

		var SpellPanelActive:Boolean;
		
		public function SpellPanelToggle() {
			// constructor code
		}
		
		public function setup(api:Object, globals:Object, panel:Object)
		{
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
			this.spellPanel = panel;
			
			this.visible = false;
			
			var txFormat:TextFormat = new TextFormat;
			txFormat.font = "$TitleFontBold";
			this.spellBtnToggle.spellToggleText.setTextFormat(txFormat);
									
			this.spellBtnToggle.addEventListener(MouseEvent.CLICK, onSpellListToggle);
			
			// Game Event Listening
			this.gameAPI.SubscribeToGameEvent("show_spell_list_button", this.showSpellListButton);
			
			trace("###SpellPanelToggle Setup!");
		}
		
		public function showSpellListButton(args:Object) : void {			
			
			// Show for this player
			var pID:int = globals.Players.GetLocalPlayer();
			if (args.player_ID == pID) {
				this.visible = true;
				trace("##Spell List Button visible for "+args.player_ID);
			}
		}
		
		public function onSpellListToggle(event:MouseEvent)
        {
            trace("Spell List Toggle");
			if (this.spellPanel.visible == false)
			{
				this.spellPanel.visible = true;
				trace("Spell Panel Visible");
			}
			else
			{
				this.spellPanel.visible = false;
				trace("Spell Panel Hidden");
			}			
			
            return;
        }// end function
		
		public function screenResize(stageW:int, stageH:int, xScale:Number, yScale:Number, wide:Boolean){
			
			trace("Stage Size: ",stageW,stageH);
						
			this.x = stageW/2 + 378*yScale;
			this.y = stageH/2 + 335*yScale;
			
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
