package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxMath;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = 0;

	var scoreText:FlxText;
	var diffText:FlxText;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var player:MusicPlayer;

	override function create()
	{
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		for (weekName in WeekData.weeksList)
		{
			if (weekIsLocked(weekName)) continue;

			var week = WeekData.weeksLoaded.get(weekName);
			WeekData.setDirectoryFromWeek(week);

			for (song in week.songs)
			{
				var col = song[2];
				if (col == null || col.length < 3)
					col = [146, 113, 253];

				addSong(song[0], week.weeks.indexOf(weekName), song[1],
					FlxColor.fromRGB(col[0], col[1], col[2]));
			}
		}
		WeekData.setDirectoryFromWeek();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(bg);

		var grid = new FlxBackdrop(
			FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF)
		);
		grid.velocity.set(40, 40);
		grid.alpha = 0.4;
		add(grid);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var item = new Alphabet(0, 0, songs[i].songName, true, true);
			item.isMenuItem = true;
			item.targetY = i;

			item.screenCenter(X);
			item.y = FlxG.height / 2;
			item.snapToPosition();

			grpSongs.add(item);

			var icon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = item;
			iconArray.push(icon);
			add(icon);

			item.visible = false;
			item.active = false;
			icon.visible = false;
			icon.active = false;
		}

		scoreText = new FlxText(0, 10, FlxG.width, "", 28);
		scoreText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER);
		add(scoreText);

		diffText = new FlxText(0, 44, FlxG.width, "", 22);
		diffText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER);
		add(diffText);

		player = new MusicPlayer(this);
		add(player);

		if (curSelected >= songs.length) curSelected = 0;

		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		changeSelection(0, false);
		super.create();
	}

	inline function unselectableCheck(i:Int):Bool
	{
		if (i < 0 || i >= songs.length) return true;
		return !Song.doesSongExist(Paths.formatToSongPath(songs[i].songName));
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0) curSelected = songs.length - 1;
		if (curSelected >= songs.length) curSelected = 0;

		bg.color = songs[curSelected].color;

		diffText.text = '< ' + Difficulty.getString(curDifficulty).toUpperCase() + ' >';
		scoreText.text = 'PERSONAL BEST: ' +
			Highscore.getScore(songs[curSelected].songName, curDifficulty);
	}

	override function update(elapsed:Float)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 10));

		for (i in 0...grpSongs.members.length)
		{
			var item = grpSongs.members[i];
			var dist = i - lerpSelected;

			item.visible = Math.abs(dist) <= 4;
			item.active = item.visible;

			if (item.visible)
			{
				item.screenCenter(X);
				item.y = (FlxG.height / 2) + dist * 70;
				item.alpha = (i == curSelected) ? 1 : 0.6;

				var icon = iconArray[i];
				icon.visible = true;
				icon.active = true;
				icon.alpha = item.alpha;
			}
		}

		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);

		super.update(elapsed);
	}

	function weekIsLocked(name:String):Bool
	{
		var w = WeekData.weeksLoaded.get(name);
		return !w.startUnlocked && w.weekBefore.length > 0 &&
			(!StoryMenuState.weekCompleted.exists(w.weekBefore)
			|| !StoryMenuState.weekCompleted.get(w.weekBefore));
	}

	public function addSong(song:String, week:Int, char:String, color:Int)
	{
		songs.push(new SongMetadata(song, week, char, color));
	}
}

class SongMetadata
{
	public var songName:String;
	public var week:Int;
	public var songCharacter:String;
	public var color:Int;
	public var folder:String;

	public function new(song:String, week:Int, char:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = char;
		this.color = color;
		this.folder = Mods.currentModDirectory != null ? Mods.currentModDirectory : '';
	}
}
