//
//  AdvPlayer.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 31/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvPlayer.h"

@interface AdvPlayer()
{
    NSMutableArray* _inventory;
    NSMutableArray* _takenObjects;
    NSMutableDictionary* _variables;
    NSMutableDictionary* _locationItemStatus;
}
@end

@implementation AdvPlayer

- (id) init
{
    if (self = [super init])
    {
        _inventory = [[NSMutableArray alloc] init];
        _takenObjects = [[NSMutableArray alloc] init];
        _variables = [[NSMutableDictionary alloc] init];
        _locationItemStatus = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) take:(NSString*)objectId
{
    [_inventory addObject:objectId];
    [_takenObjects addObject:objectId];
}

- (void) drop:(NSString*)objectId
{
    [_inventory removeObject:objectId];
    [_takenObjects addObject:objectId];
}

- (BOOL) has:(NSString*)objectId
{
    return [_inventory indexOfObject:objectId] != NSNotFound;
}

- (BOOL) isObjectTaken:(NSString*)objectId
{
    return [_takenObjects indexOfObject:objectId] != NSNotFound;
}

- (void) setVariable:(NSString*)var value:(int)value
{
    [_variables setObject:[NSNumber numberWithInt:value] forKey:var];
}

- (int) getVariable:(NSString*)var
{
    NSNumber* number = [_variables objectForKey:var];
    if (number)
    {
        return number.intValue;
    }
    return 0;
}

- (void) addVariable:(NSString*)var value:(int)value
{
    int varValue = [[_variables objectForKey:var] intValue];
    varValue += value ? value : 1;
    [_variables setObject:[NSNumber numberWithInt:varValue] forKey:var];
}

- (void) setLocationItemStatus:(NSString*)locationId itemId:(NSString*)itemId status:(NSString*)status overwrite:(BOOL)overwrite
{
    NSMutableDictionary* locationItems = [_locationItemStatus objectForKey:locationId];
	if (!locationItems)
	{
        locationItems = [[NSMutableDictionary alloc] init];
        [_locationItemStatus setObject:locationItems forKey:locationId];
	}
	if (overwrite || ![locationItems objectForKey:itemId])
	{
        [locationItems setObject:[status copy] forKey:itemId];
	}
}

- (NSString*) getLocationItemStatus:(NSString*)locationId itemId:(NSString*)itemId
{
    NSMutableDictionary* locationItems = [_locationItemStatus objectForKey:locationId];
	if (locationItems)
	{
        NSString* status = [locationItems objectForKey:itemId];
		if (status)
		{
			return status;
		}
	}
	return nil;
}

@end
