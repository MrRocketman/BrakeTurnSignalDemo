//
//  MNAppDelegate.m
//  BrakeTurnSignalDemo
//
//  Created by James Adams on 4/9/14.
//  Copyright (c) 2014 JamesAdams. All rights reserved.
//

#import "MNAppDelegate.h"

#define LOW NO
#define HIGH YES

#define NUMBER_OF_PATTERNS 5
#define MAX_NUMBER_OF_STATES_PER_PATTERN 6

char tailLightPatterns[NUMBER_OF_PATTERNS][MAX_NUMBER_OF_STATES_PER_PATTERN][3] =
{
    {{0x01, 0x01, 0x01}, {0x00, 0x00, 0x00}},
    {{0x00, 0x00, 0x00}, {0x01, 0x00, 0x00}, {0x01, 0x01, 0x00}, {0x01, 0x01, 0x01}},
    {{0x00, 0x00, 0x00}, {0x01, 0x00, 0x00}, {0x01, 0x01, 0x00}, {0x01, 0x01, 0x01}, {0x00, 0x01, 0x01}, {0x00, 0x00, 0x01}},
    {{0x01, 0x01, 0x01}, {0x00, 0x01, 0x01}, {0x00, 0x00, 0x01}, {0x00, 0x00, 0x00}},
    {{0x00, 0x01, 0x01}, {0x01, 0x00, 0x01}, {0x01, 0x01, 0x00}}
};

int tailLightPatternStates[NUMBER_OF_PATTERNS] =
{
    2,
    4,
    6,
    4,
    3
};

// Private methods/variables
@interface MNAppDelegate()
{
    
}

- (void)digitalWrite:(NSButton *)light state:(BOOL)highOrLow;
- (BOOL)digitalRead:(BOOL)variable;
- (void)manageTurnSignalLightStates:(NSTimer *)timer;
- (int)millis;

@end


@implementation MNAppDelegate

@synthesize leftBlinkerButton, rightBlinkerButton, brakesButton, tailL1, tailL2, tailL3, turnL, tailR1, tailR2, tailR3, turnR;

#pragma mark - Main Code Start

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    systemStartTime = [[NSDate date] timeIntervalSinceReferenceDate];
    
    flashRate = 1000;
    
    // Call manager light states repeatedly
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(manageTurnSignalLightStates:) userInfo:nil repeats:YES];
}

- (IBAction)leftBlinkerButtonPress:(id)sender
{
    if([sender state] == NSOnState)
    {
        inputLeftTurn = YES;
        [rightBlinkerButton setEnabled:NO];
    }
    else
    {
        inputLeftTurn = NO;
        [rightBlinkerButton setEnabled:YES];
    }
}

- (IBAction)rightBlinkerButtonPress:(id)sender
{
    if([sender state] == NSOnState)
    {
        inputRightTurn = YES;
        [leftBlinkerButton setEnabled:NO];
    }
    else
    {
        inputRightTurn = NO;
        [leftBlinkerButton setEnabled:YES];
    }
}

- (IBAction)brakesButtonPress:(id)sender
{
    if([sender state] == NSOnState)
    {
        inputBrakes = YES;
    }
    else
    {
        inputBrakes = NO;
    }
}

- (IBAction)flashPatternSegmentedControlChange:(id)sender
{
    flashPattern = (int)[sender selectedSegment];
    tailLightPatternIndex = 0;
}

#pragma mark - Light On Off

- (void)digitalWrite:(NSButton *)light state:(BOOL)highOrLow
{
    highOrLow = !highOrLow; // Inverse logic
    
    [light highlight:highOrLow];
}

- (BOOL)digitalRead:(BOOL)variable
{
    return !variable; // Inverse logic
}

- (int)millis
{
    return (int)(([[NSDate date] timeIntervalSinceReferenceDate] - systemStartTime) * 1000);
}

#pragma mark - Managment

