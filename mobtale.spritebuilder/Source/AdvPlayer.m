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

- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.locationId forKey:@"locationId"];
    [encoder encodeObject:self.inventory forKey:@"inventory"];
    [encoder encodeObject:self.takenObjects forKey:@"takenObjects"];
    [encoder encodeObject:self.variables forKey:@"variables"];
    [encoder encodeObject:self.locationItemSettings forKey:@"locationItemSettings"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    AdvPlayer *player = [[AdvPlayer alloc] init];
    if (player)
    {
        player.locationId = [decoder decodeObjectForKey:@"locationId"];
        player.inventory = [decoder decodeObjectForKey:@"inventory"];
        player.takenObjects = [decoder decodeObjectForKey:@"takenObjects"];
        player.variables = [decoder decodeObjectForKey:@"variables"];
        player.locationItemSettings = [decoder decodeObjectForKey:@"locationItemSettings"];
    }
    return player;
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
