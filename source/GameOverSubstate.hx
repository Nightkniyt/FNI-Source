package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	public var aurora:FlxSprite;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;

		if (PlayState.SONG.player1 == 'bf-scared')
		{
			bf = new Boyfriend(x, y, 'bf-scared');
			add(bf);
			FlxG.sound.play(Paths.sound(deathSoundName + '-trollge'));
		}
		//if (PlayState.SONG.player1 == 'bf-angry')
		//{
		//	FlxG.sound.play(Paths.sound(deathSoundName + '-trollge'));
		//}
		if (PlayState.SONG.player1 != 'bf-angry' && PlayState.SONG.player1 != 'bf-scared')
		{
			bf = new Boyfriend(x, y, characterName);
			add(bf);
			FlxG.sound.play(Paths.sound(deathSoundName));
		}

		aurora = new FlxSprite().loadGraphic(Paths.image('auroraGameOver'));
		aurora.setGraphicSize(Std.int(FlxG.width * 1.75), Std.int(FlxG.height * 1.75));
		//aurora.screenCenter(XY);
		aurora.x = -500;
		aurora.y = -300;
		aurora.updateHitbox();
		aurora.alpha = 0;
		//aurora.cameras = [camHUD];
		add(aurora);

		if (PlayState.SONG.player1 != 'bf-angry')
			camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		if (PlayState.SONG.player1 != 'bf-angry')
			bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			lePlayState.callOnLuas('onGameOverConfirm', [false]);
		}
		if (PlayState.SONG.player1 != 'bf-angry')
		{
			if (bf.animation.curAnim.name == 'firstDeath')
			{
				if(bf.animation.curAnim.curFrame == 12)
				{
					FlxG.camera.follow(camFollowPos, LOCKON, 1);
					updateCamera = true;
				}

				if(bf.animation.curAnim.finished)
				{
					coolStartDeath();
					bf.startedDeath = true;
				}
			}
		}
		if (PlayState.SONG.player1 == 'bf-angry')
		{
			coolStartDeath();
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		if (PlayState.SONG.player1 == 'bf-angry')
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxTween.tween(aurora, {alpha: 1}, 2);
				});
			//FlxG.sound.playMusic(Paths.music(loopSoundName + '-trollge'), volume);
		}
		if (PlayState.SONG.player1 == 'bf-scared')
			FlxG.sound.playMusic(Paths.music(loopSoundName + '-trollge'), volume);
		else
			FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			if (PlayState.SONG.player1 == 'bf-angry')
				FlxG.sound.play(Paths.music(endSoundName + '-trollge'));
			if (PlayState.SONG.player1 == 'bf-scared')
			{
				FlxG.sound.play(Paths.music(endSoundName + '-trollge'));
				bf.playAnim('deathConfirm', true);
			}
			if (PlayState.SONG.player1 != 'bf-angry' && PlayState.SONG.player1 != 'bf-scared')
			{
				FlxG.sound.play(Paths.music(endSoundName));
				bf.playAnim('deathConfirm', true);
			}
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
