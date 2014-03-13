//
//  AdvPlayer.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 31/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvPlayer.h"

@interface AdvPlayer()

@property NSMutableArray* inventory;
@property NSMutableArray* takenObjects;
@property NSMutableDictionary* variables;
@property NSMutableDictionary* locationItemStatus;

@end

@implementation AdvPlayer

- (id) init
{
    if (self = [super init])
    {
        self.inventory = [NSMutableArray array];
        self.takenObjects = [NSMutableArray array];
        self.variables = [NSMutableDictionary dictionary];
        self.locationItemStatus = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id) initFromURL:(NSURL*)url
{
    if (self = [super init])
    {
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfURL:url];
        
        self.locationId = data[@"locationId"];
        self.inventory = data[@"inventory"];
        self.takenObjects = data[@"takenObjects"];
        self.variables = data[@"variables"];
        self.locationItemStatus = data[@"locationItemStatus"];
    }
    return self;
}

- (void) writeToURL:(NSURL*)url
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"locationId"] = _locationId;
    data[@"inventory"] = _inventory;
    data[@"takenObjects"] = _takenObjects;
    data[@"variables"] = _variables;
    data[@"locationItemStatus"] = _locationItemStatus;
    [data writeToURL:url atomically:NO];
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

- (void) setLocationItemStatus:(NSString*)locationId itemId:(NSString*)itemId status:(AdvItemStatus)status overwrite:(BOOL)overwrite
{
    NSMutableDictionary* locationItems = [_locationItemStatus objectForKey:locationId];
	if (!locationItems)
	{
        locationItems = [[NSMutableDictionary alloc] init];
        [_locationItemStatus setObject:locationItems forKey:locationId];
	}
	if (overwrite || ![locationItems objectForKey:itemId])
	{
        [locationItems setObject:[NSNumber numberWithInt:status] forKey:itemId];
	}
}

- (AdvItemStatus) getLocationItemStatus:(NSString*)locationId itemId:(NSString*)itemId
{
    NSMutableDictionary* locationItems = [_locationItemStatus objectForKey:locationId];
	if (locationItems)
	{
        NSNumber *statusNumber = [locationItems objectForKey:itemId];
		if (statusNumber)
		{
			return [statusNumber intValue];
		}
	}
	return AdvItemStatusUndefined;
}

@end
