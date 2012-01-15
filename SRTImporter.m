//
//  SRTImporter.m
//  rd_qc_utils
//
//  Created by Rob Duarte on 1/13/12.
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
#import "SRTImporter.h"
#import "RegexKitLite.h"

#define	kQCPlugIn_Name			@"SRT Subtitles File Importer"
#define	kQCPlugIn_Description	@"Parses a plain text SRT (SubRip) subtitles file from a URL and outputs a structure."\
                                "Each item of the structure is a sub-structure with 3 items: start time, subtitle, end time. "\
                                "The structure is sorted in descending order by start time, which is required by the String From"\
                                " LRC/SRT Structure patch.\n\nAn offset (in ms) can be specified as an input - any changes to the offset "\
                                "are only recognized when the update input is toggled.\n\nLocal files can be "\
                                "imported by specifying a file:// URL  (Remember that an absolute path will have 3 slashes at its start eg:"\
                                " file:///Users/bill/subs.srt).\n\nThe import occurs every time the Update Signal input goes from LOW to "\
                                "HIGH.\n\nhttp://code.google.com/p/rdqcutils/"

@implementation SRTImporter

//Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputUpdate, inputURL, inputOffsetMs, outputStructure;

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
                @"SRT File URL", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"inputUpdate"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Update Signal", QCPortAttributeNameKey,
                //[NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"inputOffsetMs"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Offset Ms", QCPortAttributeNameKey,
                @"0", QCPortAttributeDefaultValueKey,
                nil];
    if([key isEqualToString:@"outputStructure"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Subtitles", QCPortAttributeNameKey,
                nil];
    
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputURL",@"inputUpdate",@"inputOffsetMs",@"outputStructure",nil];
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


@implementation SRTImporter (Execution)

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
        
        float offsetMillis = self.inputOffsetMs;
        
        NSStringEncoding encoding;
        NSError *err = nil;
        NSString *returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.inputURL] 
                                                      usedEncoding:&encoding error:&err];
        if (err != nil) {
            NSLog(@"SRT Importer file open error: %@", [err localizedDescription]);
            return YES;
        }
                
        NSArray *linesArray = [returnString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        NSArray *split = nil;
        NSString *splitRegex = @"(,|:|\\s+-->\\s+)";
        NSMutableArray *output = [NSMutableArray arrayWithCapacity:[linesArray count]/3];
        NSMutableString *subtitleString = [NSMutableString stringWithCapacity:20];
        
        BOOL inEntry = FALSE;
        float startTime;
        float endTime;
        
        id lastLine = [linesArray lastObject];
        
        for (id lineString in linesArray) {

            if (!inEntry && [[lineString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] isEqualToString:@""]) {
                // the line contains a number only - this is the start of a new entry
                [subtitleString setString:@""];
                startTime = 0;
                endTime = 0;                
                inEntry = TRUE;
            }
        
            else if (inEntry && [lineString isNotEqualTo:@""]) { 
                // we're in an entry and it's not a blank line - see what kind of line it is, timespan or subtitle
                split = [lineString componentsSeparatedByRegex:splitRegex];
                if ([split count] == 15) { 
                    // this is a timespan - store the values
                    startTime = [[split objectAtIndex:0] floatValue]*3600 + [[split objectAtIndex:2] floatValue]*60 
                        + [[split objectAtIndex:4] floatValue] + [[split objectAtIndex:6] floatValue]/1000;
                    endTime = [[split objectAtIndex:8] floatValue]*3600 + [[split objectAtIndex:10] floatValue]*60
                        + [[split objectAtIndex:12] floatValue] + [[split objectAtIndex:14] floatValue]/1000;
                } else {
                    // this is a subtitle line - add it to our running multi-line string
                    [subtitleString appendFormat:@"%@\n",lineString];
                }
            }
             
            // next condition might evaluate to true if the current line is not empty (ie: it was handled by the above conditional)
            // but we're at the end of the file.  it also takes place if we hit a blank line. either signals the end of an entry.
            if (inEntry && ([lineString isEqualToString:@""] || lineString == lastLine)) { 
                // we've hit the end of the entry (or end of file) - store the whole entry as a single element in the output array
                startTime += (offsetMillis/1000); // adjust for offset from input port
                endTime += (offsetMillis/1000); // adjust for offset from input port
                [output addObject:[NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:startTime],
                                   [subtitleString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]], // del last /n
                                   [NSNumber numberWithFloat:endTime],
                                   nil
                                   ]];
                inEntry = FALSE; // reset the flag and the variables for the next entry
            }
                    
        }
        
        if (output != nil) {
            self.outputStructure = [output sortedArrayUsingComparator:^(id a, id b) {
                NSNumber *first = [(NSArray*)a objectAtIndex:0];
                NSNumber *second = [(NSArray*)b objectAtIndex:0];
                return [second compare:first];
            }];
        } else {
            self.outputStructure = nil;
        }
        
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
