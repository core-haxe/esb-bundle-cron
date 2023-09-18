package esb.bundles.core.cron;

import haxe.io.Bytes;
import esb.bundles.core.cron.externs.CronJob;
import esb.core.IBundle;
import esb.common.Uri;
import esb.core.IProducer;
import esb.logging.Logger;
import esb.core.Bus.*;
import esb.core.bodies.RawBody;

using StringTools;

// useful site for creating cron job strings: https://crontab.guru/

@:keep
class CronProducer implements IProducer {
    private static var log:Logger = new Logger("esb.bundles.core.cron.CronProducer");
    private static var jobContexts:Map<CronJob, JobContext> = [];

    public var bundle:IBundle;
    public function start(uri:Uri) {
        log.info('creating producer for ${uri.toString()}');

        var job = null;
        var pattern = uri.path;
        job = new CronJob(pattern, () -> {
            var context = jobContexts.get(job);
            var pattern = null;
            var payload = null;
            var domain = null;
            if (context != null) {
                pattern = context.pattern;
                payload = context.payload;
                domain = context.domain;
                log.info('cron job trigged, next trigger: ${job.nextDates()}, pattern: ${context.pattern}, domain: ${context.domain}, payload: ${context.payload}');
            } else {
                log.info('cron job trigged, next trigger: ${job.nextDates()}');
            }

            var message = createMessage(RawBody);
            if (pattern != null) {
                message.properties.set("cron.pattern", pattern);
            }
            if (domain != null) {
                message.properties.set("cron.domain", domain);
            }
            if (payload != null) {
                message.body.fromBytes(Bytes.ofString(payload));
            }
            to(uri, message).then(result -> {
            }, error -> {
                trace("error", error);
            });
        });
        jobContexts.set(job, {
            job: job,
            pattern: pattern,
            payload: uri.param("body"),
            domain: uri.domain
        });
        job.start();
        log.info('cron job started, next trigger: ${job.nextDates()}');
    }
}

typedef JobContext = {
    public var pattern:String;
    public var job:CronJob;
    public var payload:String;
    public var domain:String;
}