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
    
    flashRate = 700;
    
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
    switch (flashPattern)
    {
        default: // Basic turn signal pattern (pattern 0)
            // Update current time for turn signal
            currentTailLightMillis = [self millis];
            
            // Turn signal state logic
            if (currentTailLightMillis - previousTailLightMillis > flashRate)
            {
                // Save the last time the turn changed state
                previousTailLightMillis = currentTailLightMillis;
                
                // All turn lamps off
                if (*stateTurn && *stateTail1 && *stateTail2 && *stateTail3)
                {
                    // Set all tail turn lamps states on
                    *stateTurn = LOW;
                    *stateTail1 = LOW;
                    *stateTail2 = LOW;
                    *stateTail3 = LOW;
                }
                // All turn lamps on
                else
                {
                    // Set all tail turn lamps states off
                    *stateTurn = HIGH;
                    *stateTail1 = HIGH;
                    *stateTail2 = HIGH;
                    *stateTail3 = HIGH;
                }
            }
            break;
            
        case 1: // Sequence turn signal pattern
            // Update current time for turn signal
            currentTailLightMillis = [self millis];
            
            // Turn lamp state logic
            if (currentTailLightMillis - previousTailLightMillis > flashRate)
            {
                // Save the last time the turn changed state
                previousTailLightMillis = currentTailLightMillis;
                
                *stateTurn = !(*stateTurn);
            }
            
            // Tail turn lamps state logic
            if ((currentTailLightMillis - previousTailLightMillis2) > flashRate / 4)
            {
                // Save the last time the turn changed state
                previousTailLightMillis2 = currentTailLightMillis;
                
                NSLog(@"sequence logic");
                // All tail turn lamps off
                if (*stateTail1 && *stateTail2 && *stateTail3)
                {
                    // Set tail turn lamp inner state on
                    *stateTail1 = LOW;
                }
                // Tail turn lamp inner on, tail turn lamps middle & outer off
                else if (!(*stateTail1) && *stateTail2 && *stateTail3)
                {
                    // Set tail turn lamp middle state on
                    *stateTail2 = LOW;
                }
                // Tail turn lamps inner & middle on, Tail turn lamp outer off
                else if (!(*stateTail1) && !(*stateTail2) && *stateTail3)
                {
                    // Set tail turn lamp outer state on
                    *stateTail3 = LOW;
                }
                // All tail turn lamps on
                else
                {
                    // Set all tail turn lamps states off
                    *stateTail1 = HIGH;
                    *stateTail2 = HIGH;
                    *stateTail3 = HIGH;
                }
            }
            break;
        case 2: // Chase turn signal pattern
            // Update current time for  turn
            currentTailLightMillis = [self millis];
            
            // Turn lamp state logic
            if (currentTailLightMillis - previousTailLightMillis > flashRate)
            {
                // Save the last time the turn changed state
                previousTailLightMillis = currentTailLightMillis;
                
                // Toggle turn lamp state
                *stateTurn = !(*stateTurn);
            }
            
            // Tail turn lamps state logic
            if ((currentTailLightMillis - previousTailLightMillis2) > flashRate / 6)
            {
                // Save the last time the turn changed state
                previousTailLightMillis2 = currentTailLightMillis;
                
                // All  tail turn lamps off
                if (*stateTail1 && *stateTail2 && *stateTail3)
                {
                    // Set  tail turn lamp inner state on
                    *stateTail1 = LOW;
                }
                // Tail turn lamp inner on,  tail turn lamps middle & outer off
                else if (!(*stateTail1) && *stateTail2 && *stateTail3)
                {
                    // Set  tail turn lamp middle state on
                    *stateTail2 = LOW;
                }
                // Tail turn lamps inner & middle on,  tail turn lamp outer off
                else if (!(*stateTail1) && !(*stateTail2) && *stateTail3)
                {
                    // Set  tail turn lamp outer state on
                    *stateTail3 = LOW;
                }
                // All  tail turn lamps on
                else if (!(*stateTail1) && !(*stateTail2) && !(*stateTail3))
                {
                    // Set  tail turn lamp inner state off
                    *stateTail1 = HIGH;
                }
                // Tail turn lamp inner off,  tail turn lamps middle & outer on
                else if (*stateTail1 && !(*stateTail2) && !(*stateTail3))
                {
                    // Set  tail turn lamp middle state off
                    *stateTail2 = HIGH;
                }
                // Tail turn lamps inner & middle off,  tail turn lamp outer on
                else if (*stateTail1 && *stateTail2 && !(*stateTail3))
                {
                    // Set right tail turn lamp outer state off
                    *stateTail3 = HIGH;
                }
                // All tail turn lamps on
                else
                {
                    // Set all tail turn lamps states off
                    *stateTail1 = HIGH;
                    *stateTail2 = HIGH;
                    *stateTail3 = HIGH;
                }
            }
            break;
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
