//
//  QuotifulActivityProvider.h
//  Quotiful
//
//  Created by andikabijaya on 10/20/14.
//  Copyright (c) 2014 SourcePad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DubbActivityProvider : UIActivityItemProvider<UIActivityItemSource>

@property (nonatomic, weak) NSString *listingTitle;
- (id)initWithListingTitle:(NSString *)listingTitle;

@end
