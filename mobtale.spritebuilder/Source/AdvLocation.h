//
//  Location.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvItem.h"

typedef NS_ENUM(int, AdvLocationType)
{
    AdvLocationTypeNormal,
    AdvLocationTypePerson
};

@interface AdvLocation : NSObject

@property NSString *locationId;
@property NSString *name;
@property NSString *image;
@property NSString *music;

@property (readonly) NSMutableArray *items;
@property (readonly) NSMutableArray *objectActionHandlers;
@property (readonly) NSMutableArray *locationInitCommands;
@property (readonly) AdvLocationType type;

- (id) initWithId:(NSString *)locationId name:(NSString *)name image:(NSString *)image music:(NSString *)music type:(AdvLocationType)type;
- (AdvItem *) getItemById:(NSString *)itemId;

@end
