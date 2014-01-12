//
//  AdvController.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 07/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvController.h"
#import "CCBReader.h"
#import "MenuLayer.h"
#import "IngameLayer.h"
#import "AdvParser.h"

@implementation AdvController

#pragma mark - Singleton

static AdvController *_sharedController = nil;

+ (AdvController*) sharedController
{
	if (!_sharedController)
    {
		_sharedController = [[AdvController alloc] init];
	}
	return _sharedController;
}

+(id)alloc
{
	NSAssert(_sharedController == nil, @"Attempted to allocate a second instance of a singleton.");
    
	return [super alloc];
}

- (void) dealloc
{
	_sharedController = nil;
}

#pragma mark - Controller

-(void) loadXML
{
    // load and parse XML
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* filepath = [mainBundle pathForResource:@"adventure" ofType:@"xml"];

    AdvParser* parser = [[AdvParser alloc] init];
    _adventure = [parser createAdventureFromXMLFile:filepath];
    
    // go to menu
    
    [self goToMenu];
}

-(void) goToMenu
{
    _ingameLayer = nil;
    
    MenuLayer* node = (MenuLayer*) [CCBReader load:@"MenuLayer.ccbi"];
    [node loadImage:@"title.ccbi"];
    CCScene* scene = [CCScene node];
    [scene addChild:node];
    
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}

-(void) startNewGame
{
    _player = [[AdvPlayer alloc] init];

    _ingameLayer = (IngameLayer*) [CCBReader load:@"IngameLayer.ccbi"];
    
    CCScene* scene = [CCScene node];
    [scene addChild:_ingameLayer];
    
    AdvLocation* firstLocation = _adventure.locations[0];
    [self setLocation:firstLocation.locationId];
    
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}

-(void) continueGame
{
    
}

-(void) setLocation:(NSString*)locationId
{
    _player.locationId = locationId;
    
    _currentLocation = [_adventure getLocationById:locationId];
    CCLOG(@"Location %@", _currentLocation.locationId);
    
    [_ingameLayer.locationLayer showLocationImage:_currentLocation.image];
    [self execute:_currentLocation.locationInitCommands];
    [_ingameLayer updateInventoryPositionsAnimated:YES];
}

-(BOOL) execute:(NSMutableArray*)commands
{
    for (AdvCommand *command in commands)
    {
        if (command.condition == nil || [self isExpressionTrue:command.condition])
        {
            NSString *commandName = command.type;
            if ([commandName isEqualToString:@"write"])
            {
                NSString* text = command.attributeDict[@"text"];
                [_ingameLayer showText:text];
            }
            else if ([commandName isEqualToString:@"jump"])
            {
                NSString* locationId = command.attributeDict[@"to"];
                [self setLocation:locationId];
                return YES;
            }
            else if ([commandName isEqualToString:@"do"])
            {
                [self execute:command.commands];
            }
            else if ([commandName isEqualToString:@"get"])
            {
                NSString* objectId = command.attributeDict[@"id"];
                [self takeObjectPrivate:objectId];
            }
            else if ([commandName isEqualToString:@"drop"])
            {
                NSString* objectId = command.attributeDict[@"id"];
                if ([_currentLocation getObjectById:objectId])
                {
                    [_ingameLayer.locationLayer setNodeVisible:objectId visible:NO];
                }
                [_player drop:objectId];
                [_ingameLayer removeInventoryObject:objectId];
            }
            else if ([commandName isEqualToString:@"show"])
            {
                NSString* itemId = command.attributeDict[@"id"];
                NSString* locationId = command.attributeDict[@"location"];
                [_player setLocationItemStatus:(locationId ? locationId : _currentLocation.locationId) itemId:itemId status:@"visible" overwrite:true];
                if (!locationId || locationId == _currentLocation.locationId)
                {
                    [_ingameLayer.locationLayer setNodeVisible:itemId visible:YES];
                }
            }
            else if ([commandName isEqualToString:@"hide"])
            {
                NSString* itemId = command.attributeDict[@"id"];
                NSString* locationId = command.attributeDict[@"location"];
                [_player setLocationItemStatus:(locationId ? locationId : _currentLocation.locationId) itemId:itemId status:@"hidden" overwrite:true];
                if (!locationId || locationId == _currentLocation.locationId)
                {
                    [_ingameLayer.locationLayer setNodeVisible:itemId visible:NO];
                }
            }
            else if ([commandName isEqualToString:@"set"])
            {
                NSString* var = command.attributeDict[@"var"];
                int value = command.attributeDict[@"value"];
                [_player setVariable:var value:(value ? value : 1)];
            }
            else if ([commandName isEqualToString:@"add"])
            {
                NSString* var = command.attributeDict[@"var"];
                int value = command.attributeDict[@"value"];
                [_player addVariable:var value:(value ? value : 1)];
            }
            else if ([commandName isEqualToString:@"showimage"])
            {
                //TODO
            }
            else if ([commandName isEqualToString:@"share"])
            {
    /*            if (shareFunction)
                {
                    shareTitle = element.getAttribute("title");
                    shareText = element.getAttribute("text");
                    sharePicture = element.getAttribute("picture");
                    shareFunction(shareTitle, shareText, sharePicture);
                }*/
            }
        }
    }
    return YES;
}

