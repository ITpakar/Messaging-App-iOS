//
//  TPKeyboardAvoidingScrollView.h
//  ZergID
//
//  Created by Oleg Koshkin on 05/02/15.
//  Copyright (c) 2015 ZergID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@interface TPKeyboardAvoidingScrollView : UIScrollView <UITextFieldDelegate, UITextViewDelegate>
- (void)contentSizeToFit;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;
@end
