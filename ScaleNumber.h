//
//  ScaleNumber.h
//  rd_qc_utils
//
//  Created by Rob Duarte on 10/11/10.
//  Copyright (c) 2010 rahji.com. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface ScaleNumber : QCPlugIn
{
    int handleRange;
}

/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@property(assign) double outputNewNum;
@property(assign) double inputNewMax;
@property(assign) double inputNewMin;
@property(assign) double inputOldMax;
@property(assign) double inputOldMin;
@property(assign) double inputOldNum;

@property int handleRange; 

@end
