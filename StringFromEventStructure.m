//
//  StringFromEventStructure.m
//  rd_qc_utils
//
//  Created by Rob Duarte on 1/12/12.
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

#import "StringFromEventStructure.h"

#define	kQCPlugIn_Name				@"String from LRC/SRT Structure"
#define	kQCPlugIn_Description		@"Takes the output structure from either the LCR Karaoke File Importer or SRT Subtitles File "\
                                     "Importer patches and outputs the appropriate string for the current time, using either the "\
                                     "patch time or external timebase. The order of the input structure must be exactly as output "\
                                     "by the STR or LRC importer patch (ie: sorted descending order by start time).\n\nNote that SRT "\
                                     "structures contain start and end times, where LRC structures contain only a start time. Both are "\
                                     "handled by this patch.\n\nhttp://code.google.com/p/rdqcutils/"

@implementation StringFromEventStructure

//Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputStructure,inputUpdate,outputString;

+ (NSDictionary*) attributes
{
	//Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	//Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
    
    if([key isEqualToString:@"inputStructure"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"LRC/SRT Structure", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"inputUpdate"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Update Signal", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"outputString"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Current String", QCPortAttributeNameKey,
                nil];    
    
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputStructure",@"inputUpdate",@"outputString",nil];
}

+ (QCPlugInExecutionMode) executionMode
{
	//Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	//Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeTimeBase;
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

@implementation StringFromEventStructure (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	//Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	//Return NO in case of fatal failure (this will prevent rendering of the composition to start).
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
    
    if ([self didValueForInputKeyChange:@"inputUpdate"] && self.inputUpdate) {
        
        NSString *output = nil;
        NSArray *tempStructure = self.inputStructure;

        for (id subStructure in tempStructure) {
            if (time >= [[subStructure objectAtIndex:0] floatValue]) {
                if ( [subStructure count] == 2 ||  // ie: it only contains a start time and string (LRC file, not SRT)
                    ([subStructure count] == 3 && time <= [[subStructure objectAtIndex:2] floatValue]) ) {
                    output = [subStructure objectAtIndex:1];
                } else {
                    output = @"";
                }
                break;
            }
        }
        
        self.outputString = output;
    
    }
    
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
