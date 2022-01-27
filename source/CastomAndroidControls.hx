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

	var upPozition:FlxText;
	var downPozition:FlxText;
	var leftPozition:FlxText;
	var rightPozition:FlxText;

	var inputvari:FlxText;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var controlitems:Array<String> = ['hitbox', 'right control', 'left control','keyboard','custom'];

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

		config = new Config();
		curSelected = config.getcontrolmode();

	    var exitbutton = new FlxUIButton(FlxG.width - 650, 50,"Exit", () -> {
			MusicBeatState.switchState(new OptionsState());	    	
	    });
		exitbutton.resize(125,50);
		exitbutton.setLabelFormat("VCR OSD Mono",24,FlxColor.BLACK,"center");
		add(exitbutton);		

		var savebutton = new FlxUIButton((exitbutton.x + exitbutton.width + 25), 50,"Save And Exit",() -> {
			save();
			MusicBeatState.switchState(new OptionsState());
		});
		savebutton.resize(250,50);
		savebutton.setLabelFormat("VCR OSD Mono",24,FlxColor.BLACK,"center");
		add(savebutton);

		_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
		_pad.alpha = 0;
		add(_pad);

		_hb = new Hitbox();
		_hb.visible = false;
		add(_hb);

		inputvari = new FlxText(125, 50, 0, controlitems[0], 48);
		add(inputvari);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		leftArrow = new FlxSprite(inputvari.x - 60,inputvari.y - 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(inputvari.x + inputvari.width + 10, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		add(rightArrow);

		upPozition = new FlxText(125, 200, 0,"Button Up X:" + _pad.buttonUp.x +" Y:" + _pad.buttonUp.y, 24);
		add(upPozition);

		downPozition = new FlxText(125, 250, 0,"Button Down X:" + _pad.buttonDown.x +" Y:" + _pad.buttonDown.y, 24);
		add(downPozition);

		leftPozition = new FlxText(125, 300, 0,"Button Left X:" + _pad.buttonLeft.x +" Y:" + _pad.buttonLeft.y, 24);
		add(leftPozition);

		rightPozition = new FlxText(125, 350, 0,"Button RIght x:" + _pad.buttonRight.x +" Y:" + _pad.buttonRight.y, 24);
		add(rightPozition);

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
			{
				_hb.visible = false;
				upPozition.visible = false;
				downPozition.visible = false;
				leftPozition.visible = false;
				rightPozition.visible = false;
			}

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
        if (curSelected == 'custom')
        {
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
					movebutton(touch, _pad.buttonUp);
				}
				
				if (_pad.buttonDown.justPressed) {
					movebutton(touch, _pad.buttonDown);
				}

				if (_pad.buttonRight.justPressed) {
					movebutton(touch, _pad.buttonRight);
				}

				if (_pad.buttonLeft.justPressed) {
					movebutton(touch, _pad.buttonLeft);
				}
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
		upPozition.text = "Button Up X:" + _pad.buttonUp.x +" Y:" + _pad.buttonUp.y;
		downPozition.text = "Button Down X:" + _pad.buttonDown.x +" Y:" + _pad.buttonDown.y;
		leftPozition.text = "Button Left X:" + _pad.buttonLeft.x +" Y:" + _pad.buttonLeft.y;
		rightPozition.text = "Button RIght x:" + _pad.buttonRight.x +" Y:" + _pad.buttonRight.y;
	}

	function save() {
		config.setcontrolmode(curSelected);
		
		if (curSelected == 'custom'){
			savecustom();
		}
	}

	function savecustom() {
		config.savecustom(_pad);
	}

	function loadcustom():Void{
		_pad = config.loadcustom(_pad);	
	}

	function resizebuttons(vpad:FlxVirtualPad, ?int:Int = 200) {
		for (button in vpad){
				button.setGraphicSize(260);
				button.updateHitbox();
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}
