//
//  Adventure.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "Adventure.h"

@implementation Adventure

- (id)initWithName:(NSString*)name
{
    if (self = [super init])
    {
        self.name = name;
        _locations = [[NSMutableArray alloc] init];
        _objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (AdvLocation*) getLocationById:(NSString*)locationId
{
    for (AdvLocation* location in _locations)
    {
        if ([location.locationId isEqualToString:locationId])
        {
            return location;
        }
    }
    return nil;
}

- (AdvItem*) getObjectItemById:(NSString*)itemId
{
    for (AdvItem* object in _objects)
    {
        if ([object.itemId isEqualToString:itemId])
        {
            return object;
        }
    }
    return nil;
}

@end
