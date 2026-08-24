package backend;

import openfl.events.UncaughtErrorEvent;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;
using flixel.util.FlxArrayUtil;

/**
 * Crash Handler & Trace Logger.
 * @author YoshiCrafter29, Ne_Eo, MAJigsaw77, Lily Ross (mcagabe19) & Alafandy
 */
class CrashHandler
{
    private static var traceBuffer:Array<String> = [];
    private static var maxBufferLines:Int = 500;

    public static function init():Void
    {
        var oldTrace = haxe.Log.trace;
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos)
        {
            oldTrace(v, infos); 
            
            var logMessage = '[TRACE] ${infos != null ? infos.fileName + ":" + infos.lineNumber : ""}: $v';
            addToBuffer(logMessage);
        };

        openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
        #if cpp
        untyped __global__.__hxcpp_set_critical_error_handler(onError);
        #elseif hl
        hl.Api.setErrorHandler(onError);
        #end
    }

    private static function addToBuffer(text:String):Void
    {
        traceBuffer.push(text);
        if (traceBuffer.length > maxBufferLines)
            traceBuffer.shift();

        #if sys
        saveLogFile();
        #end
    }

    private static function onUncaughtError(e:UncaughtErrorEvent):Void
    {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        var m:String = e.error;
        if (Std.isOfType(e.error, Error))
        {
            var err = cast(e.error, Error);
            m = '${err.message}';
        }
        else if (Std.isOfType(e.error, ErrorEvent))
        {
            var err = cast(e.error, ErrorEvent);
            m = '${err.text}';
        }
        var stack = haxe.CallStack.exceptionStack();
        var stackLabelArr:Array<String> = [];
        var stackLabel:String = "";
        for (e in stack)
        {
            switch (e)
            {
                case CFunction:
                    stackLabelArr.push("Non-Haxe (C) Function");
                case Module(c):
                    stackLabelArr.push('Module ${c}');
                case FilePos(parent, file, line, col):
                    switch (parent)
                    {
                        case Method(cla, func):
                            stackLabelArr.push('${file.replace('.hx', '')}.$func() [line $line]');
                        case _:
                            stackLabelArr.push('${file.replace('.hx', '')} [line $line]');
                    }
                case LocalFunction(v):
                    stackLabelArr.push('Local Function ${v}');
                case Method(cl, m):
                    stackLabelArr.push('${cl} - ${m}');
            }
        }
        stackLabel = stackLabelArr.join('\r\n');

        #if sys
        addToBuffer('\n--- CRASH DETECTED ---\n$m\n$stackLabel');
        #end

        CoolUtil.showPopUp('$m\n$stackLabel', "Error!");
        #if DISCORD_ALLOWED DiscordClient.shutdown(); #end
        lime.system.System.exit(1);
    }

    #if (cpp || hl)
    private static function onError(message:Dynamic):Void
    {
        final log:Array<String> = [];

        if (message != null && message.length > 0)
            log.push(message);

        log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack(true)));

        #if sys
        addToBuffer('\n--- CRITICAL ERROR ---\n' + log.join('\n'));
        #end

        CoolUtil.showPopUp(log.join('\n'), "Critical Error!");
        #if DISCORD_ALLOWED DiscordClient.shutdown(); #end
        lime.system.System.exit(1);
    }
    #end

    #if sys
    private static function saveLogFile():Void
    {
        try
        {
            if (!FileSystem.exists('logs'))
                FileSystem.createDirectory('logs');

            File.saveContent('logs/Trace_Logs.txt', traceBuffer.join('\n'));
        }
        catch (e:haxe.Exception)
        {
        }
    }
    #end
}