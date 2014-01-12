//
//  AdvObject.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvObject.h"

@implementation AdvObject

- (id) initWithId:(NSString*)objectId name:(NSString*)name
{
    if (self = [super init])
    {
        self.objectId = objectId;
        self.name = name;
        
        _actionHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
