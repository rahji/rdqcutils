//
//  SwapNumbers.h
//  rd_qc_utils
//
//  Created by Rob Duarte on 3/26/10.
//  Copyright (c) 2010 rahji.com. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface SwapNumbers : QCPlugIn
{
}

/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@property(assign) BOOL inputEnable;
@property(assign) double inputB;
@property(assign) double inputA;
@property(assign) double outputA;
@property(assign) double outputB;

@end
