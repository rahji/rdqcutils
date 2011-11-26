//
//  XYDistance.h
//  rd_qc_utils
//
//  Created by Rob Duarte on 11/26/11.
//  Copyright (c) 2011 rahji.com. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface XYDistance : QCPlugIn
{
}

/*
 Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
 @property double inputFoo;
 @property(assign) NSString* outputBar;
 You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
 */

@property(assign) double inputX1;
@property(assign) double inputY1;
@property(assign) double inputX2;
@property(assign) double inputY2;
@property(assign) double outputDistance;

@end
