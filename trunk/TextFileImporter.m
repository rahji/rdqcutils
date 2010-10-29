//
//  TextFileImporter.h
//  rd_qc_utils
//
//  Created by Rob Duarte on 10/28/10.
//  Copyright (c) 2010 rahji.com. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>
#import "TextFileImporter.h"
#import "NSArray+Dictionary.h"

#define	kQCPlugIn_Name			@"Text File Importer"
#define	kQCPlugIn_Description	@"Imports a plain text file from a URL and outputs a structure containing one member per line.  Local files can be imported by specifying a file:// URL  (Remember that an absolute path will have 3 slashes at its start eg: file:///Users/bill/file.txt).\n\nThe line order structure keys (not the indices).\n\nThe import occurs every time the Update Signal input goes from LOW to HIGH."


@implementation TextFileImporter

//Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputUpdate, inputURL, outputStructure;

+ (NSDictionary*) attributes
{
	//Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	//Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
    if([key isEqualToString:@"inputURL"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Text File URL", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"inputUpdate"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Update Signal", QCPortAttributeNameKey,
                NO, QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"outputStructure"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Structure", QCPortAttributeNameKey,
                nil];
    
	return nil;
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
		// Allocate any permanent resource required by the plug-in.
	}
	return self;
}

- (void) finalize
{
	// Release any non garbage collected resources created in -init.
	[super finalize];
}

- (void) dealloc
{
	// Release any resources created in -init.	
	[super dealloc];
}

@end


@implementation TextFileImporter (Execution)

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

        NSStringEncoding encoding;
        NSString * returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.inputURL] 
                                                    usedEncoding:&encoding error:nil];
        // NSArray -> NSDictionary
        self.outputStructure = [[returnString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] indexKeyedDictionary];
 
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
