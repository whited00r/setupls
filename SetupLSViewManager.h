#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "SetupLSWelcomeView.h"
#import "SetupActivationView.h"
#import "UIImage+LiveBlur.h"
#import "NSString+Localize.h"

@class SetupLS;
@interface SetupLSViewManager : NSObject{ //Not actually a view controller is it because those deal with one view and yeah.
  NSMutableDictionary *viewsDict;
  float screenWidth;
  float screenHeight; 
  UIView *currentView;
}
@property (nonatomic, assign) SetupLS *controller;

@end