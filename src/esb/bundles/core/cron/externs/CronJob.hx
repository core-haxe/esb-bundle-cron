package esb.bundles.core.cron.externs;

@:jsRequire("cron", "CronJob")
extern class CronJob {
    public function nextDates():Array<Dynamic>;
    public function lastDate():Dynamic;
    public function new(cronTime:String, onTick:Dynamic, onComplete:Dynamic = null, start:Bool = false, timeZone:String = null, context:Dynamic = null, runOnInit:Bool = false, utcOffset:Int = null, unrefTimeout:Dynamic = false);
    public function start():Void;
    public function stop():Void;
}