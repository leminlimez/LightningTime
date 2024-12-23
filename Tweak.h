// Importing the necessary headers for UIKit, custom rootless header, Foundation, CoreFoundation, and SpringBoard.
#import <UIKit/UIKit.h>
#import "rootless.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SpringBoard/SpringBoard.h>
#import <objc/runtime.h>
#import <substrate.h>

@interface _UIStatusBarDataStringEntry : NSObject
@property (nonatomic, assign) BOOL litt_isTimeEntry;
@property (nonatomic, copy, readwrite) NSString *stringValue;
@end

@interface _UIStatusBarData : NSObject
@property (copy, nonatomic) _UIStatusBarDataStringEntry *timeEntry;
@property (copy, nonatomic) _UIStatusBarDataStringEntry *shortTimeEntry;
- (void)applyIsTimeEntryToTimesEntries;
@end

@interface SBFLockScreenDateViewController : UIViewController
@property(nonatomic, strong) NSTimer *litt_timer;
@end