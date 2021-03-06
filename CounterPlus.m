//
//  CounterPlus.h
//  rd_qc_utils
//
//  Created by Rob Duarte on 11/29/10.
//

/**
 Copyright 2010-2012 Rob Duarte
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 **/

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "CounterPlus.h"

#define	kQCPlugIn_Name				@"Counter Plus"
#define	kQCPlugIn_Description		@"Like the normal counter, but allows for optionally decrementing below zero.  "\
                                     "You can also specify a starting number and an amount by which to increment or decrement."\
                                     "\n\nhttp://code.google.com/p/rdqcutils/"

@implementation CounterPlus

//Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputIncreasing, inputDecreasing, inputAmount, inputStart, inputReset, inputAllowNegatives, outputCount;

+ (NSDictionary*) attributes
{
	//Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	//Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
    
    if([key isEqualToString:@"inputIncreasing"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Increasing Signal", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"inputDecreasing"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Decreasing Signal", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"inputReset"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Reset Signal", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"inputAllowNegatives"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Allow Negatives", QCPortAttributeNameKey,
                [NSNumber numberWithBool:YES], QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"inputAmount"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"By Amount", QCPortAttributeNameKey,
                @"1", QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"inputStart"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Start With", QCPortAttributeNameKey,
                @"0", QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"outputCount"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Count", QCPortAttributeNameKey,
                nil];
        
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputIncreasing",@"inputDecreasing",@"inputReset",@"inputAllowNegatives",@"inputStart",@"inputAmount",@"outputCount",nil];
}

+ (QCPlugInExecutionMode) executionMode
{
	//Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	//Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init]) {
		//Allocate any permanent resource required by the plug-in.
	}
	    
	return self;
}

- (void) finalize
{
	//Release any non garbage collected resources created in -init.
	[super finalize];
}

- (void) dealloc
{
	//Release any resources created in -init.	
	[super dealloc];
}

@end

@implementation CounterPlus (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	//Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	//Return NO in case of fatal failure (this will prevent rendering of the composition to start).
    count = 0;
    firstExecution = TRUE;
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	//Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	/*
     Called by Quartz Composer whenever the plug-in instance needs to execute.
     Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
     Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
     
     The OpenGL context for rendering can be accessed and defined for CGL macros using:
     CGLContextObj cgl_ctx = [context CGLContextObj];
     */
    
    double amount = self.inputAmount;
    BOOL allowNegatives = self.inputAllowNegatives;
    
    if (!allowNegatives && count < 0) { return NO; } // fail to render
    
    if (self.inputReset || firstExecution) {
        count = self.inputStart;
        firstExecution = FALSE;
    } else if (self.inputIncreasing) {
        count += amount;
    } else if (self.inputDecreasing) {
        //short circuit below - works like allowneg || (!allowneg && count-amount>0)
        if (allowNegatives || count-amount > 0) count -= amount;
    }
    
    self.outputCount = count;
    
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
	//Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	//Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end
