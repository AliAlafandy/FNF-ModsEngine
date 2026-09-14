#if !macro
//Discord API
#if DISCORD_ALLOWED
import funkin.data.backend.Discord;
#end

//Scripts
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if ACHIEVEMENTS_ALLOWED
import funkin.data.backend.Achievements;
#end

//Mobile Controls
import mobile.funkin.data.objects.MobileControls;
import mobile.funkin.data.objects.IMobileControls;
import mobile.funkin.data.objects.Hitbox;
import mobile.funkin.data.objects.TouchPad;
import mobile.funkin.data.objects.TouchButton;

import mobile.engine.input.MobileInputID;
import mobile.funkin.data.backend.MobileData;
import mobile.engine.input.MobileInputManager;

import mobile.funkin.data.backend.TouchUtil;

// Android
#if android
import android.content.Context as AndroidContext;
import android.widget.Toast as AndroidToast;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.Settings as AndroidSettings;
import android.Tools as AndroidTools;
import android.os.Build.VERSION as AndroidVersion;
import android.os.Build.VERSION_CODES as AndroidVersionCode;
import android.os.BatteryManager as AndroidBatteryManager;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import funkin.data.backend.Paths;
import funkin.data.backend.Controls;
import funkin.data.backend.CoolUtil;
import funkin.data.backend.MusicBeatState;
import funkin.data.backend.MusicBeatSubstate;
import funkin.data.backend.CustomFadeTransition;
import funkin.data.backend.ClientPrefs;
import funkin.data.backend.Conductor;
import funkin.data.backend.BaseStage;
import funkin.data.backend.Difficulty;
import funkin.data.backend.Mods;

import mobile.funkin.data.backend.StorageUtil;

import funkin.data.objects.Alphabet;
import funkin.data.objects.BGSprite;

import funkin.states.PlayState;

#if NO_PRELOAD_ALL
import funkin.states.LoadingState;
#end

#if flxanimate
import flxanimate.*;
#end

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import shaders.flixel.system.FlxShader;

using StringTools;
#end
