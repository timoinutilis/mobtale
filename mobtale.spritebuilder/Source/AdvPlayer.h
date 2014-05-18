//
//  AdvPlayer.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 31/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvItem.h"

@class AdvLocationItemSettings;

@interface AdvPlayer : NSObject <NSCoding>

@property (retain) NSString* locationId;
@property NSMutableArray *inventory;

- (void) take:(NSString*)itemId;
- (void) drop:(NSString*)itemId;
- (BOOL) has:(NSString*)itemId;
- (BOOL) isObjectTaken:(NSString*)itemId;
- (void) setVariable:(NSString*)var value:(int)value;
- (int) getVariable:(NSString*)var;
- (void) addVariable:(NSString*)var value:(int)value;
- (AdvLocationItemSettings*) getLocationItemSettings:(NSString*)locationId itemId:(NSString*)itemId create:(BOOL)create;

@end
