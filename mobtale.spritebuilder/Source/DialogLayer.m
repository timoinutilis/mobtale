//
//  DialogLayer.m
//  mobtale
//
//  Created by Timo Kloss on 23/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DialogLayer.h"

@interface DialogLayer()
{
    CCLabelTTF* _labelTemplate;
}
@end

@implementation DialogLayer

- (void) didLoadFromCCB
{
    _labelTemplate.string = @"Test";
}

@end
