#import "headers.h"
#import "sqlite3.h"
#import "Globals.h"

extern dispatch_queue_t __BBServerQueue;
static BBServer* bbServer;

%hook BBServer
- (instancetype)initWithQueue:(id)arg1 {
	bbServer = %orig;
	return bbServer;
}

- (void)dealloc {
	if (bbServer == self) bbServer = nil;
	%orig;
}
%end

@implementation NotificationTester
//Query application list from applications database and filter out apple identifiers
+ (NSString *)randomID {
	NSMutableArray * applications = [[NSMutableArray alloc] init];
	NSString *filePath = @"/private/var/mobile/Library/FrontBoard/applicationState.db";
	sqlite3* db = NULL;
	sqlite3_stmt* stmt = NULL;
	int rc = 0;
	rc = sqlite3_open_v2([filePath UTF8String], &db, SQLITE_OPEN_READONLY , NULL);
	if (SQLITE_OK != rc) {
		sqlite3_close(db);
	}
	else {
		NSString  * query = @"SELECT * from application_identifier_tab";
		rc = sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt, NULL);
		if(rc == SQLITE_OK) {
			while (sqlite3_step(stmt) == SQLITE_ROW) {
				NSString * name =[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];

				NSDictionary *app = [NSDictionary dictionaryWithObjectsAndKeys:name,@"id", nil];
				if (![excludedApps containsObject:name]) {
					[applications addObject:app];
				}
			}
			sqlite3_finalize(stmt);
		}
		sqlite3_close(db);
	}
	return [[applications objectAtIndex:arc4random() % [applications count]] valueForKey:@"id"];
}

+ (void)lockscreenNotification{
	[[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];

	for (int i = 0; i < customAmount; i++) {
		if (randomApps) {
			bundleID = [self randomID];
		}

		BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];
		bulletin.title = [NSString stringWithFormat:@"Test %d", i];
		bulletin.message = customText;
		bulletin.sectionID = bundleID;
		bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
		bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
		bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
		bulletin.date = [NSDate new];
		bulletin.clearable = YES;
		bulletin.showsMessagePreview = YES;

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			if(bbServer){
				dispatch_sync(__BBServerQueue, ^{
					[bbServer publishBulletin:bulletin destinations:4];
				});
			}
		});
	}
}

+ (void)normalNotification {
	for (int i = 0; i < customAmount; i++) {
		if (randomApps) {
			bundleID = [self randomID];
		}

		BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];
		bulletin.title = [NSString stringWithFormat:@"Test %d", i];
		bulletin.message = customText;
		bulletin.sectionID = bundleID;
		bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
		bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
		bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
		bulletin.date = [NSDate new];
		bulletin.clearable = YES;
		bulletin.showsMessagePreview = YES;

		if(bbServer){
			dispatch_sync(__BBServerQueue, ^{
				[bbServer publishBulletin:bulletin destinations:15];
			});
		}
	}
}

@end

static void lsNotificationCallBack() {
	[NotificationTester lockscreenNotification];
}

static void ncNotificationCallBack() {
	[NotificationTester normalNotification];
}

//Load preferences
static void loadPrefs() {
		NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefBundle];
		if(prefs) {
			customText = ( [prefs objectForKey:@"customText"] ? [prefs objectForKey:@"customText"] : customText );
			customAmount = ( [prefs objectForKey:@"customAmount"] ? [[prefs objectForKey:@"customAmount"] intValue] : customAmount );
			randomApps = ( [prefs objectForKey:@"randomApps"] ? [[prefs objectForKey:@"randomApps"] boolValue] : randomApps );
			if ([customText isEqualToString:@""]) {
				customText = @"This is a mighty fine Test Notification!";
			}
		}
}

//Initialize event listeners and load preferences.
%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)lsNotificationCallBack, CFSTR("nl.d4ni.notificationtester/ls"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ncNotificationCallBack, CFSTR("nl.d4ni.notificationtester/nc"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("nl.d4ni.notificationtester/changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadPrefs();
}
