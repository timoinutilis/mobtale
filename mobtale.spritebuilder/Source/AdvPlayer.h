//
//  AdvPlayer.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 31/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdvPlayer : NSObject
{
    NSMutableArray* _inventory;
    NSMutableArray* _takenObjects;
    NSMutableDictionary* _variables;
    NSMutableDictionary* _locationItemStatus;
}

@property (retain) NSString* locationId;

- (void) take:(NSString*)objectId;
- (void) drop:(NSString*)objectId;
- (BOOL) has:(NSString*)objectId;
- (BOOL) isObjectTaken:(NSString*)objectId;
- (void) setVariable:(NSString*)var value:(int)value;
- (int) getVariable:(NSString*)var;
- (void) addVariable:(NSString*)var value:(int)value;
- (void) setLocationItemStatus:(NSString*)locationId itemId:(NSString*)id status:(NSString*)status overwrite:(BOOL)overwrite;
- (NSString*) getLocationItemStatus:(NSString*)locationId itemId:(NSString*)id;

@end
