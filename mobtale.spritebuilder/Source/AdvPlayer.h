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

- (id) initFromURL:(NSURL*)url;
- (void) writeToURL:(NSURL*)url;

- (void) take:(NSString*)objectId;
- (void) drop:(NSString*)objectId;
- (BOOL) has:(NSString*)objectId;
- (BOOL) isObjectTaken:(NSString*)objectId;
- (void) setVariable:(NSString*)var value:(int)value;
- (int) getVariable:(NSString*)var;
- (void) addVariable:(NSString*)var value:(int)value;
- (void) setLocationItemStatus:(NSString*)locationId itemId:(NSString*)id status:(AdvItemStatus)status overwrite:(BOOL)overwrite;
- (AdvItemStatus) getLocationItemStatus:(NSString*)locationId itemId:(NSString*)itemId;

@end