-(BOOL) isExpressionTrue:(NSString*)expression
{
    if (expression.length == 0)
	{
		CCLOG(@"Error: IF expression is empty.");
		return NO;
	}
	NSArray* parts = [expression componentsSeparatedByString:@" "];
	switch (parts.count)
	{
		case 1:
        {
            NSString* part1 = parts[0];
			return ([self parseValue:part1] != 0);
        }
			
		case 2:
        {
            NSString* part1 = parts[0];
            NSString* part2 = parts[1];

            if ([part1 isEqualToString:@"has"])
            {
                return [_player has:part2];
            }
            else if ([part1 isEqualToString:@"hasnot"])
            {
                return ![_player has:part2];
            }
            else if ([part1 isEqualToString:@"not"])
            {
                return ([self parseValue:part2] == 0);
            }
			break;
        }
			
		case 3:
        {
            NSString* part1 = parts[0];
            NSString* part2 = parts[1];
            NSString* part3 = parts[2];

			int value1 = [self parseValue:part1];
			int value2 = [self parseValue:part3];
            
            if ([part2 isEqualToString:@"is"])
            {
                return (value1 == value2);
            }
            else if ([part2 isEqualToString:@"ismin"])
            {
                return (value1 >= value2);
            }
            else if ([part2 isEqualToString:@"ismax"])
            {
                return (value1 <= value2);
            }
            else if ([part2 isEqualToString:@"isnot"])
            {
                return (value1 != value2);
            }
			break;
        }
	}
	CCLOG(@"Error: IF expression '%@' is not valid.", expression);
	return false;
}

- (int) parseValue:(NSString*)string
{
	int result = 0;
	NSString* numberChars = @"0123456789-";
    NSString* firstChar = [string substringToIndex:1];
    if ([numberChars rangeOfString:firstChar].location != NSNotFound)
	{
		// number
		result = string.intValue;
	}
	else
	{
        result = [_player getVariable:string];
	}
	return result;
}

-(void) useItem:(NSString*)objectId
{
    AdvItem* item = [_currentLocation getItemById:objectId];
    for (AdvActionHandler* handler in item.actionHandlers)
    {
        if ([handler.type isEqualToString:@"onuse"])
        {
            [self execute:handler.commands];
            break;
        }
    }
    [_ingameLayer updateInventoryPositionsAnimated:YES];
}

-(void) takeObject:(NSString*)objectId
{
    [_ingameLayer hideText];
    
    [self takeObjectPrivate:objectId];
    [_ingameLayer updateInventoryPositionsAnimated:YES];
}

- (void) takeObjectPrivate:(NSString*)objectId
{
    [_player take:objectId];
    
    [_ingameLayer.locationLayer setNodeVisible:objectId visible:NO];
    [_ingameLayer addInventoryObject:objectId];
}

