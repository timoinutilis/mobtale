//
//  AdvExecution.m
//  mobtale
//
//  Created by Timo Kloss on 08/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "AdvExecution.h"

@implementation AdvExecution

- (id) initWithCommands:(NSMutableArray*)commands
{
    if (self = [super init])
    {
        _commands = commands;
    }
    return self;
}

- (BOOL) finished
{
    return _index >= _commands.count;
}

- (AdvCommand*) getNextCommand
{
    AdvCommand *command = _commands[_index];
    _index++;
    return command;
}

@end
