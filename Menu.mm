//
//  Menu.m
//  ModMenu
//
//  Created by Joey on 3/14/19.
//  Copyright © 2019 Joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"
// By @Softerov
@interface Menu ()

@property (assign, nonatomic) CGPoint lastMenuLocation;
@property (strong, nonatomic) UILabel *menuTitle;
@property (strong, nonatomic) UIView *header;
@property (strong, nonatomic) UIView *footer;
@property (assign, nonatomic) CGPoint panCoord;
@end

@implementation Menu

NSUserDefaults *defaults;

UIView *iMenu;
UIScrollView *scrollView;
UIScrollView *iScrollView;
CGFloat menuWidth;
CGFloat scrollViewX;
CGFloat iScrollViewX;
NSString *credits;
UIColor *switchOnColor;
NSString *switchTitleFont;
UIColor *switchTitleColor;
UIColor *infoButtonColor;
NSString *menuIconBase64;
NSString *menuButtonBase64;
float scrollViewHeight = 0;
float iScrollViewHeight = 0;
BOOL hasRestoredLastSession = false;
UIButton *menuButton;

const char *frameworkName = NULL;

UIWindow *mainWindow;

UILabel *lbl1;

// init the menu
// global variabls, extern in Macros.h
Menu *menu = [[Menu alloc]init];
Switches *switches = [[Switches alloc]init];

