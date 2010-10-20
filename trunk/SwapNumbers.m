//
//  SwapNumbers.m
//  rd_qc_utils
//
//  Created by Rob Duarte on 3/26/10.
//  Copyright (c) 2010 rahji.com. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "SwapNumbers.h"

#define	kQCPlugIn_Name				@"Swap Numbers"
#define	kQCPlugIn_Description		@"Swap two numbers, or not."

@implementation SwapNumbers

//Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputEnable, inputB, inputA, outputA, outputB;

+ (NSDictionary*) attributes
{
	//Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	//Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
    
    if([key isEqualToString:@"inputEnable"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Enable Swap", QCPortAttributeNameKey,
                nil];
    
    if([key isEqualToString:@"inputB"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Input B", QCPortAttributeNameKey,
                @"0", QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"inputA"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Input A", QCPortAttributeNameKey,
                @"0", QCPortAttributeDefaultValueKey,
                nil];
    
    if([key isEqualToString:@"outputA"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Output A", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"outputB"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Output B", QCPortAttributeNameKey,
                nil];
    
     
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputA",@"inputB",@"inputEnable",@"outputB",@"outputA",nil];
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

@implementation SwapNumbers (Execution)

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
    
    BOOL enable = self.inputEnable;
    double a = self.inputA;
    double b = self.inputB;
    
    self.outputA = (enable) ? b : a;
    self.outputB = (enable) ? a : b;
    
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
