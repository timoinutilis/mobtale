//
//  AdvLocationItemSettings.m
//  mobtale
//
//  Created by Timo Kloss on 17/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "AdvLocationItemSettings.h"

@implementation AdvLocationItemSettings

- (id) init
{
    if (self = [super init])
    {
        _status = AdvItemStatusUndefined;
        _anim = nil;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:_status forKey:@"status"];
    [encoder encodeObject:_anim forKey:@"anim"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    AdvItemStatus status = [decoder decodeIntForKey:@"status"];
    NSString *anim = [decoder decodeObjectForKey:@"anim"];
    AdvLocationItemSettings *settings = [[AdvLocationItemSettings alloc] init];
    settings->_status = status;
    settings->_anim = anim;
    return settings;
}

@end
