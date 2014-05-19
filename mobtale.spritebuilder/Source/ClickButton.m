//
//  ClickButton.m
//  mobtale
//
//  Created by Timo Kloss on 15/05/14.
//  Copyright (c) 2014 Timo Kloss. All rights reserved.
//

#import "ClickButton.h"
#import "AdvController.h"

@implementation ClickButton

- (void) setHighlighted:(BOOL)highlighted
{
    if (highlighted && highlighted != self.highlighted)
    {
        [[AdvController sharedController] playSound:@"click.wav"];
    }
    [super setHighlighted:highlighted];
}

@end
