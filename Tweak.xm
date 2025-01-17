#import "Tweak.h"

BOOL lsEnabled = YES;
BOOL sbEnabled = YES;
double updateSpeed = 0.6;

NSString* getFormatted(bool seconds) {
    // code is bad but am lazy
    // convert to lightning
    // chatgpt moment

    // Get the current date and time
    NSDate *currentDate = [NSDate date];
    // Get the calendar and the current date components
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    // Create a new date object representing midnight (12:00 AM) today
    NSDate *midnightDate = [calendar dateFromComponents:components];
    // Calculate the time interval between now and midnight in seconds
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:midnightDate];
    // Convert timeInterval (seconds) to milliseconds and return it as a double
    double millis = timeInterval * 1000.0;

    // get the segments
    double totalCharges = (millis / 1318.359375);
    double totalSparks = totalCharges / 16;
    double totalZaps = totalSparks / 16;
    double totalBolts = totalZaps / 16;

    NSInteger charges = (NSInteger)(floor(totalCharges)) % 16;
    NSInteger sparks = (NSInteger)(floor(totalSparks)) % 16;
    NSInteger zaps = (NSInteger)(floor(totalZaps)) % 16;
    NSInteger bolts = (NSInteger)(floor(totalBolts)) % 16;

    // Convert to hex strings
    NSString *chargesHex = [NSString stringWithFormat:@"%lX", (long)charges];
    NSString *sparksHex = [NSString stringWithFormat:@"%lX", (long)sparks];
    NSString *zapsHex = [NSString stringWithFormat:@"%lX", (long)zaps];
    NSString *boltsHex = [NSString stringWithFormat:@"%lX", (long)bolts];

    // Concatenate the final lightning string
    if (seconds) {
        return [NSString stringWithFormat:@"%@~%@~%@|%@", boltsHex, zapsHex, sparksHex, chargesHex];
    } else {
        return [NSString stringWithFormat:@"%@~%@~%@", boltsHex, zapsHex, sparksHex];
    }
}

%hook CSProminentTimeView
- (id)_timeString {
    if (lsEnabled) return getFormatted(true);
    return %orig;
}
%end

%hook _UIStatusBarTimeItem
- (void)_create_timeView{
    %orig;
    self.timeView.litt_isTimeString = YES;
}

- (void)_create_shortTimeView{
    %orig;
    self.shortTimeView.litt_isTimeString = YES;
}

- (void)_create_pillTimeView{
    %orig;
    self.pillTimeView.litt_isTimeString = YES;
}
%end

%hook _UIStatusBarStringView
%property (nonatomic, assign) BOOL litt_isTimeString;

- (void)setText:(NSString *)text{
    if(self.litt_isTimeString){
        %orig(getFormatted(false));
        return;
    }
    %orig;
}
%end

%hook SBFLockScreenDateViewController // tesla_man
%property(nonatomic, strong) NSTimer *litt_timer;

- (void)_startUpdateTimer{
    %orig;
    NSDate *now = [NSDate date];
    double fractionalSeconds = fmod([now timeIntervalSince1970], updateSpeed);

    [self.litt_timer invalidate];
    self.litt_timer = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, fractionalSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{    
        self.litt_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeNow) userInfo:nil repeats:YES];
    });
}

- (void)_stopUpdateTimer{
    %orig;
    [self.litt_timer invalidate];
    self.litt_timer = nil;
}
%end

#define tweakPlist ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.leemin.lightningprefs.plist")

#define LISTEN_NOTIF(_call, _name) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)_call, CFSTR(_name), NULL, CFNotificationSuspensionBehaviorCoalesce);

 
void loadPrefs() {
    // Fetch the NSUserDefaults for your tweak
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.leemin.lightningprefs"];
    if (prefs) {
        lsEnabled = [prefs[@"lsEnabled"] boolValue];
        sbEnabled = [prefs[@"sbEnabled"] boolValue];
        updateSpeed = [prefs[@"updateFreq"] doubleValue];
    }
}

%ctor {
    loadPrefs();

    LISTEN_NOTIF(loadPrefs, "com.leemin.lightningprefs/reloadPrefs")	
}