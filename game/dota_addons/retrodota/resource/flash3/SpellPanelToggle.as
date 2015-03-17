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

		var SpellPanelActive:Boolean;
		
		public function SpellPanelToggle() {
			// constructor code
		}
		
		public function setup(api:Object, globals:Object, panel:Object)
		{
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
						
			this.toggleSpellBtn.addEventListener(ButtonEvent.CLICK, onSpellListToggle);
			
			trace("##VotePanel Setup!");
		}
		
		public function onSpellListToggle(event:ButtonEvent)
        {
            trace("Spell List Toggle");
            return;
        }// end function
	}
	
}
