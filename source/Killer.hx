package;

import flixel.FlxG;
import flixel.FlxSubState;
import lime.app.Application;

class Killer extends PlayState
{
	override function create()
	{
		super.create();
		Sys.exit(0);
	}

	override function update(elapsed:Float)
	{

	}
}
