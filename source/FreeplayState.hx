package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import lime.net.curl.CURLCode;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var weekThing:FlxSprite;
	var difficultyText:FlxSprite;
	var backspace:FlxSprite;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var sprDifficulty:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var colorTween:FlxTween;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(true);
		#if desktop
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
		persistentUpdate = persistentDraw = true;

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.setDirectoryFromWeek();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bg = new FlxSprite(0, 0);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		weekThing = new FlxSprite(0, 0);
		weekThing.antialiasing = ClientPrefs.globalAntialiasing;
		add(weekThing);

		backspace = new FlxSprite(-90, -15).loadGraphic(Paths.image('menuUI/backspace'));
		backspace.setGraphicSize(Std.int(backspace.width * 0.5));
		backspace.antialiasing = ClientPrefs.globalAntialiasing;
		add(backspace);

		difficultyText = new FlxSprite(-65, 440).loadGraphic(Paths.image('menuUI/difficultyText'));
		difficultyText.setGraphicSize(Std.int(difficultyText.width * 0.6));
		difficultyText.antialiasing = ClientPrefs.globalAntialiasing;

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);

		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 46, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(scoreText);

		if(curSelected >= songs.length) 
			curSelected = 0;

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(70, 575);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.setGraphicSize(Std.int(leftArrow.width * 1.25));
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);

		
		for (i in 0...CoolUtil.difficultyStuff.length) {
			sprDifficulty = new FlxSprite(leftArrow.x + 115, leftArrow.y + 190).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.setGraphicSize(Std.int(sprDifficulty.width * 0.5));
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
		}

		add(difficultyText);
		
		changeSelection();
		changeDiff();

		difficultySelectors.add(sprDifficultyGroup);

		rightArrow = new FlxSprite(leftArrow.x + 500, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.setGraphicSize(Std.int(rightArrow.width * 1.25));
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 20, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen / Press RESET to Reset your Score and Accuracy.";
		#else
		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

                addVirtualPad(FULL, A_B_X_Y);

		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE#if android || _virtualpad.buttonX.justPressed #end;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);
		if (controls.UI_RIGHT)
			rightArrow.animation.play('press')
		else
			rightArrow.animation.play('idle');

		if (controls.UI_LEFT)
			leftArrow.animation.play('press');
		else
			leftArrow.animation.play('idle');
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		#if PRELOAD_ALL
		if(space && instPlaying != curSelected)
		{
			destroyFreeplayVocals();
			Paths.currentModDirectory = songs[curSelected].folder;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			if (PlayState.SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(vocals);
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			vocals.play();
			vocals.persist = true;
			vocals.looped = true;
			vocals.volume = 0.7;
			instPlaying = curSelected;
		}
		else #end if (accepted)
		{
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET#if android || _virtualpad.buttonY.justPressed #end)
		{
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			//FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		sprDifficultyGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			if(curDifficulty == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				spr.y = leftArrow.y - 100;
				FlxTween.tween(spr, {y: leftArrow.y - 80, alpha: 1}, 0.02);
			}
		});

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		positionHighscore();
	}

	function changeSelection(change:Int = 0):Void
	{

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curSelected]);
		WeekData.setDirectoryFromWeek(leWeek);
		
		//whoever reads this, please enjoy my 200000000000000 IQ play here -- ik it sucks lol

		var poop:String = '';
		var pee:String = '';

		switch (songs[curSelected].songCharacter)
		{
			case 'trollge':
				pee = 'trollge';
				poop = 'trollge';
			case 'aurora':
				pee = 'forest';
				poop = 'monsters';
			case 'pibbyt':
				pee = 'void';
				poop = 'him';
			case 'eduard':
				pee = 'susstage';
				poop = 'eduard';
			case 'trollmogus':
				pee = 'susstage';
				poop = 'trollmogus';
			default:
				pee = 'stage';
				poop = 'mrtrololo';
    	}
		bg.loadGraphic(Paths.image('menubackgrounds/menu_' + pee));
		weekThing.loadGraphic(Paths.image('menuUI/' + poop));

		bg.alpha = 0;
		weekThing.alpha = 0;
		//difficultyText.alpha = 0;
		//leftArrow.alpha = 0;
		//rightArrow.alpha = 0;
		//sprDifficulty.alpha = 0;
		//backspace.alpha = 0;
		bg.y = -100;
		weekThing.y = -100;
		//difficultyText.y = -100;
		//leftArrow.y = -100;
		//rightArrow.y = -100;
		//sprDifficulty.y = -100;
		//backspace.y = -100;
		FlxTween.tween(bg, {y: 0, alpha: 1}, 0.2);
		FlxTween.tween(weekThing, {y: 0, alpha: 1}, 0.2);
		//FlxTween.tween(difficultyText, {y: 0, alpha: 1}, 0.2);
		//FlxTween.tween(leftArrow, {y: 0, alpha: 1}, 0.2);
		//FlxTween.tween(rightArrow, {y: 0, alpha: 1}, 0.2);
		//FlxTween.tween(sprDifficulty, {y: 0, alpha: 1}, 0.2);
		//FlxTween.tween(backspace, {y: 0, alpha: 1}, 0.2);
		
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0;
		}

		iconArray[curSelected].alpha = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0;
			if (item.targetY == 0)
				FlxTween.tween(item, {alpha: 1}, 0.2);
		}
		changeDiff();
		Paths.currentModDirectory = songs[curSelected].folder;
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
