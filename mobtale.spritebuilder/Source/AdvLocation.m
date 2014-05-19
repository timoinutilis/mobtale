//
//  Location.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvLocation.h"

@implementation AdvLocation

- (id) initWithId:(NSString *)locationId name:(NSString *)name image:(NSString *)image music:(NSString *)music type:(AdvLocationType)type
{
    if (self = [super init])
    {
        _locationId = locationId;
        _name = name;
        _image = image;
        _music = music;
        _type = type;
        
        _items = [[NSMutableArray alloc] init];
        _objectActionHandlers = [[NSMutableArray alloc] init];
        _locationInitCommands = [[NSMutableArray alloc] init];
    }
    return self;
}

- (AdvItem *) getItemById:(NSString *)itemId
{
    for (AdvItem *item in _items)
    {
        if ([item.itemId isEqualToString:itemId])
        {
            return item;
        }
    }
    return nil;
}

@end
