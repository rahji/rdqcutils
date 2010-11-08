//
//  NSArray+Dictionary.m
//  add a category to NSArray to afford conversion to an NSDictionary
//
//  based on http://stackoverflow.com/questions/1414852/convert-nsarray-to-nsdictionary
//

#import "NSArray+Dictionary.h"

@implementation NSArray (indexKeyedDictionaryExtension)

- (NSDictionary *)indexKeyedDictionary
{
    NSUInteger arrayCount = [self count];
    id arrayObjects[arrayCount], objectKeys[arrayCount];
    
    [self getObjects:arrayObjects range:NSMakeRange(0UL, arrayCount)];
    for(NSUInteger index = 0UL; index < arrayCount; index++) { 
        //objectKeys[index] = [NSNumber numberWithUnsignedInteger:index]; 
        objectKeys[index] = [NSString stringWithFormat: @"line%d", index+1]; 
    }
    
    return([NSDictionary dictionaryWithObjects:arrayObjects forKeys:objectKeys count:arrayCount]);
}

@end

