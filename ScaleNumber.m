//
//  ScaleNumber.m
//  rd_qc_utils
//
//  Created by Rob Duarte on 10/11/10.
//  Copyright (c) 2010 rahji.com. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */ 
#import <OpenGL/CGLMacro.h>

#import "ScaleNumber.h"

#define	kQCPlugIn_Name				@"Scale Number"
#define	kQCPlugIn_Description		@"Scale a number up or down, from one min-max range to another.\n\nThe patch settings determine the behavior when the original number is outside the specified original min-max range.  The Range patch can also be a handy partner.\n\nhttp://code.google.com/p/rdqcutils/"

@implementation ScaleNumber

//Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
//@dynamic inputFoo, outputBar;

@dynamic outputNewNum, inputNewMax, inputNewMin, inputOldMax, inputOldMin, inputOldNum;
@synthesize handleRange;

+ (NSDictionary*) attributes
{
	//Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	//Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
    
    if([key isEqualToString:@"inputOldNum"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Original Number", QCPortAttributeNameKey,
                @"0", QCPortAttributeDefaultValueKey,
                nil];    
    if([key isEqualToString:@"inputOldMin"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Original Min", QCPortAttributeNameKey,
                @"0", QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"inputOldMax"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Original Max", QCPortAttributeNameKey,
                @"255", QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"inputNewMin"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Scaled Min", QCPortAttributeNameKey,
                @"0", QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"inputNewMax"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Scaled Max", QCPortAttributeNameKey,
                @"1", QCPortAttributeDefaultValueKey,
                nil];    
    
    if([key isEqualToString:@"outputNewNum"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Scaled Number", QCPortAttributeNameKey,
                nil];
    
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputOldNum",@"inputOldMin",@"inputOldMax",@"inputNewMin",@"inputNewMax",@"outputNewNum",nil];
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

+ (NSArray*) plugInKeys
{
	//Return a list of the KVC keys corresponding to the internal settings of the plug-in.
    return [NSArray arrayWithObjects: @"handleRange", nil];
	
	return nil;
}

- (id) serializedValueForKey:(NSString*)key;
{
	//Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
	//The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
	return [super serializedValueForKey:key];
}

- (void) setSerializedValue:(id)serializedValue forKey:(NSString*)key
{
	//Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
	//Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
	[super setSerializedValue:serializedValue forKey:key];
}

- (QCPlugInViewController*) createViewController
{
	//Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
	//You can return a subclass of QCPlugInViewController if necessary.
	return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"ScaleNumberSettings"];
}

@end

@implementation ScaleNumber (Execution)

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
    
    double oldNum = self.inputOldNum;
    double oldMax = self.inputOldMax;
    double oldMin = self.inputOldMin;
    double newMax = self.inputNewMax;
    double newMin = self.inputNewMin;
    int handle = self.handleRange;

    if (handle != 0 && (oldNum < oldMin || oldNum > oldMax)) {
        
        if (handle == 2) return NO;  // fail to render
        
        // otherwise, handleRange is 1 (clamp the value before doing the math)
        if (oldNum < oldMin) oldNum = oldMin;
        if (oldNum > oldMax) oldNum = oldMax;
        
    } 
        
    self.outputNewNum = (oldNum - oldMin) * (newMax - newMin) / (oldMax - oldMin) + newMin;    
	
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
