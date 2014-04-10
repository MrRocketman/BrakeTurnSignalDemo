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
    BOOL leftLightStates[3];
    BOOL rightLightStates[3];
    
    NSArray *leftLights;
    NSArray *rightLights;
    
    int flashPattern;
    BOOL inputLeftTurn;
    BOOL inputRightTurn;
    BOOL inputBrakesState;
    
    long flashRate;
    unsigned long currentMillisL;
    unsigned long previousMillisL;
    unsigned long currentMillisR;
    unsigned long previousMillisR;
}

@property (assign) IBOutlet NSWindow *window;

@property(strong, nonatomic) IBOutlet NSButton *leftBlinkerButton;
@property(strong, nonatomic) IBOutlet NSButton *rightBlinkerButton;
@property(strong, nonatomic) IBOutlet NSButton *brakesButton;

@property(strong, nonatomic) IBOutlet NSSegmentedControl *flashPatternSegmentedControl;

@property(strong, nonatomic) IBOutlet NSButton *leftLight1;
@property(strong, nonatomic) IBOutlet NSButton *leftLight2;
@property(strong, nonatomic) IBOutlet NSButton *leftLight3;
@property(strong, nonatomic) NSArray *leftLights;

@property(strong, nonatomic) IBOutlet NSButton *rightLight1;
@property(strong, nonatomic) IBOutlet NSButton *rightLight2;
@property(strong, nonatomic) IBOutlet NSButton *rightLight3;
@property(strong, nonatomic) NSArray *rightLights;

- (IBAction)leftBlinkerButtonPress:(id)sender;
- (IBAction)rightBlinkerButtonPress:(id)sender;
- (IBAction)brakesButtonPress:(id)sender;

- (IBAction)flashPatternSegmentedControlChange:(id)sender;

@end
