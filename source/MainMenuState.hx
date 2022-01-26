package;

import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
//import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	/*public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];*/

	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<Alphabet>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'discord', 'credits', 'options'/*, 'troll'*/];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	/*var mustUpdate:Bool = false;
	public static var updateVersion:String = '';*/

	override public function create():Void
	{
		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end
		
		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			
			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}
			
			http.onError = function (error) {
				trace('error: $error');
			}
			
			http.request();
		}
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		// DEBUG BULLSHIT

		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
		}
		#end*/

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		//add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		//add(magenta);
		magenta.scrollFactor.set();

		var aurorga:FlxSprite = new FlxSprite();
		aurorga.frames = Paths.getSparrowAtlas('mainmenu/AuroraDemoMenu');
		aurorga.animation.addByPrefix('bop', 'why he standin like that', 24, true);
		aurorga.animation.play('bop');
		aurorga.updateHitbox();
		aurorga.screenCenter(X);
		add(aurorga);

		menuItems = new FlxTypedGroup<Alphabet>();
		add(menuItems);

		for (i in 0...optionShit.length) 
		{
			var newAlphabet:Alphabet = new Alphabet(0, 0, optionShit[i], true, false);
			newAlphabet.screenCenter();
			newAlphabet.x = 35;
			newAlphabet.y += (110 * (i - (optionShit.length / 2))) + 50;
			newAlphabet.alpha = 0.6;
			newAlphabet.ID = i;
			menuItems.add(newAlphabet);
		}

		menuItems.members[curSelected].alpha = 1;

		FlxG.camera.follow(camFollowPos, null, 1);

		/*for (i in 0...optionShit.length) //OLD MENU CODE
		{
			var menuItem:FlxSprite = new FlxSprite(0, 520);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.x += (1280 * i);
			//menuItem.y += 520;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(1, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
		}*/

		leftArrow = new FlxSprite();
		leftArrow.frames = Paths.getSparrowAtlas('mainmenu/leftArrow');
		leftArrow.animation.addByPrefix('idle', "left idle");
		leftArrow.animation.addByPrefix('press', "left press");
		leftArrow.updateHitbox();
		leftArrow.y += 500;
		leftArrow.animation.play('idle');
		leftArrow.screenCenter(X);
		leftArrow.x -= FlxG.width / 2.6;
		leftArrow.scrollFactor.set();
		//add(leftArrow);

		rightArrow = new FlxSprite();
		rightArrow.frames = Paths.getSparrowAtlas('mainmenu/rightArrow');
		rightArrow.animation.addByPrefix('idle', 'right idle');
		rightArrow.animation.addByPrefix('press', "right press");
		rightArrow.y += 500;
		rightArrow.animation.play('idle');
		rightArrow.screenCenter(X);
		rightArrow.x += FlxG.width / 2.6;
		rightArrow.scrollFactor.set();
		//add(rightArrow);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Troll Edition", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();

		updateSelection();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

                addVirtualPad(UP_DOWN, A_B);

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;
	var lastCurSelected:Int = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		//var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		//camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				//FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				//FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			/*if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');*/

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				/*if (optionShit[curSelected] == 'troll')
				{
					//if (ClientPrefs.flashing)
						//FlxFlicker.flicker(magenta, 1.1, 0.15, false);
					FlxG.sound.play(Paths.sound('confirmMenuBell'));
					CoolUtil.browserLoad('https://youtu.be/iaHr2dmUAfo');
					//FlxG.camera.flash(0xFFe0e0e0, 1.6);
				}
				else */if (optionShit[curSelected] == 'discord')
				{
					//if (ClientPrefs.flashing)
						//FlxFlicker.flicker(magenta, 1.1, 0.15, false);
					FlxG.sound.play(Paths.sound('confirmMenuBell'));
					CoolUtil.browserLoad('https://docs.google.com/document/d/19W-9DXnepN11LwaYJAbg8pZFZigrWRrJl5RoOtx6Oyo/edit');
					//FlxG.camera.flash(0xFF9271fd, 1.6);
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenuBell'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:Alphabet)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[Math.floor(curSelected)];

								switch (daChoice)
								{
									case 'story_mode':
										//FlxG.camera.fade(0xFFf9cf4f, 1.6, false);
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										//FlxG.camera.fade(0xFF9271fd, 1.6, false);
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										//FlxG.camera.fade(0xFFf9cf4f, 1.6, false);
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										//FlxG.camera.fade(0xFFe0e0e0, 1.6, false);
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										//FlxG.camera.fade(0xFFfd719b, 1.6, false);
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}

			if (Math.floor(curSelected) != lastCurSelected)
				updateSelection();
			
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

	}

	function changeItem(huh:Int = 0) 
	{
		curSelected += huh;
		if (curSelected < 0)
			curSelected = optionShit.length - 1;
		if (curSelected >= optionShit.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in menuItems.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
	}

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxSprite) {spr.alpha = 0.6;});
		
		// set the sprites and all of the current selection
		menuItems.members[curSelected].alpha = 1;
		lastCurSelected = Math.floor(curSelected);
	}
}
