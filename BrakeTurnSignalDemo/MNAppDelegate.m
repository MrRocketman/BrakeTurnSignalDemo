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

@end


@implementation MNAppDelegate

@synthesize leftBlinkerButton, rightBlinkerButton, brakesButton, brakeLeft, tailL1, tailL2, tailL3, turnL, brakeRight, tailR1, tailR2, tailR3, turnR;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    flashRate = 1000;
    
    // Call manager light states repeatedly
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(manageTurnSignalLightStates:) userInfo:nil repeats:YES];
}

- (IBAction)leftBlinkerButtonPress:(id)sender
{
    if([sender state] == NSOnState)
    {
        inputLeftTurn = YES;
    }
    else
    {
        inputLeftTurn = NO;
    }
}

- (IBAction)rightBlinkerButtonPress:(id)sender
{
    if([sender state] == NSOnState)
    {
        inputRightTurn = YES;
    }
    else
    {
        inputRightTurn = NO;
    }
}

- (IBAction)brakesButtonPress:(id)sender
{
    if([sender state] == NSOnState)
    {
        inputBrakesState = YES;
        /*[self leftLightOn:0];
        [self leftLightOn:1];
        [self leftLightOn:2];
        
        [self rightLightOn:0];
        [self rightLightOn:1];
        [self rightLightOn:2];*/
    }
    else
    {
        inputBrakesState = NO;
        /*[self leftLightOff:0];
        [self leftLightOff:1];
        [self leftLightOff:2];
        
        [self rightLightOff:0];
        [self rightLightOff:1];
        [self rightLightOff:2];*/
    }
}

- (IBAction)flashPatternSegmentedControlChange:(id)sender
{
    flashPattern = (int)[sender selectedSegment];
}

#pragma mark - Light On Off

- (void)digitalWrite:(NSButton *)light state:(BOOL)highOrLow
{
    [light highlight:highOrLow];
}

- (BOOL)digitalRead:(BOOL)variable
{
    return variable;
}

- (unsigned long)millis
{
    return (int)([[NSDate date] timeIntervalSinceReferenceDate] * 1000);
}

#pragma mark - Managment

