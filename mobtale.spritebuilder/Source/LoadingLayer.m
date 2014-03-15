//
//  LoadingLayer.m
//  mobtale
//
//  Created by Timo Kloss on 12/01/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "LoadingLayer.h"
#import "AdvController.h"

@implementation LoadingLayer

-(void) onEnter
{
    [[AdvController sharedController] start];
    [super onEnter];
}

@end
