//
//  NSArray+Dictionary.h
//  add a category to NSArray to afford conversion to an NSDictionary
//
//  based on http://stackoverflow.com/questions/1414852/convert-nsarray-to-nsdictionary
//

#import <Foundation/Foundation.h>

@interface NSArray (indexKeyedDictionaryExtension) 

- (NSDictionary *)indexKeyedDictionary;

@end