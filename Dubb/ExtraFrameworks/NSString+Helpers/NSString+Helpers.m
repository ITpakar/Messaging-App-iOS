//
//  NSString+Helpers.m
//
//  Created by Oliver on 15.06.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import "NSString+Helpers.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (Helpers)

#pragma mark Helpers
- (NSDate *) dateFromString
{
	NSDate *retDate;
	
	switch ([self length]) 
	{
		case 8:
		{
			NSDateFormatter *dateFormatter8 = [[NSDateFormatter alloc] init];
			[dateFormatter8 setDateFormat:@"yyyyMMdd"]; /* Unicode Locale Data Markup Language */
			[dateFormatter8 setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
			retDate = [dateFormatter8 dateFromString:self];
			return retDate;
		}
		case 10:
		{
			NSDateFormatter *dateFormatterToRead = [[NSDateFormatter alloc] init];
			[dateFormatterToRead setDateFormat:@"MM/dd/yyyy"]; /* Unicode Locale Data Markup Language */
			[dateFormatterToRead setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
			retDate = [dateFormatterToRead dateFromString:self];
			return retDate;
		}
	}
	
	return nil;
}


- (NSString *) stringByUrlDecoding
{
	return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
//	return [(NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, NULL, kCFStringEncodingUTF8) autorelease];
}



- (NSComparisonResult)compareDesc:(NSString *)aString
{
	return -[self compare:aString];
}


// method to calculate a standard md5 checksum of this string, check against: http://www.adamek.biz/md5-generator.php
- (NSString * )md5
{
	const char *cStr = [self UTF8String];
	unsigned char result [CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString 
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
}


+ (NSString *) stringFromFormattingBytes:(NSUInteger)bytes
{
	double kBytes = bytes / 1024.0;
	double mBytes = kBytes / 1024;
	
	if (bytes<1024)
	{
		return [NSString stringWithFormat:@"%ld bytes", bytes];
	}
	else if (kBytes < 1024.0)
	{
		return [NSString stringWithFormat:@"%.2f KB", kBytes];
	}
	else 
	{
		return [NSString stringWithFormat:@"%.2f MB", mBytes];
	}
}

- (NSString *) stringWithLowercaseFirstLetter
{
	return [[[self substringToIndex:1] lowercaseString] stringByAppendingString:[self substringFromIndex:1]];
}

- (NSString *) stringWithUppercaseFirstLetter
{
	return [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
}

- (BOOL)containsNumbersOnly {
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([self rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        return YES; // string consists only of the digits 0 through 9
    } else {
        return NO;
    }
    
}

@end

