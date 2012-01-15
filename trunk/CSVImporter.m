//
//  CSVImporter.m
//  rd_qc_utils
//
//  Created by Rob Duarte on 10/17/10.
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
#import "CSVImporter.h"
#import "CHCSV.h"
#import "NSArray+Dictionary.h"

#define	kQCPlugIn_Name			@"CSV Importer"
#define	kQCPlugIn_Description	@"Imports a CSV text file from a URL and outputs a structure of structures, containing rows of fields.  "\
                                 "Local files can be imported by specifying a file:// URL  (Remember that an absolute path will have 3 "\
                                 "slashes at its start eg: file:///Users/bill/file.txt).\n\nThe import occurs every time the Update "\
                                 "Signal input goes from LOW to HIGH.\n\nhttp://code.google.com/p/rdqcutils/"

@implementation CSVImporter

//Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputUpdate, inputURL, outputParsed;

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
                @"CSV URL", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"inputUpdate"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Update Signal", QCPortAttributeNameKey,
                //[NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"outputParsed"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Parsed CSV", QCPortAttributeNameKey,
                nil];
    
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputURL",@"inputUpdate",@"outputParsed",nil];
}

+ (QCPlugInExecutionMode) executionMode
{
	//Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProvider;
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


@implementation CSVImporter (Execution)

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
        NSError *err = nil;
        NSString *returnData = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.inputURL] 
                                                usedEncoding:&encoding error:nil];
        if (err != nil) {
            NSLog(@"CSV Importer file open error: %@", [err localizedDescription]);
            return YES;
        }
        
        // NSString -> NSArray -> NSDictionary
        self.outputParsed = [[returnData CSVComponents] indexKeyedDictionary];
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
