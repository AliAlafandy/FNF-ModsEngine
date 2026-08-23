package funk;

import openfl.Assets;
import mobile.backend.StorageUtil;
#if sys
import sys.FileSystem;
import sys.FileStat;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
#end

using StringTools;

/**
 * Unified file class that works with both native file access and OpenFL assets.
 * @see https://github.com/Psych-Slice/P-Slice/blob/master/source/mikolka/funkin/custom/NativeFileSystem.hx
 */
class ModsEngineFile {
	inline static function cwd(path:String):String {
		/*#if android
		return StorageUtil.getExternalStorageDirectory();
		#else*/
		if (path.startsWith(Sys.getCwd()) /*|| path.startsWith(Paths.mods())*/)
			return path;
		else
			return Sys.getCwd() + path;
        //#end
	}

	static function openflcwd(path:String):String {
		@:privateAccess
		for (library in lime.utils.Assets.libraries.keys())
		{
			if (Assets.exists('$library:$path') && !path.startsWith('$library:'))
				return '$library:$path';
		}

		return path;
	}

	public static function getContent(path:String):String {
		#if sys
		if (FileSystem.exists(cwd(path)))
			return File.getContent(cwd(path));
		#end

		return Assets.getText(openflcwd(path));
	}

	public static function getBytes(path:String):haxe.io.Bytes {
		#if sys
		if (FileSystem.exists(cwd(path)))
			return File.getBytes(cwd(path));
		#end

		switch (haxe.io.Path.extension(path).toLowerCase()) {
			case 'otf' | 'ttf':
				return openfl.utils.ByteArray.fromFile(openflcwd(path));
			default:
				return Assets.getBytes(openflcwd(path));
		}
	}

	public static function saveContent(path:String, content:String):Void {
		#if sys
        File.saveContent(cwd(path), content);
        #end
	}

	public static function saveBytes(path:String, bytes:haxe.io.Bytes):Void {
		#if sys
        File.saveBytes(cwd(path), bytes);
        #end
	}

	public static function read(path:String, binary:Bool = true):Null<FileInput> {
		#if sys
        return File.read(cwd(path), binary);
        #else
        return null;
        #end
	}

	public static function write(path:String, binary:Bool = true):Null<FileOutput> {
		#if sys
        return File.write(cwd(path), binary);
        #else
        return null;
        #end
	}

	public static function append(path:String, binary:Bool = true):Null<FileOutput> {
        #if sys
        return File.append(cwd(path), binary);
        #else
        return null;
        #end
	}

	public static function update(path:String, binary:Bool = true):Null<FileOutput> {
		#if sys
        return File.update(cwd(path), binary);
        #else
        return null;
        #end
	}

	public static function copy(srcPath:String, dstPath:String):Void {
		#if sys
        File.copy(cwd(srcPath), cwd(dstPath));
        #end
	}

	public static function getBitmapData(path:String):openfl.display.BitmapData {
    #if sys
    if (FileSystem.exists(cwd(path)))
        return openfl.display.BitmapData.fromFile(cwd(path));
    #end

    var openflPath = openflcwd(path);
    if (Assets.exists(openflPath, IMAGE)) {
        return Assets.getBitmapData(openflPath);
    }
    
    return null;
	}
}