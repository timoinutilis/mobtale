//
//  Location.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvItem.h"
#import "AdvObject.h"

enum AdvLocationType : NSInteger {
    AdvLocationTypeNormal,
    AdvLocationTypePerson
};
typedef enum AdvLocationType : NSInteger AdvLocationType;


@interface AdvLocation : NSObject

@property (retain) NSString* locationId;
@property (retain) NSString* name;
@property (retain) NSString* image;

@property (readonly) NSMutableArray* items;
@property (readonly) NSMutableArray* objects;
@property (readonly) NSMutableArray* objectActionHandlers;
@property (readonly) NSMutableArray* locationInitCommands;
@property (readonly) AdvLocationType type;

- (id) initWithId:(NSString*)locationId name:(NSString*)name image:(NSString*)image type:(AdvLocationType)type;
- (AdvItem*) getItemById:(NSString*)itemId;
- (AdvObject*) getObjectById:(NSString*)objectId;

@end
