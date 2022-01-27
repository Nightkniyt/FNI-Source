package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import sys.FileSystem;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Dynamic> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		trace("finding mod shit");
		if (FileSystem.exists(Paths.mods())) {
			trace("mods folder");
			if (FileSystem.exists(Paths.modFolders("data/credits.txt"))){
				trace("credit file");
				var firstarray:Array<String> = CoolUtil.coolTextFile(Paths.modFolders("data/credits.txt"));
				trace("found credit shit");
				
				for(i in firstarray){
					var arr:Array<String> = i.split("::");
					trace(arr);
					creditsStuff.push(arr);
				}
			}
		}
		
		#end
		var pisspoop = [ //Name - Icon name - Description - Link - BG Color
		['Android Port'],
		['Saw (M.A. Jigsaw)','trollface','The Friday Night Incident\nAndroid Port Main Coder','https://www.youtube.com/channel/UC2Sk7vtPzOvbVzdVTWrribQ','0xFFFF0000'],
		['Friday Night Incident Team'],
		['Arthur / ADJ',  'trollface',		 'Mr. Trololo/Aurora Sprites\nDirector',						   'https://twitter.com/AdjDraws',							'0xFFFFFF00'],
		['KGBepis',		  'trollface',		 'Background Artist',							   'https://twitter.com/kgbepis',									    '0xFF5B15FF'],
		['Fore',		  'trollface',		 'Week 1 Cutscene & Week 2 Boyfriend Artist',								   'https://twitter.com/Fore_8040',					    '0xFFFF1AE0'],
		['BAnims',	      'trollface',		 'Eduard.PNG Sprites',			             	   'https://twitter.com/BAnims_the2nd',												'0xFF0B0D3C'],
		['FalseCow',	      'trollface',		 'Aurora Jumpscare Artist',	                 'https://twitter.com/FalseCow'	,										'0xFF0B0D3C'],
		['Julianlikeaboss',	      'trollface',		 'Pibby T Artist',					'0xFF0B0D3C'],
		['MysteryHarry',	  'trollface',		 'Week 2 Cutscene Artist',				   'https://twitter.com/MysteryHarry56',												'0xFF0B0D3C'],
		['the yornder303',      'trollface',       'Week 2 Cutscene Background Artist',									   'https://twitter.com/yornder303',			    '0xFF841984'],
		['FireDemonWalker',      'trollface',       'Week 2 Cutscene Background Artist',									   'https://twitter.com/FireDemonWalker',	    '0xFF841984'],
		['Big Soda',      'trollchad',       'Main Coder',									   'https://twitter.com/Nightkniyt',								    '0xFF841984'],
		['Salted Sporks', 'trollface',		 'Trollmogus Artist\nGlad, Prepare and Yoinky Sploinky Composer','https://twitter.com/saltedsporks',							'0xFFFF74E0'],
		['Saruky',		  'trollface',		 'Evacuate Composer',						   'https://twitter.com/Saruky__',										'0xFFFF004F'],
		['Sawsk',		  'trollface',		 'Reminisce Composer',			   'https://www.youtube.com/channel/UCn4y5CKpgsCyp0KO7R-KBGg/channels', 	'0xFFFF0000'],
		['Armydillo',		  'trollface',		 'Aurora Composer',			   'https://twitter.com/Armydilloiscool', 	'0xFFFF0000'],
		['Kitsune*2',		  'trollface',		 'Rainbow Tylenol Composer',			   'https://www.youtube.com/watch?v=5K7Frc2lTI8', '0xFF0B0D3C'],
		['EnigmaEvocative',		  'trollface',		 'Rainbow Trololo Composer',			   'https://www.youtube.com/watch?v=1Wytn-_MSBo', '0xFF0B0D3C'],
		['Iro',			  'trollface',		 'Charter',						   'https://twitter.com/HowManyIros',								    '0xFF89EF40'],
		['Sumii',  'trollface',		 'Charter',								   'https://twitter.com/SumiiMG_',											    '0xFF0000FF'],
		['niffirg',  'trollface',		 'Charter',								   'https://twitter.com/n1ffirg',											    '0xFF0000FF'],
		['Active777',	  'trollface',		 'Charter',								   'https://twitter.com/Active7772',								    '0xFFA01F1F'],
		['Wilde',		  'trollface',		 'Charter',							   'https://twitter.com/0WildeRaze',								    '0xFFFF1E00'],
		['Schmoe',	  'trollface',		 'Boyfriend Voice Actor', 			'0xFF0B0D3C'],
		['Freddie Heinz', 'trollface',		 'Baki BF Voice Actor',							   'https://twitter.com/freddie_heinz?s=21',									    '0xFF5B15FF'],
		['Angelattes',	  'trollface',		 'Girlfriend Voice Actress',								   'https://twitter.com/angelattesart',								    '0xFF8A061A'],
		['Mr. Amazing VA','trollface',		 'Mr Trololo Voice Actor',								   'https://twitter.com/MrAmazingVA',								    '0xFF59280D'],
		['Audiospawn',	  'trollface',		 'Trollge Voice Actor',									   'https://twitter.com/Audiospawned',									'0xFF808080'],
		['RushMavrick',	  'trollface',		 'Screaming Tree Voice Actor',									   'https://twitter.com/Rush_Maverick',							'0xFF808080'],
		[''],
		['Special Thanks'],
		['Banbuds',	      'trollchad',		 'Original Trollge Concept/Art',				   'https://twitter.com/Banbuds',								    '0xFF808080'],
		['Shmooify',	      'trollchad',	 'Screaming Tree Creator\nAssistance',			   'https://www.youtube.com/channel/UCgA9B3XCC65B9p4s1GngW5A',		   '0xFF8A061A'],
		['Daniel',	      'trollchad',		 'Assistance',								  	   'https://twitter.com/soulja_daniel',								    '0xFF8A061A'],
		['Balloon',		'trollchad',		 'Assistance',								  	   'https://twitter.com/Balloon84195471',								    '0xFF59280D'],
		['Gartalick',	  'trollchad',		 'Assistance',									   'https://twitter.com/GatalickGun',									'0xFF808080']
	];
		
		
				for(i in pisspoop){
					creditsStuff.push(i);
				}
			
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = Std.parseInt(creditsStuff[curSelected][4]);
		intendedColor = bg.color;
		changeSelection();

                addVirtualPad(UP_DOWN, A_B);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  Std.parseInt(creditsStuff[curSelected][4]);
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
