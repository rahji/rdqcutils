//
//  LRCImporter.m
//  rd_qc_utils
//
//  Created by Rob Duarte on 12/30/11.
//  Copyright 2011 rahji.com. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>
#import "LRCImporter.h"
#import "RegexKitLite.h"

#define	kQCPlugIn_Name			@"LRC File Importer"
#define	kQCPlugIn_Description	@"Parses a plain text LRC (karaoke) file from a URL and outputs some metadata and a structure of its lyrics (with number of seconds as its key). An offset (in ms) can be specified as an input or in the file itself. A change to the offset input is only recognized when the update input is toggled.\n\nLocal files can be imported by specifying a file:// URL  (Remember that an absolute path will have 3 slashes at its start eg: file:///Users/bill/song.lrc).\n\nThe import occurs every time the Update Signal input goes from LOW to HIGH.\n\nhttp://code.google.com/p/rdqcutils/"


@implementation LRCImporter

//Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputUpdate, inputURL, inputOffsetMs, outputStructure, outputTitle, outputAlbum, outputArtist;

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
                @"LRC File URL", QCPortAttributeNameKey,
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
                @"Lyrics", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"outputTitle"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Song Title", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"outputAlbum"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Album Title", QCPortAttributeNameKey,
                nil];
    if([key isEqualToString:@"outputArtist"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Artist Name", QCPortAttributeNameKey,
                nil];
    
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputURL",@"inputUpdate",@"inputOffsetMs",@"outputStructure",@"outputTitle",@"outputAlbum",@"outputArtist",nil];
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


@implementation LRCImporter (Execution)

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
    
        NSString *title = nil;
        NSString *artist = nil;
        NSString *album = nil;
        float offsetMillis = self.inputOffsetMs;
        
        NSMutableDictionary *output = [NSMutableDictionary dictionary];
        
        NSStringEncoding encoding;
        NSString *returnString = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.inputURL] 
                                                      usedEncoding:&encoding error:nil];
        
        NSArray *linesArray = [returnString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSString *regexString  = @"\\[\\d\\d:\\d\\d\\.\\d\\d\\]";
        
        NSString *lineString;
        for (lineString in linesArray) {

            lineString = [lineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            lineString = [lineString substringToIndex:[lineString length]]; // get rid of trailing bracket
            
            if (title == nil && [lineString hasPrefix:@"[ti:"])
                self.outputTitle = [NSString stringWithString:
                                     [lineString substringWithRange:NSMakeRange(4,[lineString length]-5)] ];
            
            if (artist == nil && [lineString hasPrefix:@"[ar:"])
                self.outputArtist = [NSString stringWithString:
                                     [lineString substringWithRange:NSMakeRange(4,[lineString length]-5)] ];
            
            if (album == nil && [lineString hasPrefix:@"[al:"])
                self.outputAlbum = [NSString stringWithString:
                                     [lineString substringWithRange:NSMakeRange(4,[lineString length]-5)] ];
            
            // if there is no offset yet (from neither the offsetMs input nor the offset: file tag)...
            if (offsetMillis == 0 && [lineString hasPrefix:@"[offset:"])
                // may have + or - in front of the number, which floatValue is okay with
                offsetMillis = [[lineString substringWithRange:NSMakeRange(8,[lineString length]-9)] floatValue];
            
            NSArray *matches = nil;
            matches = [lineString componentsMatchedByRegex:regexString]; // find ALL timestamps
            if (matches == nil || [matches count] == 0) {
                // don't bother with the rest, since no timestamp was found...
                continue;
            }
            
            // find the location of the right-most timestamp
            NSRange lastMatch = [lineString rangeOfString:[matches lastObject] options:NSBackwardsSearch]; 
            
            for (NSString *matchedString in matches) {
                float secs;
                secs = [[matchedString substringWithRange:NSMakeRange(1,2)] floatValue] * 60 // from mm part of [mm:ss.mm]
                + [[matchedString substringWithRange:NSMakeRange(4,5)] floatValue] // from ss.mm part of [mm:ss.mm]
                + offsetMillis / 1000; // offset could be zero (if no offset: tag in file and no value for offset input)
                [output setObject:[lineString substringFromIndex:lastMatch.location+lastMatch.length]
                           forKey:[NSNumber numberWithFloat:secs]];
            }
            
        }
        
        self.outputStructure = output;
        
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