-(BOOL) lookAtItem:(NSString*)objectId
{
    AdvItem* item = [_currentLocation getItemById:objectId];
    for (AdvActionHandler* handler in item.actionHandlers)
    {
        if ([handler.type isEqualToString:@"onlookat"])
        {
            [self execute:handler.commands];
            [_ingameLayer updateInventoryPositionsAnimated:YES];
            [_ingameLayer showUseForObjectId:objectId isItem:YES];
            return YES;
        }
    }
    return NO;
}

-(void) useObject:(NSString*)objectId
{
    [_ingameLayer closeInventory];
    [self handleObject:objectId event:@"onuse"];
    [_ingameLayer updateInventoryPositionsAnimated:YES];
}

-(void) useObject:(NSString*)objectId with:(NSString*)useWithId
{
    CCLOG(@"Use %@ with %@", objectId, useWithId);
    BOOL openInventory = YES;
    if (![self handleUseWith:useWithId handlers:[_adventure getObjectById:objectId].actionHandlers])
	{
		if (![self handleUseWith:objectId handlers:[_adventure getObjectById:useWithId].actionHandlers])
		{
			if ([self handleUseWith:objectId handlers:[_currentLocation getItemById:useWithId].actionHandlers])
			{
                openInventory = NO;
			}
		}
	}
    if (openInventory && ![_ingameLayer isInventoryOpen])
    {
        [_ingameLayer openInventory];
    }
    [_ingameLayer updateInventoryPositionsAnimated:YES];
}

-(BOOL) handleUseWith:(NSString*)useWithId handlers:(NSMutableArray*)handlers
{
    if (handlers)
    {
        for (AdvActionHandler* handler in handlers)
        {
            if (   [handler.type isEqualToString:@"onusewith"]
                && [handler.objectId isEqualToString:useWithId])
            {
                [self execute:handler.commands];
                return YES;
            }
        }
    }
	return NO;
}


-(void) lookAtObject:(NSString*)objectId inventory:(BOOL)inventory
{
    AdvObject* object = [_adventure getObjectById:objectId];
    if (![self handleObject:objectId event:@"onlookat"])
    {
        [_ingameLayer showText:object.name];
    }
    if (inventory)
    {
        [_ingameLayer showUseForObjectId:object.objectId isItem:NO];
    }
    else
    {
        [_ingameLayer showTakeForObjectId:object.objectId];
    }
    [_ingameLayer updateInventoryPositionsAnimated:YES];
}

-(void) giveObject:(NSString*)objectId
{
    if ([self handleObjectInLocation:objectId event:@"ongive"])
    {
        [_ingameLayer closeInventory];
    }
    else
    {
        // not given
        for (AdvActionHandler* handler in _currentLocation.objectActionHandlers)
        {
            if ([handler.type isEqualToString:@"onnoneed"])
            {
                [self execute:handler.commands];
                break;
            }
        }
    }
    [_ingameLayer updateInventoryPositionsAnimated:YES];
}

-(BOOL) handleObject:(NSString*)objectId event:(NSString*)event
{
    BOOL handled = [self handleObjectInLocation:objectId event:event];
    if (!handled)
    {
        handled = [self handleObjectInDefs:objectId event:event];
    }
    return handled;
}

-(BOOL) handleObjectInLocation:(NSString*)objectId event:(NSString*)event
{
    for (AdvActionHandler* handler in _currentLocation.objectActionHandlers)
    {
        if ([handler.type isEqualToString:event] && [handler.objectId isEqualToString:objectId])
        {
            [self execute:handler.commands];
            return YES;
        }
    }
    return NO;
}

-(BOOL) handleObjectInDefs:(NSString*)objectId event:(NSString*)event
{
    AdvObject* object = [_adventure getObjectById:objectId];
    for (AdvActionHandler* handler in object.actionHandlers)
    {
        if ([handler.type isEqualToString:event])
        {
            [self execute:handler.commands];
            return YES;
        }
    }
    return NO;
}

- (BOOL) isNodeAvailable:(AdvNode*)advNode
{
    if (advNode.isObject)
    {
        if ([_player isObjectTaken:advNode.itemId])
        {
            return NO;
        }
    }
    else
    {
        if ([_player getLocationItemStatus:_currentLocation.locationId itemId:advNode.itemId])
        {
            return NO;
        }
    }
    return YES;
}


@end
