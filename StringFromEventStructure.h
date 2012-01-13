//
//  StringFromEventStructure.h
//  rd_qc_utils
//
//  Created by Rob Duarte on 1/12/12.
//  Copyright (c) 2012 rahji.com. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface StringFromEventStructure : QCPlugIn
{
}

/*
 Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
 @property double inputFoo;
 @property(assign) NSString* outputBar;
 You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
 */

@property(assign) NSDictionary *inputStructure;
@property(assign) BOOL inputUpdate;
@property(assign) NSString *outputString;

@end
