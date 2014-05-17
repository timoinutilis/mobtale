//
//  Location.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvItem.h"

enum AdvLocationType : int {
    AdvLocationTypeNormal,
    AdvLocationTypePerson
};
typedef enum AdvLocationType : int AdvLocationType;


@interface AdvLocation : NSObject

@property (retain) NSString* locationId;
@property (retain) NSString* name;
@property (retain) NSString* image;
@property (retain) NSString* music;

@property (readonly) NSMutableArray* items;
@property (readonly) NSMutableArray* objectActionHandlers;
@property (readonly) NSMutableArray* locationInitCommands;
@property (readonly) AdvLocationType type;

- (id) initWithId:(NSString*)locationId name:(NSString*)name image:(NSString*)image music:(NSString*)music type:(AdvLocationType)type;
- (AdvItem*) getItemById:(NSString*)itemId;

@end
