﻿package  {
	
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
	
	public class VotePanel extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		
		var killsToWinBox:Object;
        var levelBox:Object;
        var goldBox:Object;
        var invokeCDBox:Object;
        var secondInvokeBox:Object;
        var forceMirrorBox:Object;
        var manaCostBox:Object;
        var wtfBox:Object;
        var fastRespawnBox:Object;
		var xpSlider:Object;
		var goldSlider:Object;
		var voteBtn:Object;
		var ignoreBtn:Object;
		
		public function VotePanel() {
			// constructor code
		}
		
		public function setup(api:Object, globals:Object)
		{
			//set our needed variables
			this.gameAPI = api;
			this.globals = globals;
					
			//Hide the "Filter By". Do this only when the hero pick phase has started!
			var obj = globals.Loader_shared_heroselectorandloadout.movieClip.heroDock.filterButtons; 
			obj.parent.removeChild(obj);
			
			// Replacements
			// Kills To Win: ComboBoxSkinned
			this.killsToWinBox = replaceWithValveComponent(killsToWin, "ComboBoxSkinned");
	
			var array_wcondition:Array = new Array();
			array_wcondition.push({"label":"2 kills", "data":"1"});
			array_wcondition.push({"label":"5 kills", "data":"2"});
			array_wcondition.push({"label":"10 kills", "data":"3"});
			array_wcondition.push({"label":"25 kills", "data":"4"});
			array_wcondition.push({"label":"50 kills", "data":"5"});
			array_wcondition.push({"label":"100 kills", "data":"6"});
			array_wcondition.push({"label":"Ancient", "data":"7"});
			var dataProvider1 = new DataProvider(array_wcondition);
			this.killsToWinBox.setDataProvider(dataProvider1);
			this.killsToWinBox.setSelectedIndex(6);
			this.killsToWinBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onKillsToWinChanged );
						
			this.levelBox = replaceWithValveComponent(startingLevel, "ComboBoxSkinned");
			var array_level:Array = new Array();
			array_level.push({"label":"Level 1", "data":"1"});
			array_level.push({"label":"Level 6", "data":"2"});
			array_level.push({"label":"Level 11", "data":"3"});
			array_level.push({"label":"Level 16", "data":"4"});
			array_level.push({"label":"Level 25", "data":"5"});
			var dataProvider6 = new DataProvider(array_level);
			this.levelBox.setDataProvider(dataProvider6);
			this.levelBox.setSelectedIndex(1);
			this.levelBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onStartingLevelChanged );
			
			// Gold Combobox
			this.goldBox = replaceWithValveComponent(startingGold, "ComboBoxSkinned");
			var array_gold:Array = new Array();
			array_gold.push({"label":"625 (standard)", "data":"1"});
			array_gold.push({"label":"1.5k", "data":"2"});
			array_gold.push({"label":"5k", "data":"3"});
			array_gold.push({"label":"10k", "data":"4"});
			array_gold.push({"label":"20k", "data":"5"});
			array_gold.push({"label":"MAX", "data":"6"});
			var dataProvider2 = new DataProvider(array_gold);
			this.goldBox.setDataProvider(dataProvider2);
			this.goldBox.setSelectedIndex(0);
			this.goldBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onStartingGoldChanged );
			
			// Invoke CD: 12/6/2/0 ComboBoxSkinned
			this.invokeCDBox = replaceWithValveComponent(invokeCD, "ComboBoxSkinned");
			var array_cd:Array = new Array();
			array_cd.push({"label":"12 seconds", "data":"1"});
			array_cd.push({"label":"6 seconds", "data":"2"});
			array_cd.push({"label":"2 seconds", "data":"3"});
			array_cd.push({"label":"0 seconds", "data":"4"});
			var dataProvider3 = new DataProvider(array_cd);
			this.invokeCDBox.setDataProvider(dataProvider3);
			this.invokeCDBox.setSelectedIndex(1);
			this.invokeCDBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onInvokeCDChanged );
			
			// 2nd Invoke slot: ComboBoxSkinned
			this.secondInvokeBox = replaceWithValveComponent(secondInvoke, "ComboBoxSkinned");
			var array_yn:Array = new Array();
			array_yn.push({"label":"1 slot", "data":"1"});
			array_yn.push({"label":"2 slots", "data":"2"});
			var dataProvider7 = new DataProvider(array_yn);
			this.secondInvokeBox.setDataProvider(dataProvider7);
			this.secondInvokeBox.setSelectedIndex(1);
			this.secondInvokeBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, secondInvoke_click );

			// 2nd Invoke slot: ComboBoxSkinned
			this.forceMirrorBox = replaceWithValveComponent(forceMirror, "ComboBoxSkinned");
			var array_fmm:Array = new Array();
			array_fmm.push({"label":"Normal All Pick", "data":"1"});
			array_fmm.push({"label":"Mirror Most Picked", "data":"2"});
			var dataProvider10 = new DataProvider(array_fmm);
			this.forceMirrorBox.setDataProvider(dataProvider10);
			this.forceMirrorBox.setSelectedIndex(1);
			this.forceMirrorBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, forceMirror_click );
			
			// Mana Cost: 100/50/0 ComboBoxSkinned
			this.manaCostBox = replaceWithValveComponent(manaCost, "ComboBoxSkinned");
			var array_mana:Array = new Array();
			array_mana.push({"label":"100% (full mana cost)", "data":"1"});
			array_mana.push({"label":"50% (half mana cost)", "data":"2"});
			array_mana.push({"label":"0% (no mana cost)", "data":"3"});
			var dataProvider4 = new DataProvider(array_mana);
			this.manaCostBox.setDataProvider(dataProvider4);
			this.manaCostBox.setSelectedIndex(1);
			this.manaCostBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onManaCostChanged );
			
			// -wtf: DotaCheckBoxDota
			// 2nd Invoke slot: DotaCheckBoxDota
			this.wtfBox = replaceWithValveComponent(wtf, "ComboBoxSkinned");
			var array_wtf:Array = new Array();
			array_wtf.push({"label":"No", "data":"0"});
			array_wtf.push({"label":"Yes", "data":"1"});
			var dataProvider8 = new DataProvider(array_wtf);
			this.wtfBox.setDataProvider(dataProvider8);
			this.wtfBox.setSelectedIndex(0);
			this.wtfBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, wtf_click );

			this.fastRespawnBox = replaceWithValveComponent(fastRespawn, "ComboBoxSkinned");
			var array_fast:Array = new Array();
			array_fast.push({"label":"No", "data":"0"});
			array_fast.push({"label":"Yes", "data":"1"});
			var dataProvider9 = new DataProvider(array_fast);
			this.fastRespawnBox.setDataProvider(dataProvider9);
			this.fastRespawnBox.setSelectedIndex(1);
			this.fastRespawnBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, fast_click );
			
			// Gold Multiplier Slider
			this.goldSlider = replaceWithValveComponent(goldMultiplier, "Slider_New");
			this.goldSlider.minimum = 1;
			this.goldSlider.maximum = 5;
			this.goldSlider.value = 1;
			this.goldSlider.snapInterval = 1;
			this.goldSlider.snapping = true;
			this.goldSlider.addEventListener( SliderEvent.VALUE_CHANGE, onGoldSliderChanged );
			
			// XP Multiplier Slider
			this.xpSlider = replaceWithValveComponent(xpMultiplier, "Slider_New");
			this.xpSlider.minimum = 1;
			this.xpSlider.maximum = 5;
			this.xpSlider.value = 1;
			this.xpSlider.snapInterval = 1;
			this.xpSlider.snapping = true;
			this.xpSlider.addEventListener( SliderEvent.VALUE_CHANGE, onXPSliderChanged );
					
			//Vote Button
			this.voteBtn = replaceWithValveComponent(vote, "ButtonThinSecondary");
			this.voteBtn.addEventListener(ButtonEvent.CLICK, onVoteButtonClicked);
			this.voteBtn.label = Globals.instance.GameInterface.Translate("#VOTE");
			
			//Don't care button
			this.ignoreBtn = replaceWithValveComponent(dontCare, "ButtonThinPrimary");
			this.ignoreBtn.addEventListener(ButtonEvent.CLICK, onIgnoreButtonClicked);
			this.ignoreBtn.label = Globals.instance.GameInterface.Translate("#DONTCARE");

			// Font Labels
			var txFormatBold:TextFormat = new TextFormat;
			txFormatBold.font = "$TextFontBold";

			var txFormatTitle:TextFormat = new TextFormat;
			txFormatTitle.font = "$TitleFontBold";

			this.InvokerTitle.text = Globals.instance.GameInterface.Translate("#InvokerTitle");
			this.InvokerTitle.setTextFormat(txFormatTitle);

			this.WinConditionLabel.text = Globals.instance.GameInterface.Translate("#WinConditionLabel");
			this.WinConditionLabel.setTextFormat(txFormatBold);

			this.StartingLevelLabel.text = Globals.instance.GameInterface.Translate("#StartingLevelLabel");
			this.StartingLevelLabel.setTextFormat(txFormatBold);

			this.StartingGoldLabel.text = Globals.instance.GameInterface.Translate("#StartingGoldLabel");
			this.StartingGoldLabel.setTextFormat(txFormatBold);

			this.InvokeCDLabel.text = Globals.instance.GameInterface.Translate("#InvokeCDLabel");
			this.InvokeCDLabel.setTextFormat(txFormatBold);

			this.SecondInvokeLabel.text = Globals.instance.GameInterface.Translate("#SecondInvokeLabel");
			this.SecondInvokeLabel.setTextFormat(txFormatBold);

			this.ManaCostLabel.text = Globals.instance.GameInterface.Translate("#ManaCostLabel");
			this.ManaCostLabel.setTextFormat(txFormatBold);

			this.wtfLabel.text = Globals.instance.GameInterface.Translate("#wtfLabel");
			this.wtfLabel.setTextFormat(txFormatBold);

			this.fastRespawnLabel.text = Globals.instance.GameInterface.Translate("#fastRespawnLabel");
			this.fastRespawnLabel.setTextFormat(txFormatBold);
								
			this.GoldMultiplierLabel.text = Globals.instance.GameInterface.Translate("#GoldMultiplierTextLabel")+" x"+"1";
			this.GoldMultiplierLabel.setTextFormat(txFormatBold);

			this.XPMultiplierLabel.text = Globals.instance.GameInterface.Translate("#XPMultiplierTextLabel")+" x"+"1";	
			this.XPMultiplierLabel.setTextFormat(txFormatBold);
			
			// Game Event Listening
			this.visible = false;
			this.gameAPI.SubscribeToGameEvent("show_vote_panel", this.showVotePanel);
			this.gameAPI.SubscribeToGameEvent("hide_vote_panel", this.hideVotePanel);
			
			trace("##VotePanel Setup!");
		}
		
		public function showVotePanel() : void {
			this.visible = true
			trace("##VotePanel is now Visible")
		}
		
		public function hideVotePanel() : void {
			this.visible = false
			trace("##VotePanel is now Hidden")
		}
		
		public function onKillsToWinChanged(event:ListEvent)
        {
            var Current:String = this.killsToWinBox.menuList.dataProvider[this.killsToWinBox.selectedIndex].data;
            trace("Kills To Win Changed to " + Current);
						
            return;
        }// end function
		
		public function onGoldSliderChanged(event:SliderEvent)
        {
			trace("gold slider " + this.goldSlider.value);
			this.GoldMultiplierLabel.text = Globals.instance.GameInterface.Translate("#GoldMultiplierTextLabel")+" x"+this.goldSlider.value;
			
			//font
			var txFormat:TextFormat = new TextFormat;
			txFormat.font = "$TextFontBold";					
			this.GoldMultiplierLabel.setTextFormat(txFormat);
        }// end function

        public function onXPSliderChanged(event:SliderEvent)
        {
			trace("xp slider " + this.xpSlider.value);
			this.XPMultiplierLabel.text = Globals.instance.GameInterface.Translate("#XPMultiplierTextLabel")+" x"+this.xpSlider.value;
			
			//font
			var txFormat:TextFormat = new TextFormat;
			txFormat.font = "$TextFontBold";					
			this.XPMultiplierLabel.setTextFormat(txFormat);
			
        }// end function

        public function onStartingLevelChanged(event:ListEvent)
        {
            var Current:String = this.levelBox.menuList.dataProvider[this.levelBox.selectedIndex].data;
            trace("Starting Level Changed to " + Current);
            return;		
        }// end function

        public function onStartingGoldChanged(event:ListEvent)
        {
            var Current:String = this.goldBox.menuList.dataProvider[this.goldBox.selectedIndex].data;
            trace("Starting Gold Changed to " + Current);
            return;		
        }// end function

        public function onInvokeCDChanged(event:ListEvent)
        {
            var Current:String = this.invokeCDBox.menuList.dataProvider[this.invokeCDBox.selectedIndex].data;
            trace("Invoke CD Changed to " + Current);
            return;
        }// end function

        public function onManaCostChanged(event:ListEvent)
        {
            var Current:String = this.manaCostBox.menuList.dataProvider[this.manaCostBox.selectedIndex].data;
            trace("Mana Cost Changed to " + Current);
            return;
        }// end function

        public function secondInvoke_click(event:ListEvent)
        {
            var Current:String = this.secondInvokeBox.menuList.dataProvider[this.secondInvokeBox.selectedIndex].data;
            trace("Invoke 2nd slot " + Current);
            return;
        }// end function

        public function forceMirror_click(event:ListEvent)
        {
            var Current:String = this.forceMirrorBox.menuList.dataProvider[this.forceMirrorBox.selectedIndex].data;
            trace("Force Mirror Match " + Current);
            return;
        }// end function

        public function wtf_click(event:ListEvent)
        {
			var Current:String = this.wtfBox.menuList.dataProvider[this.wtfBox.selectedIndex].data;
            trace("WTF " + Current);
            return;
        }// end function

         public function fast_click(event:ListEvent)
        {
			var Current:String = this.fastRespawnBox.menuList.dataProvider[this.fastRespawnBox.selectedIndex].data;
            trace("FAST RESPAWN " + Current);
            return;
        }// end function

        public function onVoteButtonClicked(event:ButtonEvent)
        {
            trace("VOTE REGISTERED");

            var win_condition:String = this.killsToWinBox.menuList.dataProvider[this.killsToWinBox.selectedIndex].data;
            var level:String = this.levelBox.menuList.dataProvider[this.levelBox.selectedIndex].data;
			var gold:String = this.goldBox.menuList.dataProvider[this.goldBox.selectedIndex].data;
			var invoke_cd:String = this.invokeCDBox.menuList.dataProvider[this.invokeCDBox.selectedIndex].data;
			var invoke_slots:String = this.secondInvokeBox.menuList.dataProvider[this.secondInvokeBox.selectedIndex].data;
			var mirror_match:String = this.forceMirrorBox.menuList.dataProvider[this.forceMirrorBox.selectedIndex].data;
			var mana_cost_reduction:String = this.manaCostBox.menuList.dataProvider[this.manaCostBox.selectedIndex].data;
			var wtf:String = this.wtfBox.menuList.dataProvider[this.wtfBox.selectedIndex].data;
			var fast_respawn:String = this.fastRespawnBox.menuList.dataProvider[this.fastRespawnBox.selectedIndex].data;
			var gold_multiplier:String = this.goldSlider.value;
			var xp_multiplier:String = this.xpSlider.value;

			var command:String = "player_voted "+ win_condition+','+level+','+gold+','+invoke_cd+','+invoke_slots+','+mana_cost_reduction+','+wtf+','+fast_respawn+','+gold_multiplier+','+xp_multiplier+','+mirror_match;

            trace(command)
			this.gameAPI.SendServerCommand(command);
			this.visible = false;
            return;
        }// end function

        public function onIgnoreButtonClicked(event:ButtonEvent)
        {
            trace("VOTE IGNORED");
            this.visible = false;
			this.gameAPI.SendServerCommand("player_skip_vote");
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
						
			this.x = stageW/2;
			this.y = stageH/2 - 17*yScale;		
			
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
