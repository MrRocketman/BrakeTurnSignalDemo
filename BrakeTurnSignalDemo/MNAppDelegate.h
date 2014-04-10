//
//  MNAppDelegate.h
//  BrakeTurnSignalDemo
//
//  Created by James Adams on 4/9/14.
//  Copyright (c) 2014 JamesAdams. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MNAppDelegate : NSObject <NSApplicationDelegate>
{
    BOOL stateTailL1;									//left tail turn lamp inner state
    BOOL stateTailL2;									//left tail turn lamp middle state
    BOOL stateTailL3;									//left tail turn lamp outer state
    BOOL stateTurnL;									//left turn lamp state
    BOOL stateTailR1;									//right tail turn lamp inner state
    BOOL stateTailR2;									//right tail turn lamp middle state
    BOOL stateTailR3;									//right tail turn lamp outer state
    BOOL stateTurnR;									//right turn lamp state
    
    int flashPattern;
    long flashRate;
    unsigned long currentMillisL;
    unsigned long previousMillisL;
    unsigned long currentMillisR;
    unsigned long previousMillisR;
    
    BOOL inputLeftTurn;
    BOOL inputRightTurn;
    BOOL inputBrakesState;
}

@property (assign) IBOutlet NSWindow *window;

@property(strong, nonatomic) IBOutlet NSButton *leftBlinkerButton;
@property(strong, nonatomic) IBOutlet NSButton *rightBlinkerButton;
@property(strong, nonatomic) IBOutlet NSButton *brakesButton;

@property(strong, nonatomic) IBOutlet NSSegmentedControl *flashPatternSegmentedControl;

@property(strong, nonatomic) IBOutlet NSButton *brakeLeft;
@property(strong, nonatomic) IBOutlet NSButton *tailL1;
@property(strong, nonatomic) IBOutlet NSButton *tailL2;
@property(strong, nonatomic) IBOutlet NSButton *tailL3;
@property(strong, nonatomic) IBOutlet NSButton *turnL;

@property(strong, nonatomic) IBOutlet NSButton *brakeRight;
@property(strong, nonatomic) IBOutlet NSButton *tailR1;
@property(strong, nonatomic) IBOutlet NSButton *tailR2;
@property(strong, nonatomic) IBOutlet NSButton *tailR3;
@property(strong, nonatomic) IBOutlet NSButton *turnR;

- (IBAction)leftBlinkerButtonPress:(id)sender;
- (IBAction)rightBlinkerButtonPress:(id)sender;
- (IBAction)brakesButtonPress:(id)sender;

- (IBAction)flashPatternSegmentedControlChange:(id)sender;

@end
