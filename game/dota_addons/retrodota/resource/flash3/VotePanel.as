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
	
	public class VotePanel extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		
		var killsToWinBox:Object;
        var levelBox:Object;
        var goldBox:Object;
        var invokeCDBox:Object;
        var secondInvokeBtn:Object;
        var manaCostBox:Object;
        var wtfBtn:Object;
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
		
			// Replacements
			// Kills To Win: ComboBoxSkinned
			this.killsToWinBox = replaceWithValveComponent(killsToWin, "ComboBoxSkinned");
			this.killsToWinBox.visibleRows = 7;
			this.killsToWinBox.showScrollBar = false;
			this.killsToWinBox.rowHeight = 30;
			this.killsToWinBox.menuWidth = 300;		
			this.killsToWinBox.scaleX = 1.5;
			this.killsToWinBox.scaleY = 1.5;
			var a:Array = new Array();
			a.push({"label":"Ancient", "data":"1"});
			a.push({"label":"2 Kills", "data":"2"});
			a.push({"label":"5 Kills", "data":"3"});
			a.push({"label":"10 Kills", "data":"4"});
			a.push({"label":"25 Kills", "data":"5"});
			a.push({"label":"50 Kills", "data":"6"});
			a.push({"label":"100 Kills", "data":"7"});
			var dataProvider1 = new DataProvider(a);
			this.killsToWinBox.setDataProvider(dataProvider1);
			this.killsToWinBox.setSelectedIndex(0);
			this.killsToWinBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onKillsToWinChanged );
			
			// Initial Level - Slider_New 1-25
			/*this.levelSlider = replaceWithValveComponent(startingLevel, "Slider_New");
			this.levelSlider.minimum = 1;
			this.levelSlider.maximum = 25;
			this.levelSlider.value = 1;
			this.levelSlider.snapInterval = 1;
			this.levelSlider.snapping = true;
			this.levelSlider.addEventListener( SliderEvent.VALUE_CHANGE, onLevelSliderChanged );
			trace("Initial Level: Slider_New 1-25");*/
			
			this.levelBox = replaceWithValveComponent(startingLevel, "ComboBoxSkinned");
			this.levelBox.visibleRows = 5;
			this.levelBox.showScrollBar = false;
			//this.killsToWinBox.rowHeight = 25;
			var array_level:Array = new Array();
			array_level.push({"label":"1", "data":"1"});
			array_level.push({"label":"6", "data":"2"});
			array_level.push({"label":"11", "data":"3"});
			array_level.push({"label":"16", "data":"4"});
			array_level.push({"label":"25", "data":"5"});
			var dataProvider6 = new DataProvider(array_level);
			this.levelBox.setDataProvider(dataProvider6);
			this.levelBox.setSelectedIndex(0);
			this.levelBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onStartingGoldChanged );
			
			
			// Gold Combobox
			this.goldBox = replaceWithValveComponent(startingGold, "ComboBoxSkinned");
			this.goldBox.visibleRows = 6;
			this.goldBox.showScrollBar = false;
			//this.killsToWinBox.rowHeight = 25;
			var array_gold:Array = new Array();
			array_gold.push({"label":"Default", "data":"Default"});
			array_gold.push({"label":"1.5k", "data":"1.5k"});
			array_gold.push({"label":"5k", "data":"5k"});
			array_gold.push({"label":"10k", "data":"10k"});
			array_gold.push({"label":"20k", "data":"20k"});
			array_gold.push({"label":"MAX", "data":"MAX"});
			var dataProvider2 = new DataProvider(array_gold);
			this.goldBox.setDataProvider(dataProvider2);
			this.goldBox.setSelectedIndex(0);
			this.goldBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onStartingGoldChanged );
			
			// Invoke CD: 12/6/2/0 ComboBoxSkinned
			this.invokeCDBox = replaceWithValveComponent(invokeCD, "ComboBoxSkinned");
			this.invokeCDBox.visibleRows = 4;
			this.invokeCDBox.showScrollBar = false;
			//this.killsToWinBox.rowHeight = 25;
			var array_cd:Array = new Array();
			array_cd.push({"label":"12", "data":"12"});
			array_cd.push({"label":"6", "data":"6"});
			array_cd.push({"label":"2", "data":"2"});
			array_cd.push({"label":"0", "data":"0"});
			var dataProvider3 = new DataProvider(array_cd);
			this.invokeCDBox.setDataProvider(dataProvider3);
			this.invokeCDBox.setSelectedIndex(0);
			this.invokeCDBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onInvokeCDChanged );
			
			// 2nd Invoke slot: DotaCheckBoxDota
			this.secondInvokeBtn = replaceWithValveComponent(secondInvoke, "DotaCheckBoxDota");
			this.secondInvokeBtn.label = "2 Invoke Slots";
			this.secondInvokeBtn.selected = true;
			this.secondInvokeBtn.addEventListener(MouseEvent.CLICK, secondInvoke_click);
			
			// Mana Cost: 100/50/0 ComboBoxSkinned
			this.manaCostBox = replaceWithValveComponent(manaCost, "ComboBoxSkinned");
			this.manaCostBox.visibleRows = 3;
			this.manaCostBox.showScrollBar = false;
			//this.killsToWinBox.rowHeight = 25;
			var array_mana:Array = new Array();
			array_mana.push({"label":"100", "data":"100"});
			array_mana.push({"label":"50", "data":"50"});
			array_mana.push({"label":"No Mana Cost", "data":"0 FREE"});
			var dataProvider4 = new DataProvider(array_mana);
			this.manaCostBox.setDataProvider(dataProvider4);
			this.manaCostBox.setSelectedIndex(0);
			this.manaCostBox.menuList.addEventListener( ListEvent.INDEX_CHANGE, onManaCostChanged );
			
			// -wtf: DotaCheckBoxDota
			// 2nd Invoke slot: DotaCheckBoxDota
			this.wtfBtn = replaceWithValveComponent(wtf, "DotaCheckBoxDota");
			this.wtfBtn.label = "Enable -wtf?";
			this.wtfBtn.selected = false;
			this.wtfBtn.addEventListener(MouseEvent.CLICK, wtf_click);
					
			//Vote Button
			this.voteBtn = replaceWithValveComponent(vote, "ButtonThinSecondary");
			voteBtn.addEventListener(ButtonEvent.CLICK, onVoteButtonClicked);
			voteBtn.label = "VOTE";
			//GoButton.label = Globals.instance.GameInterface.Translate("#Play");
			
			//Don't care button
			this.ignoreBtn = replaceWithValveComponent(dontCare, "ButtonThinPrimary");
			ignoreBtn.addEventListener(ButtonEvent.CLICK, onIgnoreButtonClicked);
			ignoreBtn.label = "DONT CARE";
			//GoButton.label = Globals.instance.GameInterface.Translate("#Play");
			
			trace("##GamePanel Setup!");
		}
		
		public function onKillsToWinChanged(event:ListEvent)
        {
            var Current:String = this.killsToWinBox.menuList.dataProvider[this.killsToWinBox.selectedIndex].data;
            trace("Kills To Win Changed to " + Current);
            return;
        }// end function

        public function onLevelSliderChanged(event:SliderEvent)
        {
			 var Current:String = this.levelBox.menuList.dataProvider[this.levelBox.selectedIndex].data;
            trace("Starting Level Changed to "+ Current);
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
            trace("Starting Gold Changed to " + Current);
            return;
        }// end function

        public function onManaCostChanged(event:ListEvent)
        {
            var Current:String = this.manaCostBox.menuList.dataProvider[this.manaCostBox.selectedIndex].data;
            trace("Mana Cost Changed to " + Current);
            return;
        }// end function

        public function secondInvoke_click(event:MouseEvent)
        {
            if (this.secondInvokeBtn.selected == true)
            {
                trace("Second Invoke ON");
            }
            else
            {
                trace("Second Invoke OFF");
            }
            return;
        }// end function

        public function wtf_click(event:MouseEvent)
        {
            if (this.wtfBtn.selected == true)
            {
                trace("WTF ON");
            }
            else
            {
                trace("WTF OFF");
            }
            return;
        }// end function

        public function onVoteButtonClicked(event:ButtonEvent)
        {
            trace("VOTED");
            this.visible = false;
            return;
        }// end function

        public function onIgnoreButtonClicked(event:ButtonEvent)
        {
            trace("DONT CARE");
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
						
			this.x = stageW/2;
			this.y = stageH/2;		
			
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
