//
//  AdvActionHandler.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 09/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvActionHandler.h"

@implementation AdvActionHandler

- (id) initWithType:(NSString*)type
{
    if (self = [super init])
    {
        self.type = type;
        _commands = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