-(id)initWithTitle:(NSString *)title_ titleColor:(UIColor *)titleColor_ titleFont:(NSString *)titleFont_ credits:(NSString *)credits_ headerColor:(UIColor *)headerColor_ switchOffColor:(UIColor *)switchOffColor_ switchOnColor:(UIColor *)switchOnColor_ switchTitleFont:(NSString *)switchTitleFont_ switchTitleColor:(UIColor *)switchTitleColor_ infoButtonColor:(UIColor *)infoButtonColor_ maxVisibleSwitches:(int)maxVisibleSwitches_ menuWidth:(CGFloat )menuWidth_ menuIcon:(NSString *)menuIconBase64_ menuButton:(NSString *)menuButtonBase64_ {
    mainWindow = [UIApplication sharedApplication].keyWindow;
    defaults = [NSUserDefaults standardUserDefaults];

    menuWidth = menuWidth_;
    switchOnColor = switchOnColor_;
    credits = credits_;
    switchTitleFont = switchTitleFont_;
    switchTitleColor = switchTitleColor_;
    infoButtonColor = infoButtonColor_;
    menuButtonBase64 = menuButtonBase64_;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    [view setBackgroundColor:[UIColor clearColor]];
    [view setUserInteractionEnabled:NO];
    UITextField *field = [[UITextField alloc] init];
    field.secureTextEntry = true;
    [view addSubview:field];
    view = field.layer.sublayers.firstObject.delegate;
    [mainWindow addSubview:view];
// By @Softerov
    iMenu = [[UIView alloc] initWithFrame:CGRectMake(0,0,menuWidth_, maxVisibleSwitches_ * 50 + 50)];
    iMenu.center = mainWindow.center;
    iMenu.backgroundColor = [UIColor clearColor];
    iMenu.layer.opacity = 0.0f;
    [mainWindow addSubview:iMenu];

    UIView *iHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 1, menuWidth_, 50)];
    iHeader.backgroundColor = [UIColor clearColor];
    CAShapeLayer *iHeaderLayer = [CAShapeLayer layer];
    iHeaderLayer.path = [UIBezierPath bezierPathWithRoundedRect: iHeader.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    iHeader.layer.mask = iHeaderLayer;
    [iMenu addSubview:iHeader];

    NSData* iData = [[NSData alloc] initWithBase64EncodedString:@"" options:0];
    UIImage* iMenuIconImage = [UIImage imageWithData:iData];
    UIButton *iMenuIcon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    iMenuIcon.frame = CGRectMake(5, 1, 50, 50);
    iMenuIcon.backgroundColor = [UIColor clearColor];
    [iMenuIcon setBackgroundImage:iMenuIconImage forState:UIControlStateNormal];
    [iMenuIcon addTarget:self action:@selector(menuIconTapped) forControlEvents:UIControlEventTouchDown];
    [iHeader addSubview:iMenuIcon];

    iScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(iHeader.bounds), menuWidth_, CGRectGetHeight(iMenu.bounds) - CGRectGetHeight(iHeader.bounds))];
    iScrollView.backgroundColor = [UIColor clearColor];
    iScrollView.delegate = self;
    [iScrollView setShowsHorizontalScrollIndicator:NO];
    [iScrollView setShowsVerticalScrollIndicator:NO];
    [iMenu addSubview:iScrollView];

    UIPanGestureRecognizer *iDragMenuRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragging:)];
    [iHeader addGestureRecognizer:iDragMenuRecognizer];

    UITapGestureRecognizer *iTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMenu:)];
    iTapGestureRecognizer.numberOfTapsRequired = 1;
    [iHeader addGestureRecognizer:iTapGestureRecognizer];

    // Base of the Menu UI.
    self = [super initWithFrame:CGRectMake(0,0,menuWidth_, maxVisibleSwitches_ * 50 + 50)];
    self.center = mainWindow.center;
    self.layer.opacity = 0.0f;

    self.header = [[UIView alloc]initWithFrame:CGRectMake(0, 1, menuWidth_, 50)];
    self.header.backgroundColor = headerColor_;
    CAShapeLayer *headerLayer = [CAShapeLayer layer];
    headerLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.header.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    self.header.layer.mask = headerLayer;
    [self addSubview:self.header];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:menuIconBase64_ options:0];
    UIImage* menuIconImage = [UIImage imageWithData:data];

    UIButton *menuIcon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuIcon.frame = CGRectMake(5, 1, 50, 50);
    menuIcon.backgroundColor = [UIColor clearColor];
    [menuIcon setBackgroundImage:menuIconImage forState:UIControlStateNormal];

    [menuIcon addTarget:self action:@selector(menuIconTapped) forControlEvents:UIControlEventTouchDown];
    [self.header addSubview:menuIcon];

    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.header.bounds), menuWidth_, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.header.bounds))];
    scrollView.backgroundColor = switchOffColor_;
    [self addSubview:scrollView];

    // we need this for the switches, do not remove.
    scrollViewX = CGRectGetMinX(scrollView.self.bounds);
    iScrollViewX = CGRectGetMinX(iScrollView.self.bounds);

    self.menuTitle = [[UILabel alloc]initWithFrame:CGRectMake(55, -2, menuWidth_ - 60, 50)];
    self.menuTitle.text = title_;
    self.menuTitle.textColor = titleColor_;
    self.menuTitle.font = [UIFont fontWithName:titleFont_ size:30.0f];
    self.menuTitle.adjustsFontSizeToFitWidth = true;
    self.menuTitle.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview: self.menuTitle];

    self.footer = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, menuWidth_, 20)];
    self.footer.backgroundColor = headerColor_;
    CAShapeLayer *footerLayer = [CAShapeLayer layer];
    footerLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.footer.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    self.footer.layer.mask = footerLayer;
    [self addSubview:self.footer];

    UIPanGestureRecognizer *dragMenuRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragging:)];
    [self.header addGestureRecognizer:dragMenuRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMenu:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.header addGestureRecognizer:tapGestureRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMenu:)];
    tapGestureRecognizer2.numberOfTapsRequired = 2;
    tapGestureRecognizer2.numberOfTouchesRequired = 2;
    [mainWindow addGestureRecognizer:tapGestureRecognizer2];

    [view addSubview:self];

    return self;
}
// By @Softerov
- (void)matchScrollView:(UIScrollView *)first toScrollView:(UIScrollView *)second {
  CGPoint offset = first.contentOffset;
  offset.y = second.contentOffset.y;
  [first setContentOffset:offset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
  if([scroll isEqual:iScrollView]) {
    [self matchScrollView:scrollView toScrollView:iScrollView];  
  } else {
    [self matchScrollView:iScrollView toScrollView:scrollView];  
  }
}

-(void)dragging:(UIPanGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        //NSLog(@"Received a pan gesture");
        self.panCoord = [gesture locationInView:gesture.view];
    }
    CGPoint newCoord = [gesture locationInView:gesture.view];
    float dX = newCoord.x-self.panCoord.x;
    float dY = newCoord.y-self.panCoord.y;
    iMenu.frame = CGRectMake(iMenu.frame.origin.x+dX, iMenu.frame.origin.y+dY, iMenu.frame.size.width, iMenu.frame.size.height);
    self.frame = iMenu.frame;
 }