- (void)manageTurnSignalLightStates:(NSTimer *)timer
{
	//left turn signal indicator active
	if([self digitalRead:inputLeftTurn] == LOW)
	{
        [self digitalWrite:brakeLeft state:HIGH]; //turn off braking inidicator left side when left turn is on
        
		switch (flashPattern)
		{
				//basic left turn signal pattern
			case 0:
				currentMillisL = [self millis];					//update current time for left turn
				//left turn state logic
				if (currentMillisL - previousMillisL > flashRate)
				{
					previousMillisL = currentMillisL;		//save last time left turn changed state
					//all left turn lamps off
					if (stateTurnL && stateTailL1 && stateTailL2 && stateTailL3)
					{
						//set all left tail turn lamps states on
						stateTurnL = LOW;
						stateTailL1 = LOW;
						stateTailL2 = LOW;
						stateTailL3 = LOW;
					}
					//all left turn lamps on
					else
					{
						//set all left tail turn lamps states off
						stateTurnL = HIGH;
						stateTailL1 = HIGH;
						stateTailL2 = HIGH;
						stateTailL3 = HIGH;
					}
					//update left turn lamps relays
					[self digitalWrite:turnL state:stateTurnL];
					[self digitalWrite:tailL1 state:stateTailL1];
					[self digitalWrite:tailL2 state:stateTailL2];
					[self digitalWrite:tailL3 state:stateTailL3];
				}
				break;
				//sequence left turn signal pattern
			case 1:
				currentMillisL = [self millis];					//update current time for left turn
				//left turn lamp state logic
				if (currentMillisL - previousMillisL > flashRate)
				{
					stateTurnL = !stateTurnL;
				}
				//left tail turn lamps state logic
				if (((currentMillisL - previousMillisL)/4) > flashRate)
				{
					//all left tail turn lamps off
					if (stateTailL1 && stateTailL2 && stateTailL3)
					{
						stateTailL1 = LOW;					//set left tail turn lamp inner state on
					}
					//left tail turn lamp inner on, left tail turn lamps middle & outer off
					else if (!stateTailL1 && stateTailL2 && stateTailL3)
					{
						stateTailL2 = LOW;					//set left tail turn lamp middle state on
					}
					//left tail turn lamps inner & middle on, left tail turn lamp outer off
					else if (!stateTailL1 && !stateTailL2 && stateTailL3)
					{
						stateTailL3 = LOW;					//set left tail turn lamp outer state on
					}
					//all left tail turn lamps on
					else
					{
						//set all left tail turn lamps states off
						stateTailL1 = HIGH;
						stateTailL2 = HIGH;
						stateTailL3 = HIGH;
					}
					//update left tail turn lamps relays
					[self digitalWrite:tailL1 state:stateTailL1];
					[self digitalWrite:tailL2 state:stateTailL2];
					[self digitalWrite:tailL3 state:stateTailL3];
				}
				break;
				//chase left turn signal pattern
			case 2:
				currentMillisL = [self millis];					//update current time for left turn
				//left turn lamp state logic
				if (currentMillisL - previousMillisL > flashRate)
				{
					stateTurnL = !stateTurnL;				//toggle left turn lamp state
				}
				//left tail turn lamps state logic
				if (((currentMillisL - previousMillisL)/6) > flashRate)
				{
					//all left tail turn lamps off
					if (stateTailL1 && stateTailL2 && stateTailL3)
					{
						stateTailL1 = LOW;					//set left tail turn lamp inner state on
					}
					//left tail turn lamp inner on, left tail turn lamps middle & outer off
					else if (!stateTailL1 && stateTailL2 && stateTailL3)
					{
						stateTailL2 = LOW;					//set left tail turn lamp middle state on
					}
					//left tail turn lamps inner & middle on, left tail turn lamp outer off
					else if (!stateTailL1 && !stateTailL2 && stateTailL3)
					{
						stateTailL3 = LOW;					//set left tail turn lamp outer state on
					}
					//all left tail turn lamps on
					else if (!stateTailL1 && !stateTailL2 && !stateTailL3)
					{
						stateTailL1 = HIGH;					//set left tail turn lamp inner state off
					}
					//left tail turn lamp inner off, left tail turn lamps middle & outer on
					else if (stateTailL1 && !stateTailL2 && !stateTailL3)
					{
						stateTailL2 = HIGH;					//set left tail turn lamp middle state off
					}
					//left tail turn lamps inner & middle off, left tail turn lamp outer on
					else if (stateTailL1 && stateTailL2 && !stateTailL3)
					{
						stateTailL3 = HIGH;					//set right tail turn lamp outer state off
					}
					else
					{
						//default case do nothing
					}
					//update left turn lamps relays
					[self digitalWrite:turnL state:stateTurnL];
					[self digitalWrite:tailL1 state:stateTailL1];
					[self digitalWrite:tailL2 state:stateTailL2];
					[self digitalWrite:tailL3 state:stateTailL3];
				}
			default:
				//not valid turn signal pattern detected
				break;
		}
	}
	//right turn signal indicator active
	else if([self digitalRead:inputRightTurn] == LOW)
	{
		[self digitalWrite:brakeRight state:HIGH];						//turn off braking indicator right side when right turn is on
		
		switch (flashPattern)
		{
				//basic right turn signal pattern
			case 0:
				currentMillisR = [self millis];					//update current time for right turn
				//right turn state logic
				if (currentMillisR - previousMillisR > flashRate)
				{
					previousMillisR = currentMillisR;		//save last time right turn changed state
					//all right turn lamps off
					if (stateTurnR && stateTailR1 && stateTailR2 && stateTailR3)
					{
						//set all right tail turn lamps states on
						stateTurnR = LOW;
						stateTailR1 = LOW;
						stateTailR2 = LOW;
						stateTailR3 = LOW;
					}
					//all right turn lamps on
					else
					{
						//set all right tail turn lamps states off
						stateTurnR = HIGH;
						stateTailR1 = HIGH;
						stateTailR2 = HIGH;
						stateTailR3 = HIGH;
					}
					//update right turn lamps relays
					[self digitalWrite:turnR state:stateTurnR];
					[self digitalWrite:tailR1 state:stateTailR1];
					[self digitalWrite:tailR2 state:stateTailR2];
					[self digitalWrite:tailR3 state:stateTailR3];
				}
				break;
				//sequence right turn signal pattern
			case 1:
				currentMillisR = [self millis];					//update current time for right turn
				//right turn lamp state logic
				if (currentMillisR - previousMillisR > flashRate)
				{
					stateTurnR = !stateTurnR;
				}
				//right tail turn lamps state logic
				if (((currentMillisR - previousMillisR)/4) > flashRate)
				{
					//all right tail turn lamps off
					if (stateTailR1 && stateTailR2 && stateTailR3)
					{
						stateTailR1 = LOW;					//set right tail turn lamp inner state on
					}
					//right tail turn lamp inner on, right tail turn lamps middle & outer off
					else if (!stateTailR1 && stateTailR2 && stateTailR3)
					{
						stateTailR2 = LOW;					//set right tail turn lamp middle state on
					}
					//right tail turn lamps inner & middle on, right tail turn lamp outer off
					else if (!stateTailR1 && !stateTailR2 && stateTailR3)
					{
						stateTailR3 = LOW;					//set right tail turn lamp outer state on
					}
					//all right tail turn lamps on
					else
					{
						//set all right tail turn lamps states off
						stateTailR1 = HIGH;
						stateTailR2 = HIGH;
						stateTailR3 = HIGH;
					}
					//update right tail turn lamps relays
					[self digitalWrite:tailR1 state:stateTailR1];
					[self digitalWrite:tailR2 state:stateTailR2];
					[self digitalWrite:tailR3 state:stateTailR3];
				}
				break;
				//chase right turn signal pattern
			case 2:
				currentMillisR = [self millis];					//update current time for right turn
				//right turn lamp state logic
				if (currentMillisR - previousMillisR > flashRate)
				{
					stateTurnR = !stateTurnR;				//toggle right turn lamp state
				}
				//right tail turn lamps state logic
				if (((currentMillisR - previousMillisR)/6) > flashRate)
				{
					//all right tail turn lamps off
					if (stateTailR1 && stateTailR2 && stateTailR3)
					{
						stateTailR1 = LOW;					//set right tail turn lamp inner state on
					}
					//right tail turn lamp inner on, right tail turn lamps middle & outer off
					else if (!stateTailR1 && stateTailR2 && stateTailR3)
					{
						stateTailR2 = LOW;					//set right tail turn lamp middle state on
					}
					//right tail turn lamps inner & middle on, right tail turn lamp outer off
					else if (!stateTailR1 && !stateTailR2 && stateTailR3)
					{
						stateTailR3 = LOW;					//set right tail turn lamp outer state on
					}
					//all right tail turn lamps on
					else if (!stateTailR1 && !stateTailR2 && !stateTailR3)
					{
						stateTailR1 = HIGH;					//set right tail turn lamp inner state off
					}
					//right tail turn lamp inner off, right tail turn lamps middle & outer on
					else if (stateTailR1 && !stateTailR2 && !stateTailR3)
					{
						stateTailR2 = HIGH;					//set right tail turn lamp middle state off
					}
					//right tail turn lamps inner & middle off, right tail turn lamp outer on
					else if (stateTailR1 && stateTailR2 && !stateTailR3)
					{
						stateTailR3 = HIGH;					//set right tail turn lamp outer state off
					}
					else
					{
						//default case do nothing
					}
					//update right turn lamps relays
					[self digitalWrite:turnR state:stateTurnR];
					[self digitalWrite:tailR1 state:stateTailR1];
					[self digitalWrite:tailR2 state:stateTailR2];
					[self digitalWrite:tailR3 state:stateTailR3];
				}
			default:
				//not valid turn signal pattern detected
				break;
		}
	}
	//no turn signal indicator active
	else
	{
		//activate brake relays so braking inidicator function is on when no turn lamp indicator is active
		[self digitalWrite:brakeLeft state:LOW];
		[self digitalWrite:brakeRight state:LOW];
		
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
	}
}

@end
