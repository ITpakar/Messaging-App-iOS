//
//  CharactersEscapeService.h
//  Dubb
//
//  Created by Oleg Koshkin on 24/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface CharactersEscapeService : NSObject

+ (NSString *)escape:(NSString *)unescapedString;
+ (NSString *)unescape:(NSString *)escapedString;

@end