// Detects whether the menu is being touched and sets a lastMenuLocation.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.lastMenuLocation = CGPointMake(CGRectGetMinX(iMenu.frame), CGRectGetMinY(iMenu.frame));
    [super touchesBegan:touches withEvent:event];
}

// Update the menu's location when it's being dragged
- (void)menuDragged:(UIPanGestureRecognizer *)pan {
    CGPoint newLocation = [pan translationInView:self.superview];
    iMenu.frame = CGRectMake(self.lastMenuLocation.x + newLocation.x, self.lastMenuLocation.y + newLocation.y, CGRectGetWidth(iMenu.frame), CGRectGetHeight(iMenu.frame));
    self.frame = iMenu.frame;
}

- (void)hideMenu:(UITapGestureRecognizer *)tap {
    if(tap.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 0.0f;
            menuButton.alpha = 1.0f;
            iMenu.layer.opacity = 0.0f;
        }];
    }
}

-(void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        menuButton.alpha = 0.0f;
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 1.0f;
            iMenu.layer.opacity = 1.0f;
        }];
    }
    // We should only have to do this once (first launch)
    if(!hasRestoredLastSession) {
        restoreLastSession();
        hasRestoredLastSession = true;
    }
}

/**********************************************************************************************
     This function will be called when the menu has been opened for the first time on launch.
     It'll handle the correct background color and patches the switches do.
***********************************************************************************************/
void restoreLastSession() {
    UIColor *clearColor = [UIColor clearColor];
    BOOL isOn = false;

    for(id switch_ in scrollView.subviews) {
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
            for(int i = 0; i < memoryPatches.size(); i++) {
                if(isOn){
                 memoryPatches[i].Modify();
                } else {
                 memoryPatches[i].Restore();
                }
            }
            ((OffsetSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }

        if([switch_ isKindOfClass:[TextFieldSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            ((TextFieldSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }

        if([switch_ isKindOfClass:[SliderSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            ((SliderSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }
    }
}

-(void)showMenuButton {
    NSData* data = [[NSData alloc] initWithBase64EncodedString:menuButtonBase64 options:0];
    UIImage* menuButtonImage = [UIImage imageWithData:data];

    menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuButton.frame = CGRectMake((mainWindow.frame.size.width/2), (mainWindow.frame.size.height/2), 50, 50);
    menuButton.backgroundColor = [UIColor clearColor];
    [menuButton setBackgroundImage:menuButtonImage forState:UIControlStateNormal];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMenu:)];
    [menuButton addGestureRecognizer:tapGestureRecognizer];

    [menuButton addTarget:self action:@selector(buttonDragged:withEvent:)
       forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:menuButton];
}

// handler for when the user is draggin the menu.
- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];

    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;

    button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);
}

// When the menu icon(on the header) has been tapped, we want to show proper credits!
-(void)menuIconTapped {
    [self showPopup:self.menuTitle.text description:credits];
    self.layer.opacity = 0.0f;
}

-(void)showPopup:(NSString *)title_ description:(NSString *)description_ {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];

    alert.shouldDismissOnTapOutside = NO;
    alert.customViewColor = [UIColor purpleColor];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

    [alert addButton: @"Ok!" actionBlock: ^(void) {
        self.layer.opacity = 1.0f;
    }];

    [alert showInfo:title_ subTitle:description_ closeButtonTitle:nil duration:9999999.0f];
}

/*******************************************************************
    This method adds the given switch to the menu's scrollview.
    it also add's an action for when the switch is being clicked.
********************************************************************/
- (void)addSwitchToMenu:(id)switch_ {
    [switch_ addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchDown];
    scrollViewHeight += 50;
    scrollView.contentSize = CGSizeMake(menuWidth, scrollViewHeight);
    [scrollView addSubview:switch_];
}

- (void)addSwitchToiMenu:(id)switch_ {
    [switch_ addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchDown];
    iScrollViewHeight += 50;
    iScrollView.contentSize = CGSizeMake(menuWidth, iScrollViewHeight);
    [iScrollView addSubview:switch_];
}

- (void)changeSwitchBackground:(id)switch_ isSwitchOn:(BOOL)isSwitchOn_ {
    UIColor *clearColor = [UIColor clearColor];

    [UIView animateWithDuration:0.3 animations:^ {
        if([switch_ isKindOfClass:[TextFieldSwitch class]]) {
            ((TextFieldSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
        if([switch_ isKindOfClass:[SliderSwitch class]]) {
            ((SliderSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            ((OffsetSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
    }];

    [defaults setBool:!isSwitchOn_ forKey:[switch_ getPreferencesKey]];
}

/*********************************************************************************************
    This method does the following handles the behaviour when a switch has been clicked
    TextfieldSwitch and SliderSwitch only change from color based on whether it's on or not.
    A OffsetSwitch does too, but it also applies offset patches
***********************************************************************************************/
-(void)switchClicked:(id)switch_ {
    BOOL isOn = [defaults boolForKey:[switch_ getPreferencesKey]];

    if([switch_ isKindOfClass:[OffsetSwitch class]]) {
        std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
        for(int i = 0; i < memoryPatches.size(); i++) {
            if(!isOn){
                memoryPatches[i].Modify();
            } else {
                memoryPatches[i].Restore();
           }
        }
    }

    for(id iSwitch_ in scrollView.subviews) {
        if([iSwitch_ isKindOfClass:[OffsetSwitch class]]) {
            if ([switch_ getPreferencesKey] == [iSwitch_ getPreferencesKey]) {
                [self changeSwitchBackground:iSwitch_ isSwitchOn:isOn];
            }
        }
    }

    // Update switch background color and pref value.
    //[self changeSwitchBackground:switch_ isSwitchOn:isOn];
}

-(void)setFrameworkName:(const char *)name_ {
    frameworkName = name_;
}

-(const char *)getFrameworkName {
    return frameworkName;
}
@end // End of menu class!


/********************************
    OFFSET SWITCH STARTS HERE!
*********************************/

@implementation OffsetSwitch {
    std::vector<MemoryPatch> memoryPatches;
}

- (id)initHackNamed:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::vector<uint64_t>)offsets_ bytes:(std::vector<std::string>)bytes_ {
    description = description_;
    preferencesKey = hackName_;

    if(offsets_.size() != bytes_.size()){
        [menu showPopup:@"Invalid input count" description:[NSString stringWithFormat:@"Offsets array input count (%d) is not equal to the bytes array input count (%d)", (int)offsets_.size(), (int)bytes_.size()]];
    } else {
        // For each offset, we create a MemoryPatch.
        for(int i = 0; i < offsets_.size(); i++) {
            MemoryPatch patch = MemoryPatch::createWithHex([menu getFrameworkName], offsets_[i], bytes_[i]);
            if(patch.isValid()) {
              memoryPatches.push_back(patch);
            } else {
              [menu showPopup:@"Invalid patch" description:[NSString stringWithFormat:@"Failing offset: 0x%llx, please re-check the hex you entered.", offsets_[i]]];
            }
        }
    }

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight - 1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 50)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    return self;
}

- (id)initHackNamedA:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::vector<uint64_t>)offsets_ bytes:(std::vector<std::string>)bytes_ {
    description = description_;
    preferencesKey = hackName_;

    if(offsets_.size() != bytes_.size()){
        [menu showPopup:@"Invalid input count" description:[NSString stringWithFormat:@"Offsets array input count (%d) is not equal to the bytes array input count (%d)", (int)offsets_.size(), (int)bytes_.size()]];
    } else {
        // For each offset, we create a MemoryPatch.
        for(int i = 0; i < offsets_.size(); i++) {
            MemoryPatch patch = MemoryPatch::createWithHex([menu getFrameworkName], offsets_[i], bytes_[i]);
            if(patch.isValid()) {
              memoryPatches.push_back(patch);
            } else {
              [menu showPopup:@"Invalid patch" description:[NSString stringWithFormat:@"Failing offset: 0x%llx, please re-check the hex you entered.", offsets_[i]]];
            }
        }
    }

    self = [super initWithFrame:CGRectMake(-1, iScrollViewX + iScrollViewHeight - 1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor clearColor].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 50)];
    switchLabel.text = hackName_;
    switchLabel.textColor = [UIColor clearColor];
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = [UIColor clearColor];

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    return self;
}

-(void)showInfo:(UIGestureRecognizer *)gestureRec {
    if(gestureRec.state == UIGestureRecognizerStateEnded) {
        [menu showPopup:[self getPreferencesKey] description:[self getDescription]];
        menu.layer.opacity = 0.0f;
    }
}

-(NSString *)getPreferencesKey {
    return preferencesKey;
}

-(NSString *)getDescription {
    return description;
}

- (std::vector<MemoryPatch>)getMemoryPatches {
    return memoryPatches;
}

@end //end of OffsetSwitch class

// By @Softerov
/**************************************
    TEXTFIELD SWITCH STARTS HERE!
    - Note that this extends from OffsetSwitch.
***************************************/

@implementation TextFieldSwitch {
    UITextField *textfieldValue;
}

- (id)initTextfieldNamed:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 30)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    textfieldValue = [[UITextField alloc]initWithFrame:CGRectMake(menuWidth / 4 - 10, switchLabel.self.bounds.origin.x - 5 + switchLabel.self.bounds.size.height, menuWidth / 2, 20)];
    textfieldValue.layer.borderWidth = 2.0f;
    textfieldValue.layer.borderColor = inputBorderColor_.CGColor;
    textfieldValue.layer.cornerRadius = 10.0f;
    textfieldValue.textColor = switchTitleColor;
    textfieldValue.textAlignment = NSTextAlignmentCenter;
    textfieldValue.delegate = self;
    textfieldValue.backgroundColor = [UIColor clearColor];

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        textfieldValue.text = [[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:textfieldValue];

    return self;
}

// so when click "return" the keyboard goes way, got it from internet. Common thing apparantly
-(BOOL)textFieldShouldReturn:(UITextField*)textfieldValue_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    [defaults setObject:textfieldValue_.text forKey:[self getSwitchValueKey]];
    [textfieldValue_ resignFirstResponder];

    return true;
}

-(NSString *)getSwitchValueKey {
    return switchValueKey;
}

@end // end of TextFieldSwitch Class


/*******************************
    SLIDER SWITCH STARTS HERE!
    - Note that this extends from TextFieldSwitch
 *******************************/

@implementation SliderSwitch {
    UISlider *sliderValue;
    float valueOfSlider;
}

- (id)initSliderNamed:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_{
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;
// By @Softerov
    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 1, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(5, 10, 0, 50)];
    /*[toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventTouchUpInside];*/
    [toggleSwitch addTarget:self action: @selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:toggleSwitch];

    BOOL isOn = [defaults boolForKey:preferencesKey];
    if([[NSUserDefaults standardUserDefaults] objectForKey:preferencesKey] != nil)
    {
        [toggleSwitch setOn:isOn animated:YES];
    }

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 30)];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    sliderValue = [[UISlider alloc]initWithFrame:CGRectMake(menuWidth / 3 - 25, switchLabel.self.bounds.origin.x - 4.5 + switchLabel.self.bounds.size.height, menuWidth / 2 + 15, 15)];
    sliderValue.thumbTintColor = sliderColor_;
    sliderValue.minimumTrackTintColor = switchTitleColor;
    sliderValue.maximumTrackTintColor = switchTitleColor;
    sliderValue.minimumValue = minimumValue_;
    sliderValue.maximumValue = maximumValue_;
    sliderValue.continuous = true;
    [sliderValue addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueOfSlider = sliderValue.value;

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        sliderValue.value = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
        switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:sliderValue];

    return self;
}

- (id)initSliderNamed2:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_{
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight2 -1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(5, 10, 0, 50)];
    /*[toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventTouchUpInside];*/
    [toggleSwitch addTarget:self action: @selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:toggleSwitch];

    BOOL isOn = [defaults boolForKey:preferencesKey];
    if([[NSUserDefaults standardUserDefaults] objectForKey:preferencesKey] != nil)
    {
        [toggleSwitch setOn:isOn animated:YES];
    }

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 30)];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    sliderValue = [[UISlider alloc]initWithFrame:CGRectMake(menuWidth / 4 - 20, switchLabel.self.bounds.origin.x - 4 + switchLabel.self.bounds.size.height, menuWidth / 2 + 20, 20)];
    sliderValue.thumbTintColor = sliderColor_;
    sliderValue.minimumTrackTintColor = switchTitleColor;
    sliderValue.maximumTrackTintColor = switchTitleColor;
    sliderValue.minimumValue = minimumValue_;
    sliderValue.maximumValue = maximumValue_;
    sliderValue.continuous = true;
    [sliderValue addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueOfSlider = sliderValue.value;

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        sliderValue.value = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
        switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:sliderValue];

    return self;
}

