//
//  AdvCommand.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvCommand.h"

@implementation AdvCommand

- (id) initWithType:(NSString*)type attributes:(NSMutableDictionary*)attributeDict
{
    if (self = [super init])
    {
        self.type = type;
        self.attributeDict = attributeDict;
    }
    return self;
}

- (NSMutableArray*) createCommandsArray
{
    if (!_commands)
    {
        _commands = [[NSMutableArray alloc] init];
    }
    return _commands;
}

- (NSString*) condition
{
    return [_attributeDict objectForKey:@"if"];
}

@end
