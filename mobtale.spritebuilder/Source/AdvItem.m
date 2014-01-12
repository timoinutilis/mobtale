//
//  AdvItem.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvItem.h"

@implementation AdvItem

- (id) initWithId:(NSString*)itemId name:(NSString*)name
{
    if (self = [super init])
    {
        self.itemId = itemId;
        self.name = name;
        _actionHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