- (id)initSliderNamed3:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_{
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight3 -1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(5, 10, 0, 50)];
    /*[toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventTouchUpInside];*/
    [toggleSwitch addTarget:self action: @selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:toggleSwitch];

    BOOL isOn = [defaults boolForKey:preferencesKey];
    if([[NSUserDefaults standardUserDefaults] objectForKey:preferencesKey] != nil)
    {
        [toggleSwitch setOn:isOn animated:YES];
    }

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 30)];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    sliderValue = [[UISlider alloc]initWithFrame:CGRectMake(menuWidth / 4 - 20, switchLabel.self.bounds.origin.x - 4 + switchLabel.self.bounds.size.height, menuWidth / 2 + 20, 20)];
    sliderValue.thumbTintColor = sliderColor_;
    sliderValue.minimumTrackTintColor = switchTitleColor;
    sliderValue.maximumTrackTintColor = switchTitleColor;
    sliderValue.minimumValue = minimumValue_;
    sliderValue.maximumValue = maximumValue_;
    sliderValue.continuous = true;
    [sliderValue addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueOfSlider = sliderValue.value;

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        sliderValue.value = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
        switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:sliderValue];

    return self;
}

- (id)initSliderNamed4:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_{
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight4 -1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(5, 10, 0, 50)];
    /*[toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventTouchUpInside];*/
    [toggleSwitch addTarget:self action: @selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:toggleSwitch];

    BOOL isOn = [defaults boolForKey:preferencesKey];
    if([[NSUserDefaults standardUserDefaults] objectForKey:preferencesKey] != nil)
    {
        [toggleSwitch setOn:isOn animated:YES];
    }

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 30)];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    sliderValue = [[UISlider alloc]initWithFrame:CGRectMake(menuWidth / 4 - 20, switchLabel.self.bounds.origin.x - 4 + switchLabel.self.bounds.size.height, menuWidth / 2 + 20, 20)];
    sliderValue.thumbTintColor = sliderColor_;
    sliderValue.minimumTrackTintColor = switchTitleColor;
    sliderValue.maximumTrackTintColor = switchTitleColor;
    sliderValue.minimumValue = minimumValue_;
    sliderValue.maximumValue = maximumValue_;
    sliderValue.continuous = true;
    [sliderValue addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueOfSlider = sliderValue.value;

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        sliderValue.value = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
        switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:sliderValue];

    return self;
}

