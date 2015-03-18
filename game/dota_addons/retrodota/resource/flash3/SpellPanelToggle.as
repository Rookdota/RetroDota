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
									
			this.spellBtnToggle.addEventListener(MouseEvent.CLICK, onSpellListToggle);
			
			trace("##SpellPanelToggle Setup!");
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
	}
	
}
