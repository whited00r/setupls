#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UIImage+LiveBlur.h"
#import "NSString+Localize.h"

@class SetupLS;
@interface SetupLSOTASettingView : UIView{
	UILabel *titleLabel;
	UITextView *aboutOTATextView;
	UILabel *aboutOTATitleLabel;
	UITextView *otaOptionTextView;
	UILabel *otaOptionTitleLabel;
	UIImageView *otaGroupImage; //To sloth, or not to sloth. That is the question.
	UIView *otaOptionTextViewOverlay;
	UIButton *stableButton;
	UIButton *betaButton;
	UIButton *continueButton;
	NSMutableDictionary *otaDict;
}
@property (nonatomic, assign) SetupLS *controller;
@end