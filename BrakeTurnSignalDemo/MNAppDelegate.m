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
        inputBrakesState = YES;
    }
    else
    {
        inputBrakesState = NO;
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
        default: //basic left turn signal pattern (pattern 0)
            currentTailLightMillis = [self millis];	//update current time for left turn
            
            //left turn state logic
            if (currentTailLightMillis - previousTailLightMillis > flashRate)
            {
                previousTailLightMillis = currentTailLightMillis;		//save last time left turn changed state
                
                //all left turn lamps off
                if (*stateTurn && *stateTail1 && *stateTail2 && *stateTail3)
                {
                    //set all left tail turn lamps states on
                    *stateTurn = LOW;
                    *stateTail1 = LOW;
                    *stateTail2 = LOW;
                    *stateTail3 = LOW;
                }
                //all left turn lamps on
                else
                {
                    //set all left tail turn lamps states off
                    *stateTurn = HIGH;
                    *stateTail1 = HIGH;
                    *stateTail2 = HIGH;
                    *stateTail3 = HIGH;
                }
            }
            break;
            
        case 1: //sequence left turn signal pattern
            currentTailLightMillis = [self millis]; //update current time for left turn
            
            //left turn lamp state logic
            if (currentTailLightMillis - previousTailLightMillis > flashRate)
            {
                *stateTurn = !(*stateTurn);
            }
            
            //left tail turn lamps state logic
            if (((currentTailLightMillis - previousTailLightMillis) / 4) > flashRate)
            {
                //all left tail turn lamps off
                if (*stateTail1 && *stateTail2 && *stateTail3)
                {
                    *stateTail1 = LOW;					//set left tail turn lamp inner state on
                }
                //left tail turn lamp inner on, left tail turn lamps middle & outer off
                else if (!stateTail1 && stateTail2 && stateTail3)
                {
                    *stateTail2 = LOW;					//set left tail turn lamp middle state on
                }
                //left tail turn lamps inner & middle on, left tail turn lamp outer off
                else if (!stateTail1 && !stateTail2 && stateTail3)
                {
                    *stateTail3 = LOW;					//set left tail turn lamp outer state on
                }
                //all left tail turn lamps on
                else
                {
                    //set all left tail turn lamps states off
                    *stateTail1 = HIGH;
                    *stateTail2 = HIGH;
                    *stateTail3 = HIGH;
                }
            }
            break;
        case 2: //chase left turn signal pattern
            currentTailLightMillis = [self millis]; //update current time for left turn
            
            //left turn lamp state logic
            if (currentTailLightMillis - previousTailLightMillis > flashRate)
            {
                *stateTurn = !(*stateTurn);				//toggle left turn lamp state
            }
            
            //left tail turn lamps state logic
            if (((currentTailLightMillis - previousTailLightMillis) / 6) > flashRate)
            {
                //all left tail turn lamps off
                if (*stateTail1 && *stateTail2 && *stateTail3)
                {
                    *stateTail1 = LOW;					//set left tail turn lamp inner state on
                }
                //left tail turn lamp inner on, left tail turn lamps middle & outer off
                else if (!(*stateTail1) && *stateTail2 && *stateTail3)
                {
                    *stateTail2 = LOW;					//set left tail turn lamp middle state on
                }
                //left tail turn lamps inner & middle on, left tail turn lamp outer off
                else if (!(*stateTail1) && !(*stateTail2) && *stateTail3)
                {
                    *stateTail3 = LOW;					//set left tail turn lamp outer state on
                }
                //all left tail turn lamps on
                else if (!(*stateTail1) && !(*stateTail2) && !(*stateTail3))
                {
                    *stateTail1 = HIGH;					//set left tail turn lamp inner state off
                }
                //left tail turn lamp inner off, left tail turn lamps middle & outer on
                else if (*stateTail1 && !(*stateTail2) && !(*stateTail3))
                {
                    *stateTail2 = HIGH;					//set left tail turn lamp middle state off
                }
                //left tail turn lamps inner & middle off, left tail turn lamp outer on
                else if (*stateTail1 && *stateTail2 && !(*stateTail3))
                {
                    *stateTail3 = HIGH;					//set right tail turn lamp outer state off
                }
            }
    }
}

