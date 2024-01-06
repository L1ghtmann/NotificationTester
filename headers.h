@import UIKit;

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
-(void)lockUIFromSource:(int)arg1 withOptions:(id)arg2;
@end

@interface BBBulletin : NSObject
@property (nonatomic, copy) NSString* sectionID;
@property (nonatomic, copy) NSString* bulletinID;
@property (nonatomic, copy) NSString* recordID;
@property (nonatomic, copy) NSString* publisherBulletinID;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, retain) NSDate* date;
@property (assign, nonatomic) BOOL clearable;
@property (nonatomic) BOOL showsMessagePreview;
@end

@interface BBServer : NSObject
-(void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
-(id)initWithQueue:(id)arg1;
-(void)dealloc;
@end

@interface NotificationTester : NSObject
+ (NSString *)randomID;
+ (void)lockscreenNotification;
+ (void)normalNotification;
@end
