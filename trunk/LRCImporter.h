//
//  LRCImporter.h
//  rd_qc_utils
//
//  Created by Rob Duarte on 12/30/11.
//  Copyright 2011 rahji.com. All rights reserved.
//

#import <Quartz/Quartz.h>


@interface LRCImporter : QCPlugIn {

}

/*
 Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
 @property double inputFoo;
 @property(assign) NSString* outputBar;
 You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
 */

@property(assign) NSString * inputURL;
@property(assign) BOOL inputUpdate;
@property(assign) double inputOffsetMs;
@property(assign) NSString * outputTitle;
@property(assign) NSString * outputAlbum;
@property(assign) NSString * outputArtist;
@property(assign) NSDictionary * outputStructure;

@end