- (void)manageTurnSignalLightStates:(NSTimer *)timer
{
    // No brake or turn signals active
    if([self digitalRead:inputBrakesState] == HIGH && [self digitalRead:inputLeftTurn] == HIGH && [self digitalRead:inputRightTurn] == HIGH)
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
    else if([self digitalRead:inputBrakesState] == LOW && [self digitalRead:inputLeftTurn] == HIGH && [self digitalRead:inputRightTurn] == HIGH)
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
    else if([self digitalRead:inputBrakesState] == LOW && [self digitalRead:inputLeftTurn] == LOW && [self digitalRead:inputRightTurn] == HIGH)
    {
        [self turnSignalLogicForTurnLight:&stateTurnL light1:&stateTailL1 light2:&stateTailL2 light3:&stateTailL3];
        
        //set right tail turn lamps states on
        stateTurnR = LOW;
        stateTailR1 = LOW;
        stateTailR2 = LOW;
        stateTailR3 = LOW;
    }
    // Brakes signal and left turn signal are active
    else if([self digitalRead:inputBrakesState] == LOW && [self digitalRead:inputLeftTurn] == HIGH && [self digitalRead:inputRightTurn] == LOW)
    {
        [self turnSignalLogicForTurnLight:&stateTurnR light1:&stateTailR1 light2:&stateTailR2 light3:&stateTailR3];
        
        //set left tail turn lamps states on
        stateTurnL = LOW;
        stateTailL1 = LOW;
        stateTailL2 = LOW;
        stateTailL3 = LOW;
    }
    // Only left turn signal is active
    else if([self digitalRead:inputBrakesState] == HIGH && [self digitalRead:inputLeftTurn] == LOW && [self digitalRead:inputRightTurn] == HIGH)
    {
        [self turnSignalLogicForTurnLight:&stateTurnL light1:&stateTailL1 light2:&stateTailL2 light3:&stateTailL3];
    }
    // Only right turn signal is active
    else if([self digitalRead:inputBrakesState] == HIGH && [self digitalRead:inputLeftTurn] == HIGH && [self digitalRead:inputRightTurn] == LOW)
    {
        [self turnSignalLogicForTurnLight:&stateTurnR light1:&stateTailR1 light2:&stateTailR2 light3:&stateTailR3];
    }
    // Flahsers signal is active
    else if(1 == 0)
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
    
    
    
    
    
	//no turn signal indicator active
	/*else
	{
		//turn off any left turn lamps that might still be on after left turn signal indicator becomes inactive
		if ((!stateTurnL || !stateTailL1 || !stateTailL2 || !stateTailL3) && (![self digitalRead:inputLeftTurn]))
		{
			//left turn lamps states off
			stateTurnL = HIGH;
			stateTailL1 = HIGH;
			stateTailL2 = HIGH;
			stateTailL3 = HIGH;
			//update left turn lamps relays
			[self digitalWrite:turnL state:stateTurnL];
			[self digitalWrite:tailL1 state:stateTailL1];
			[self digitalWrite:tailL2 state:stateTailL2];
			[self digitalWrite:tailL3 state:stateTailL3];
			
		}
		//turn off any right turn lamps that might still be on after right turn signal indicator becomes inactive
		if ((!stateTurnR || !stateTailR1 || !stateTailR2 || !stateTailR3) && (![self digitalRead:inputRightTurn]))
		{
			//right turn lamps state off
			stateTurnR = HIGH;
			stateTailR1 = HIGH;
			stateTailR2 = HIGH;
			stateTailR3 = HIGH;
			//update right turn lamps relays
			[self digitalWrite:turnR state:stateTurnR];
			[self digitalWrite:tailR1 state:stateTailR1];
			[self digitalWrite:tailR2 state:stateTailR2];
			[self digitalWrite:tailR3 state:stateTailR3];
		}
	}*/
}

@end