- (void)turnSignalLogicForTurnLight:(BOOL *)stateTurn light1:(BOOL *)stateTail1 light2:(BOOL *)stateTail2 light3:(BOOL *)stateTail3
{
    // Update current time for turn signal
    currentTailLightMillis = [self millis];
    
    // Front Turn lamp state logic
    if (currentTailLightMillis - previousTailLightMillis > flashRate / 2)
    {
        // Save the last time the turn changed state
        previousTailLightMillis = currentTailLightMillis;
        
        *stateTurn = !(*stateTurn);
    }
    
    // Tail turn lamps state logic
    if ((currentTailLightMillis - previousTailLightMillis2) > flashRate / tailLightPatternStates[flashPattern])
    {
        // Save the last time the turn changed state
        previousTailLightMillis2 = currentTailLightMillis;
        
        // Do the pattern state
        if(tailLightPatternIndex < tailLightPatternStates[flashPattern])
        {
            *stateTail1 = tailLightPatterns[flashPattern][tailLightPatternIndex][0];
            *stateTail2 = tailLightPatterns[flashPattern][tailLightPatternIndex][1];
            *stateTail3 = tailLightPatterns[flashPattern][tailLightPatternIndex][2];
            
            tailLightPatternIndex ++;
        }
        // Loop back to the first state
        if(tailLightPatternIndex >= tailLightPatternStates[flashPattern])
        {
            tailLightPatternIndex = 0;
        }
    }
}

- (void)manageTurnSignalLightStates:(NSTimer *)timer
{
    BOOL inputBrakesState = [self digitalRead:inputBrakes];
    BOOL inputLeftTurnState = [self digitalRead:inputLeftTurn];
    BOOL inputRightTurnState = [self digitalRead:inputRightTurn];
    
    // No brake or turn signals active
    if(inputBrakesState == HIGH && inputLeftTurnState == HIGH && inputRightTurnState == HIGH)
    {
        //set all tail turn lamps states off
        stateTurnL = HIGH;
        stateTailL1 = HIGH;
        stateTailL2 = HIGH;
        stateTailL3 = HIGH;
        stateTurnR = HIGH;
        stateTailR1 = HIGH;
        stateTailR2 = HIGH;
        stateTailR3 = HIGH;
    }
    // Only the brakes signal is active
    else if(inputBrakesState == LOW && inputLeftTurnState == HIGH && inputRightTurnState == HIGH)
    {
        //set all tail turn lamps states on
        stateTurnL = LOW;
        stateTailL1 = LOW;
        stateTailL2 = LOW;
        stateTailL3 = LOW;
        stateTurnR = LOW;
        stateTailR1 = LOW;
        stateTailR2 = LOW;
        stateTailR3 = LOW;
    }
    // Brakes signal and left turn signal are active
    else if(inputBrakesState == LOW && inputLeftTurnState == LOW && inputRightTurnState == HIGH)
    {
        //set right tail turn lamps states on
        stateTurnR = LOW;
        stateTailR1 = LOW;
        stateTailR2 = LOW;
        stateTailR3 = LOW;
    }
    // Brakes signal and right turn signal are active
    else if(inputBrakesState == LOW && inputLeftTurnState == HIGH && inputRightTurnState == LOW)
    {
        //set left tail turn lamps states on
        stateTurnL = LOW;
        stateTailL1 = LOW;
        stateTailL2 = LOW;
        stateTailL3 = LOW;
    }
    // Brakes signal and left turn signal are active
    else if(inputBrakesState == HIGH && inputLeftTurnState == LOW && inputRightTurnState == HIGH)
    {
        //set right tail turn lamps states off
        stateTurnR = HIGH;
        stateTailR1 = HIGH;
        stateTailR2 = HIGH;
        stateTailR3 = HIGH;
    }
    // Brakes signal and right turn signal are active
    else if(inputBrakesState == HIGH && inputLeftTurnState == HIGH && inputRightTurnState == LOW)
    {
        //set left tail turn lamps states off
        stateTurnL = HIGH;
        stateTailL1 = HIGH;
        stateTailL2 = HIGH;
        stateTailL3 = HIGH;
    }
    
    // Left turn signal is active
    if(inputLeftTurnState == LOW)
    {
        [self turnSignalLogicForTurnLight:&stateTurnL light1:&stateTailL1 light2:&stateTailL2 light3:&stateTailL3];
    }
    // Right turn signal is active
    if(inputRightTurnState == LOW)
    {
        [self turnSignalLogicForTurnLight:&stateTurnR light1:&stateTailR1 light2:&stateTailR2 light3:&stateTailR3];
    }
    
#pragma mark !!! Write flasher signal logic here
    if(1 == 0)
    {
        
    }
    
    //update turn lamps relays
    [self digitalWrite:turnL state:stateTurnL];
    [self digitalWrite:tailL1 state:stateTailL1];
    [self digitalWrite:tailL2 state:stateTailL2];
    [self digitalWrite:tailL3 state:stateTailL3];
    [self digitalWrite:turnR state:stateTurnR];
    [self digitalWrite:tailR1 state:stateTailR1];
    [self digitalWrite:tailR2 state:stateTailR2];
    [self digitalWrite:tailR3 state:stateTailR3];
}

@end
