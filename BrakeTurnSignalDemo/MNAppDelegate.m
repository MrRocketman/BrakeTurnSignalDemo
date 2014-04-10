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

- (void)leftLightOn:(int)lightIndex;
- (void)leftLightOff:(int)lightIndex;
- (void)rightLightOn:(int)lightIndex;
- (void)rightLightOff:(int)lightIndex;
- (BOOL)digitalRead:(BOOL)variable;
- (void)manageTurnSignalLightStates:(NSTimer *)timer;

@end


@implementation MNAppDelegate

@synthesize leftBlinkerButton, rightBlinkerButton, brakesButton, leftLight1, leftLight2, leftLight3, leftLights, rightLight1, rightLight2, rightLight3, rightLights;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    leftLights = [[NSArray alloc] initWithObjects:leftLight1, leftLight2, leftLight3, nil];
    rightLights = [[NSArray alloc] initWithObjects:rightLight1, rightLight2, rightLight3, nil];
    
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

- (void)leftLightOn:(int)lightIndex
{
    [[leftLights objectAtIndexedSubscript:lightIndex] setTitle:@"LIGHT"];
    [[leftLights objectAtIndexedSubscript:lightIndex] highlight:YES];
    leftLightStates[lightIndex] = YES;
}

- (void)leftLightOff:(int)lightIndex
{
    [[leftLights objectAtIndexedSubscript:lightIndex] setTitle:@""];
    [[leftLights objectAtIndexedSubscript:lightIndex] highlight:NO];
    leftLightStates[lightIndex] = NO;
}

- (void)rightLightOn:(int)lightIndex
{
    [[rightLights objectAtIndexedSubscript:lightIndex] setTitle:@"LIGHT"];
    [[rightLights objectAtIndexedSubscript:lightIndex] highlight:YES];
    rightLightStates[lightIndex] = YES;
}

- (void)rightLightOff:(int)lightIndex
{
    [[rightLights objectAtIndexedSubscript:lightIndex] setTitle:@""];
    [[rightLights objectAtIndexedSubscript:lightIndex] highlight:NO];
    rightLightStates[lightIndex] = NO;
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
					digitalWrite(turnL, stateTurnL);
					digitalWrite(tailL1, stateTailL1);
					digitalWrite(tailL2, stateTailL2);
					digitalWrite(tailL3, stateTailL3);
				}
				break;
				//sequence left turn signal pattern
			case 1:
				currentMillisL = millis();					//update current time for left turn
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
					digitalWrite(tailL1, stateTailL1);
					digitalWrite(tailL2, stateTailL2);
					digitalWrite(tailL3, stateTailL3);
				}
				break;
				//chase left turn signal pattern
			case 2:
				currentMillisL = millis();					//update current time for left turn
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
					digitalWrite(turnL, stateTurnL);
					digitalWrite(tailL1, stateTailL1);
					digitalWrite(tailL2, stateTailL2);
					digitalWrite(tailL3, stateTailL3);
				}
			default:
				//not valid turn signal pattern detected
				break;
		}
	}
	//right turn signal indicator active
	else if (digitalRead(inputRightTurn) == LOW)
	{
		digitalWrite(brakeRight, HIGH);						//turn off braking indicator right side when right turn is on
		
		switch (flashPattern)
		{
				//basic right turn signal pattern
			case 0:
				currentMillisR = millis();					//update current time for right turn
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
					digitalWrite(turnR, stateTurnR);
					digitalWrite(tailR1, stateTailR1);
					digitalWrite(tailR2, stateTailR2);
					digitalWrite(tailR3, stateTailR3);
				}
				break;
				//sequence right turn signal pattern
			case 1:
				currentMillisR = millis();					//update current time for right turn
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
					digitalWrite(tailR1, stateTailR1);
					digitalWrite(tailR2, stateTailR2);
					digitalWrite(tailR3, stateTailR3);
				}
				break;
				//chase right turn signal pattern
			case 2:
				currentMillisR = millis();					//update current time for right turn
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
					digitalWrite(turnR, stateTurnR);
					digitalWrite(tailR1, stateTailR1);
					digitalWrite(tailR2, stateTailR2);
					digitalWrite(tailR3, stateTailR3);
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
		digitalWrite(brakeLeft, LOW);
		digitalWrite(brakeRight, LOW);
		
		//turn off any left turn lamps that might still be on after left turn signal indicator becomes inactive
		if ((!stateTurnL || !stateTailL1 || !stateTailL2 || !stateTailL3) && (!digitalRead(inputLeftTurn)))
		{
			//left turn lamps states off
			stateTurnL = HIGH;
			stateTailL1 = HIGH;
			stateTailL2 = HIGH;
			stateTailL3 = HIGH;
			//update left turn lamps relays
			digitalWrite(turnL, stateTurnL);
			digitalWrite(tailL1, stateTailL1);
			digitalWrite(tailL2, stateTailL2);
			digitalWrite(tailL3, stateTailL3);
			
		}
		//turn off any right turn lamps that might still be on after right turn signal indicator becomes inactive
		if ((!stateTurnR || !stateTailR1 || !stateTailR2 || !stateTailR3) && (!digitalRead(inputRightTurn)))
		{
			//right turn lamps state off
			stateTurnR = HIGH;
			stateTailR1 = HIGH;
			stateTailR2 = HIGH;
			stateTailR3 = HIGH;
			//update right turn lamps relays
			digitalWrite(turnR, stateTurnR);
			digitalWrite(tailR1, stateTailR1);
			digitalWrite(tailR2, stateTailR2);
			digitalWrite(tailR3, stateTailR3);
		}
	}
}

@end