-(void)sliderValueChanged:(UISlider *)slider_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", [self getPreferencesKey], slider_.value];
    [defaults setFloat:slider_.value forKey:[self getSwitchValueKey]];
}

-(void) switchToggled:(id)sender_
{
    BOOL isOn = [sender_ isOn];
    [defaults setBool:isOn forKey:preferencesKey];
}

@end // end of SliderSwitch class





@implementation Switches


-(void)addSwitch:(NSString *)hackName_ description:(NSString *)description_ {
    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ offsets:std::vector<uint64_t>{} bytes:std::vector<std::string>{}];
    [menu addSwitchToMenu:offsetPatch];
    OffsetSwitch *offsetPatch2 = [[OffsetSwitch alloc]initHackNamedA:hackName_ description:description_ offsets:std::vector<uint64_t>{} bytes:std::vector<std::string>{}];
    [menu addSwitchToiMenu:offsetPatch2];
}

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::initializer_list<uint64_t>)offsets_ bytes:(std::initializer_list<std::string>)bytes_ {
    std::vector<uint64_t> offsetVector;
    std::vector<std::string> bytesVector;

    offsetVector.insert(offsetVector.begin(), offsets_.begin(), offsets_.end());
    bytesVector.insert(bytesVector.begin(), bytes_.begin(), bytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ offsets:offsetVector bytes:bytesVector];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addTextfieldSwitch:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToMenu:textfieldSwitch];
}

- (void)addSliderSwitch:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToMenu:sliderSwitch];
}

- (NSString *)getValueFromSwitch:(NSString *)name {

    //getting the correct key for the saved input.
    NSString *correctKey =  [name stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];

    if([[NSUserDefaults standardUserDefaults] objectForKey:correctKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:correctKey];
    }
    else if([[NSUserDefaults standardUserDefaults] floatForKey:correctKey]) {
        NSString *sliderValue = [NSString stringWithFormat:@"%f", [[NSUserDefaults standardUserDefaults] floatForKey:correctKey]];
        return sliderValue;
    }

    return 0;
}
// By @Softerov
-(bool)isSwitchOn:(NSString *)switchName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:switchName];
}

@end
// By @Softerov
// By @Softerov
