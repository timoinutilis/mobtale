//
//  Adventure.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvObject.h"
#import "AdvLocation.h"

@interface Adventure : NSObject

@property (retain) NSString* name;
@property (retain) NSString* info;
@property (readonly) NSMutableArray* locations;
@property (readonly) NSMutableArray* objects;

- (id) initWithName:(NSString*)name;
- (AdvLocation*) getLocationById:(NSString*)locationId;
- (AdvObject*) getObjectById:(NSString*)objectId;

@end
