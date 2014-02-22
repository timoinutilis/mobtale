//
//  AdvExecution.h
//  mobtale
//
//  Created by Timo Kloss on 08/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvCommand.h"

@interface AdvExecution : NSObject

@property (weak) NSMutableArray* commands;
@property int index;

- (id) initWithCommands:(NSMutableArray*)commands;
- (BOOL) finished;
- (AdvCommand*) getCurrentCommand;
- (void) next;

@end
