//
//  DubbTextField.m
//  Dubb
//
//  Created by Oleg Koshkin on 12/03/15.
//  Copyright (c) 2015 dubb.co. All rights reserved.
//

#import "DubbTextField.h"

@implementation DubbTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    if( _padding.width + _padding.height == 0 )
        return CGRectInset( bounds , 10, 5 );
    return CGRectInset( bounds , _padding.width, _padding.height );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    if( _padding.width + _padding.height == 0 )
        return CGRectInset( bounds , 10, 5 );
    
    return CGRectInset( bounds , _padding.width , _padding.height );
}


@end
