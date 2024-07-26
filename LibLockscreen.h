//Something something to add here.
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LibLSController : NSObject{

}
+(LibLSController *)sharedInstance;
-(void)unlock;
-(UITableViewController*)bulletinController; //maybe right? I don't remember what this is. Test it, find out! :)
-(UIImage *)backgroundImage;
@end


@protocol LibLockscreen
-(id)initWithController:(LibLSController*)controller;
-(float)liblsVersion; //In case there are updates to liblockscreen, I can provide legacy support for your plugin if I know the version.
@property (nonatomic, assign) UIView *view; //Set this up in the init method. This is your view that is going to be the new lockscreen. 
@property (nonatomic, assign) LibLSController* controller; //Has some API you can use to perform actions or get information
@optional

//-----Passcode related stuff
-(void)passcodeFailed;
-(void)passcodeAccepted;
-(void)showLockKeypad:(BOOL)show; //Will be true for showing, will be false for hiding. 
-(void)unlockedDevice; //Called after the device unlocks
//-----Clock methods
-(void)updateClockWithTime:(NSString*)time andDate:(NSString*)date; //Called when the time changes.

//----Media information is good right?
-(void)showMediaControls:(BOOL)show;
-(void)nowPlayingInfoChanged;

//-----Call related things
-(void)receivingCall;
-(void)makeEmergencyCall:(BOOL)call;


//-----Notification related things
-(void)receivedNotification:(NSMutableDictionary *)notification;
-(BOOL)usesStockNotificationList;
-(void)showBulletinView; //Both called when the bulletin view should be shown/added I guess?
-(void)insertBulletinView;
@end






