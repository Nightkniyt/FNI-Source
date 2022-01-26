package;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import ui.FlxVirtualPad;
import flixel.util.FlxSave;
import flixel.math.FlxPoint;
import haxe.Json;
import ui.Hitbox;
import ui.AndroidControls.Config;

using StringTools;

class CastomAndroidControls extends MusicBeatState
{
	var _pad:FlxVirtualPad;
	var _hb:Hitbox;

	var up_text:FlxText;
	var down_text:FlxText;
	var left_text:FlxText;
	var right_text:FlxText;

	var inputvari:FlxText;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
							//'hitbox',
	var controlitems:Array<String> = ['right control', 'left control','keyboard','custom', 'hitbox'];

	var curSelected:Int = 0;

	var buttonistouched:Bool = false;

	var bindbutton:flixel.ui.FlxButton;

	var config:Config;

	override public function create():Void
	{
		super.create();

        var aurorga:FlxSprite = new FlxSprite();
		aurorga.frames = Paths.getSparrowAtlas('mainmenu/AuroraDemoMenu');
		aurorga.animation.addByPrefix('bop', 'why he standin like that', 24, true);
		aurorga.animation.play('bop');
		aurorga.updateHitbox();
		aurorga.screenCenter(X);
		add(aurorga);

		//init config
		config = new Config();

		// load curSelected
		curSelected = config.getcontrolmode();
		
		//pad
		_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
		_pad.alpha = 0;
		
		//text inputvari
		inputvari = new FlxText(125, 50, 0, controlitems[0], 48);
		
		//arrows
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		leftArrow = new FlxSprite(inputvari.x - 60,inputvari.y - 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');

		rightArrow = new FlxSprite(inputvari.x + inputvari.width + 10, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');


		//text
		up_text = new FlxText(200, 200, 0,"Button up x:" + _pad.buttonUp.x +" y:" + _pad.buttonUp.y, 24);
		down_text = new FlxText(200, 250, 0,"Button down x:" + _pad.buttonDown.x +" y:" + _pad.buttonDown.y, 24);
		left_text = new FlxText(200, 300, 0,"Button left x:" + _pad.buttonLeft.x +" y:" + _pad.buttonLeft.y, 24);
		right_text = new FlxText(200, 350, 0,"Button right x:" + _pad.buttonRight.x +" y:" + _pad.buttonRight.y, 24);
		
		//hitboxes

		_hb = new Hitbox();
		_hb.visible = false;

		// buttons
		var savebutton:FlxButton = new FlxButton(FlxG.width - 150, 25, "Save And Exit", function()
		{
			save();
			MusicBeatState.switchState(new OptionsState());
		});
		savebutton.resize(100,50);

		var exitbutton:FlxButton = new FlxButton(saveButton.x, 75, "Exit", function()
		{
			MusicBeatState.switchState(new OptionsState());
		});
		exitbutton.resize(100,50);

		// add buttons
		add(exitbutton);
		add(savebutton);

		// add virtualpad
		add(_pad);

		//add hb
		add(_hb);


		// add arrows and text
		add(inputvari);
		add(leftArrow);
		add(rightArrow);

		// add texts
		add(up_text);
		add(down_text);
		add(left_text);
		add(right_text);

		// change selection
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		for (touch in FlxG.touches.list){
			arrowanimate(touch);
			
			if(touch.overlaps(leftArrow) && touch.justPressed){
				changeSelection(-1);
			}else if (touch.overlaps(rightArrow) && touch.justPressed){
				changeSelection(1);
			}

			trackbutton(touch);
		}
	}

	function changeSelection(change:Int = 0)
	{
			curSelected += change;
	
			if (curSelected < 0)
				curSelected = controlitems.length - 1;
			if (curSelected >= controlitems.length)
				curSelected = 0;
	
			inputvari.text = controlitems[curSelected];

			if (controlitems[curSelected] != "hitbox")
				_hb.visible = false;

			var daChoice:String = controlitems[Math.floor(curSelected)];

			switch (daChoice)
			{
				case 'right control':
					remove(_pad);
					_pad = null;
					_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
					_pad.alpha = 0.75;
					add(_pad);
				case 'left control':
					remove(_pad);
					_pad = null;
					_pad = new FlxVirtualPad(FULL, NONE);
					_pad.alpha = 0.75;
					add(_pad);
				case 'keyboard':
					_pad.alpha = 0;
				case 'custom':
					add(_pad);
					_pad.alpha = 0.75;
					loadcustom();
				case 'hitbox':
					remove(_pad);
					_pad.alpha = 0;
					_hb.visible = true;
			}
	}

	function arrowanimate(touch:flixel.input.touch.FlxTouch){
		if(touch.overlaps(leftArrow) && touch.pressed){
			leftArrow.animation.play('press');
		}
		
		if(touch.overlaps(leftArrow) && touch.released){
			leftArrow.animation.play('idle');
		}
		//right arrow animation
		if(touch.overlaps(rightArrow) && touch.pressed){
			rightArrow.animation.play('press');
		}
		
		if(touch.overlaps(rightArrow) && touch.released){
			rightArrow.animation.play('idle');
		}
	}

	function trackbutton(touch:flixel.input.touch.FlxTouch){
		//custom pad

		if (buttonistouched){
			
			if (bindbutton.justReleased && touch.justReleased)
			{
				bindbutton = null;
				buttonistouched = false;
			}else 
			{
				movebutton(touch, bindbutton);
				setbuttontexts();
			}

		}else {
			if (_pad.buttonUp.justPressed) {
				if (curSelected != 3)
					changeSelection(0,3);

				movebutton(touch, _pad.buttonUp);
			}
			
			if (_pad.buttonDown.justPressed) {
				if (curSelected != 3)
					changeSelection(0,3);

				movebutton(touch, _pad.buttonDown);
			}

			if (_pad.buttonRight.justPressed) {
				if (curSelected != 3)
					changeSelection(0,3);

				movebutton(touch, _pad.buttonRight);
			}

			if (_pad.buttonLeft.justPressed) {
				if (curSelected != 3)
					changeSelection(0,3);

				movebutton(touch, _pad.buttonLeft);
			}
		}
	}

	function movebutton(touch:flixel.input.touch.FlxTouch, button:flixel.ui.FlxButton) {
		button.x = touch.x - _pad.buttonUp.width / 2;
		button.y = touch.y - _pad.buttonUp.height / 2;
		bindbutton = button;
		buttonistouched = true;
	}

	function setbuttontexts() {
		up_text.text = "Button up x:" + _pad.buttonUp.x +" y:" + _pad.buttonUp.y;
		down_text.text = "Button down x:" + _pad.buttonDown.x +" y:" + _pad.buttonDown.y;
		left_text.text = "Button left x:" + _pad.buttonLeft.x +" y:" + _pad.buttonLeft.y;
		right_text.text = "Button right x:" + _pad.buttonRight.x +" y:" + _pad.buttonRight.y;
	}

	function save() {

		config.setcontrolmode(curSelected);
		
		if (curSelected == 3){
			savecustom();
		}
	}

	function savecustom() {
		trace("saved");

		//Config.setdata(55);

		config.savecustom(_pad);
	}

	function loadcustom():Void{
		//load pad
		_pad = config.loadcustom(_pad);	
	
	}

	function resizebuttons(vpad:FlxVirtualPad, ?int:Int = 200) {
		for (button in vpad)
		{
				button.setGraphicSize(260);
				button.updateHitbox();
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}
