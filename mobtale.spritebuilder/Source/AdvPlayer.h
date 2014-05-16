//
//  AdvPlayer.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 31/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvItem.h"

@interface AdvPlayer : NSObject

@property (retain) NSString* locationId;
@property NSMutableArray *inventory;

- (id) initFromURL:(NSURL*)url;
- (void) writeToURL:(NSURL*)url;

- (void) take:(NSString*)itemId;
- (void) drop:(NSString*)itemId;
- (BOOL) has:(NSString*)itemId;
- (BOOL) isObjectTaken:(NSString*)itemId;
- (void) setVariable:(NSString*)var value:(int)value;
- (int) getVariable:(NSString*)var;
- (void) addVariable:(NSString*)var value:(int)value;
- (void) setLocationItemStatus:(NSString*)locationId itemId:(NSString*)id status:(AdvItemStatus)status overwrite:(BOOL)overwrite;
- (AdvItemStatus) getLocationItemStatus:(NSString*)locationId itemId:(NSString*)itemId;

@end
