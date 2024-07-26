#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "LibLockscreen.h"
#import "SetupLSViewManager.h"
#import "NSString+Localize.h"





@interface SetupLS : NSObject <LibLockscreen>{
  UILabel *timeLabel;
}
@property (nonatomic, assign) UIView *view; //Set this up in the init method. This is your view that is going to be the new lockscreen. 
@property (nonatomic, assign) LibLSController* controller; //Has some API you can use to perform actions or get information
@property (nonatomic, assign) SetupLSViewManager *vManager;
@property (nonatomic, assign) UIImageView *blurOverlay; //Like magic, it lets things blur so smoothly? 
-(id)initWithController:(LibLSController*)controller; //Required
-(float)liblsVersion; //Required
-(void)unlock;
-(void)undimScreen;
-(void)dimScreen;
-(void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
@end