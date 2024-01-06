#import "NotificationTesterPrefs.h"
#import <rootless.h>

@implementation NotificationTesterPrefsListController

- (id)readPreferenceValue:(PSSpecifier *)specifier {
	NSDictionary *karenPrefsPlist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:ROOT_PATH_NS_VAR(@"/User/Library/Preferences/%@.plist"), [specifier.properties objectForKey:@"defaults"]]];
	if (![karenPrefsPlist objectForKey:[specifier.properties objectForKey:@"key"]]) {
		return [specifier.properties objectForKey:@"default"];
	}
	return [karenPrefsPlist objectForKey:[specifier.properties objectForKey:@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSMutableDictionary *karenPrefsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:ROOT_PATH_NS_VAR(@"/User/Library/Preferences/%@.plist"), [specifier.properties objectForKey:@"defaults"]]];
	[karenPrefsPlist setObject:value forKey:[specifier.properties objectForKey:@"key"]];
	[karenPrefsPlist writeToFile:[NSString stringWithFormat:ROOT_PATH_NS_VAR(@"/User/Library/Preferences/%@.plist"), [specifier.properties objectForKey:@"defaults"]] atomically:1];
	if ([specifier.properties objectForKey:@"PostNotification"]) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)[specifier.properties objectForKey:@"PostNotification"], NULL, NULL, YES);
	}
	[super setPreferenceValue:value specifier:specifier];
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"NotificationTesterPrefs" target:self];
	}
	return _specifiers;
}

- (void)lockscreenNotification {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("nl.d4ni.notificationtester/ls"), nil, nil, true);
}

- (void)normalNotification {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("nl.d4ni.notificationtester/nc"), nil, nil, true);
}

-(void)save {
  [self.view endEditing:YES];
}

@end

// vim:ft=objc
