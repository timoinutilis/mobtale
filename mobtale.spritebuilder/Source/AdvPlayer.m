//
//  AdvPlayer.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 31/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvPlayer.h"
#import "AdvLocationItemSettings.h"

@interface AdvPlayer()

@property NSMutableArray *takenObjects;
@property NSMutableDictionary *variables;
@property NSMutableDictionary *locationItemSettings;

@end

@implementation AdvPlayer

- (id) init
{
    if (self = [super init])
    {
        self.inventory = [NSMutableArray array];
        self.takenObjects = [NSMutableArray array];
        self.variables = [NSMutableDictionary dictionary];
        self.locationItemSettings = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id) initFromURL:(NSURL*)url
{
    if (self = [super init])
    {
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfURL:url];
        if (!data)
        {
            return nil;
        }
        
        self.locationId = data[@"locationId"];
        self.inventory = [NSMutableArray arrayWithArray:data[@"inventory"]];
        self.takenObjects = [NSMutableArray arrayWithArray:data[@"takenObjects"]];
        self.variables = [NSMutableDictionary dictionaryWithDictionary:data[@"variables"]];
        
        self.locationItemSettings = [NSMutableDictionary dictionary];
/*        NSDictionary *locationItemSettingsDict = data[@"locationItemSettings"];
        for (NSString *key in locationItemSettingsDict)
        {
            self.locationItemSettings[key] = [NSMutableDictionary dictionaryWithDictionary:locationItemSettingsDict[key]];
        }*/
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
//    data[@"locationItemSettings"] = _locationItemSettings;
    [data writeToURL:url atomically:YES];
}

- (void) take:(NSString*)itemId
{
    [_inventory addObject:itemId];
    [_takenObjects addObject:itemId];
}

- (void) drop:(NSString*)itemId
{
    [_inventory removeObject:itemId];
    [_takenObjects addObject:itemId];
}

- (BOOL) has:(NSString*)itemId
{
    return [_inventory indexOfObject:itemId] != NSNotFound;
}

- (BOOL) isObjectTaken:(NSString*)itemId
{
    return [_takenObjects indexOfObject:itemId] != NSNotFound;
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

- (AdvLocationItemSettings*) getLocationItemSettings:(NSString*)locationId itemId:(NSString*)itemId create:(BOOL)create
{
    AdvLocationItemSettings *settings = nil;
    NSMutableDictionary *locationItems = [_locationItemSettings objectForKey:locationId];
	if (locationItems)
	{
        settings = [locationItems objectForKey:itemId];
	}
    if (!settings && create)
    {
        settings = [[AdvLocationItemSettings alloc] init];
        if (!locationItems)
        {
            locationItems = [[NSMutableDictionary alloc] init];
            [_locationItemSettings setObject:locationItems forKey:locationId];
        }
        [locationItems setObject:settings forKey:itemId];
    }
	return settings;
}

@end
