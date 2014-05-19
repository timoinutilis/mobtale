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
#import "AdvParser.h"
#import "AdvPlayer.h"
#import "AdvCommand.h"
#import "AdvActionHandler.h"
#import "AdvExecution.h"
#import "LocationLayer.h"
#import "Adventure.h"
#import "AdvLocation.h"
#import "AdvNode.h"
#import "DialogLayer.h"
#import "AdvItem.h"
#import "AdvLocationItemSettings.h"

@implementation AdvController
{
    Adventure *_adventure;
    AdvPlayer *_player;
    NSMutableArray *_stack;
    int _waitingFor;
    NSString *_currentMusic;
}

#pragma mark - Singleton

static AdvController *_sharedController = nil;

+ (AdvController *) sharedController
{
	if (!_sharedController)
    {
		_sharedController = [[AdvController alloc] init];
	}
	return _sharedController;
}

+ (id) alloc
{
	NSAssert(_sharedController == nil, @"Attempted to allocate a second instance of a singleton.");
    
	return [super alloc];
}

- (void) dealloc
{
	_sharedController = nil;
}

- (id) init
{
    if (self = [super init])
    {
        _stack = [NSMutableArray array];
        _waitingFor = ViewEventNone;
    }
    return self;
}

#pragma mark - Controller

- (void) start
{
    // load and parse XML
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filepath = [mainBundle pathForResource:@"adventure" ofType:@"xml"];

    AdvParser *parser = [[AdvParser alloc] init];
    _adventure = [parser createAdventureFromXMLFile:filepath];
    
    // load player
    
    NSData *codedData = [[NSData alloc] initWithContentsOfURL:[self playerURL]];
    if (codedData)
    {
        _player = [NSKeyedUnarchiver unarchiveObjectWithData:codedData];
    }
    
    // go to menu
    
    [self goToMenu:0.5];
}

- (void) goToMenu:(NSTimeInterval)duration
{
    _ingameLayer = nil;
    
    MenuLayer *node = (MenuLayer *) [CCBReader load:@"MenuLayer.ccbi"];
    [node loadImage:@"title.ccbi"];
    CCScene *scene = [CCScene node];
    [scene addChild:node];
    
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:duration]];
    
    [self playMusic:@"title.wav"];
}

- (void) startNewGame
{
    _player = [[AdvPlayer alloc] init];

    AdvLocation *firstLocation = _adventure.locations[0];
    [self enterGameAtLocationId:firstLocation.locationId];
}

- (void) continueGame
{
    NSAssert(_player, @"no player");
    [self enterGameAtLocationId:_player.locationId];
}

- (void) enterGameAtLocationId:(NSString *)locationId
{
    _ingameLayer = (IngameLayer *) [CCBReader load:@"IngameLayer.ccbi"];
    
    CCScene *scene = [CCScene node];
    [scene addChild:_ingameLayer];
    
    for (NSString *itemId in _player.inventory)
    {
        [_ingameLayer addInventoryObject:itemId];
    }

    [self setLocation:locationId];
    
    [[CCDirector sharedDirector] replaceScene:scene withTransition:[CCTransition transitionFadeWithDuration:0.5f]];
}

- (BOOL) canContinueGame
{
    return (_player != nil);
}

- (void) saveCurrentGame
{
    if (_player)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_player];
        [data writeToURL:[self playerURL] atomically:YES];
    }
}

- (NSURL *) playerURL
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *url = [NSURL URLWithString:@"savegame.plist" relativeToURL:urls[0]];
    return url;
}

- (void) endGame
{
    // delete savegame
    [[NSFileManager defaultManager] removeItemAtURL:[self playerURL] error:nil];
    _player = nil;
    
    [self goToMenu:4];
}

- (void) onViewEvent:(ViewEventType)event
{
//    CCLOG(@"onViewEvent: %d - waiting for: %d", event, _waitingFor);
    if (event == _waitingFor)
    {
        _waitingFor = ViewEventNone;
        if ([self isExecuting])
        {
            [self continueExecution];
        }
    }
}

- (void) setLocation:(NSString *)locationId
{
    _player.locationId = locationId;
    
    _currentLocation = [_adventure getLocationById:locationId];
    
    NSString *music = _currentLocation.music;
    [_ingameLayer.locationLayer showLocationImage:_currentLocation.image];
    
    [_ingameLayer.dialogLayer clearItems];
    [self execute:_currentLocation.locationInitCommands enteringLocation:YES];
    
    if (music)
    {
        [self playMusic:music];
    }
    else
    {
        [self stopMusic];
    }
}

- (void) updateDialog
{
    [_ingameLayer.dialogLayer clearItems];
    for (AdvItem *item in _currentLocation.items)
    {
        if ([self getItemStatus:item.itemId] == AdvItemStatusVisible)
        {
            [_ingameLayer.dialogLayer addItemWithText:item.name itemId:item.itemId];
        }
    }
}

- (void) execute:(NSMutableArray *)commands enteringLocation:(BOOL)enteringLocation
{
    [_ingameLayer.dialogLayer hide];
    
    AdvExecution *exec = [[AdvExecution alloc] initWithCommands:commands];
    [_stack addObject:exec];

    [self executeCommands_enteringLocation:enteringLocation];
    [_ingameLayer updateInventoryPositionsAnimated:YES];
    [_ingameLayer setExecutionMode:[self isExecuting]];
}

- (BOOL) isExecuting
{
    return _stack.count > 0;
}

- (void) continueExecution
{
    [self executeCommands_enteringLocation:NO];
    [_ingameLayer updateInventoryPositionsAnimated:YES];
    [_ingameLayer setExecutionMode:[self isExecuting]];
}

- (void) executeCommands_enteringLocation:(BOOL)enteringLocation
{
    while (_stack.count > 0)
    {
        BOOL enteredSub = NO;
        AdvExecution *exec = [_stack lastObject];
        
        while (![exec finished])
        {
            AdvCommand *command = [exec getCurrentCommand];
            NSString *commandName = command.type;
            
            // preconditions
            
            if ([commandName isEqualToString:@"drop"])
            {
                NSString *itemId = command.attributeDict[@"id"];
                if (![_ingameLayer isInventoryOpen] && ![_ingameLayer isDragging:itemId] && [_player isObjectTaken:itemId])
                {
                    [_ingameLayer openInventory];
                    _waitingFor = ViewEventInventoryOpened;
                    return;
                }
            }
            else if ([commandName isEqualToString:@"get"])
            {
                if (![_ingameLayer isInventoryOpen])
                {
                    [_ingameLayer openInventory];
                    _waitingFor = ViewEventInventoryOpened;
                    return;
                }
            }
            else if ([commandName isEqualToString:@"say"])
            {
                if ([_ingameLayer areObjectsMoving])
                {
                    _waitingFor = ViewEventObjectsMoved;
                    return;
                }
                if ([_ingameLayer isInventoryOpen])
                {
                    [_ingameLayer closeInventory];
                    _waitingFor = ViewEventInventoryClosed;
                    return;
                }
            }
            
            // go to next command already, but this is still the execution of the last one
            [exec next];
            
            // command executions
            
            if (command.condition == nil || [self isExpressionTrue:command.condition])
            {
                if ([commandName isEqualToString:@"say"])
                {
                    NSString *text = command.attributeDict[@"text"];
                    [_ingameLayer showText:text];
                    _waitingFor = ViewEventTextHidden;
                    if (!enteringLocation)
                    {
                        [self playSound:@"text.wav"];
                    }
                    return;
                }
                else if ([commandName isEqualToString:@"jump"])
                {
                    NSString *locationId = command.attributeDict[@"to"];
                    [_stack removeAllObjects];
                    [self setLocation:locationId];
                    [self playSound:@"walk.wav"];
                    return;
                }
                else if ([commandName isEqualToString:@"do"])
                {
                    AdvExecution *subExec = [[AdvExecution alloc] initWithCommands:command.commands];
                    [_stack addObject:subExec];
                    enteredSub = YES;
                    break;
                }
                else if ([commandName isEqualToString:@"get"])
                {
                    NSString *itemId = command.attributeDict[@"id"];
                    [self takeItemPrivate:itemId];
                    [self playSound:@"take.wav"];
                }
                else if ([commandName isEqualToString:@"drop"])
                {
                    NSString *itemId = command.attributeDict[@"id"];
                    if ([_currentLocation getItemById:itemId])
                    {
                        [_ingameLayer.locationLayer setNodeVisible:itemId visible:NO];
                    }
                    [_player drop:itemId];
                    [_ingameLayer removeInventoryObject:itemId];
                }
                else if ([commandName isEqualToString:@"show"])
                {
                    NSString *itemId = command.attributeDict[@"id"];
                    NSString *locationId = command.attributeDict[@"location"];
                    AdvLocationItemSettings *settings = [_player getLocationItemSettings:(locationId ? locationId : _currentLocation.locationId) itemId:itemId create:YES];
                    settings.status = AdvItemStatusVisible;
                    if (!locationId || locationId == _currentLocation.locationId)
                    {
                        [_ingameLayer.locationLayer setNodeVisible:itemId visible:YES];
                    }
                }
                else if ([commandName isEqualToString:@"hide"])
                {
                    NSString *itemId = command.attributeDict[@"id"];
                    NSString *locationId = command.attributeDict[@"location"];
                    AdvLocationItemSettings *settings = [_player getLocationItemSettings:(locationId ? locationId : _currentLocation.locationId) itemId:itemId create:YES];
                    settings.status = AdvItemStatusHidden;
                    if (!locationId || locationId == _currentLocation.locationId)
                    {
                        [_ingameLayer.locationLayer setNodeVisible:itemId visible:NO];
                    }
                }
                else if ([commandName isEqualToString:@"set"])
                {
                    NSString *var = command.attributeDict[@"var"];
                    int value = [command.attributeDict[@"value"] intValue];
                    [_player setVariable:var value:(value ? value : 1)];
                }
                else if ([commandName isEqualToString:@"add"])
                {
                    NSString *var = command.attributeDict[@"var"];
                    int value = [command.attributeDict[@"value"] intValue];
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
                else if ([commandName isEqualToString:@"playanim"])
                {
                    NSString *itemId = command.attributeDict[@"id"];
                    NSString *timeline = command.attributeDict[@"timeline"];
                    [_ingameLayer.locationLayer setNodeAnim:itemId timeline:timeline];
                }
                else if ([commandName isEqualToString:@"playsound"])
                {
                    NSString *file = command.attributeDict[@"file"];
                    [self playSound:file];
                }
                else if ([commandName isEqualToString:@"setanim"])
                {
                    NSString *itemId = command.attributeDict[@"id"];
                    NSString *locationId = command.attributeDict[@"location"];
                    NSString *timeline = command.attributeDict[@"timeline"];
                    AdvLocationItemSettings *settings = [_player getLocationItemSettings:(locationId ? locationId : _currentLocation.locationId) itemId:itemId create:YES];
                    settings.anim = timeline;
                    if (!locationId || locationId == _currentLocation.locationId)
                    {
                        [_ingameLayer.locationLayer setNodeAnim:itemId timeline:timeline];
                    }
                }
                else if ([commandName isEqualToString:@"end"])
                {
                    [self endGame];
                }
            }
        }
        if (!enteredSub)
        {
            [_stack removeLastObject];
        }
    }
    
    // end of current script
    if (_currentLocation.type == AdvLocationTypePerson)
    {
        [self updateDialog];
        [_ingameLayer.dialogLayer show];
    }
}

- (BOOL) isExpressionTrue:(NSString *)expression
{
    if (expression.length == 0)
	{
		CCLOG(@"Error: IF expression is empty.");
		return NO;
	}
	NSArray *parts = [expression componentsSeparatedByString:@" "];
	switch (parts.count)
	{
		case 1:
        {
            NSString *part1 = parts[0];
			return ([self parseValue:part1] != 0);
        }
			
		case 2:
        {
            NSString *part1 = parts[0];
            NSString *part2 = parts[1];

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
            NSString *part1 = parts[0];
            NSString *part2 = parts[1];
            NSString *part3 = parts[2];

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

- (int) parseValue:(NSString *)string
{
	int result = 0;
	NSString *numberChars = @"0123456789-";
    NSString *firstChar = [string substringToIndex:1];
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

- (BOOL) useItem:(NSString *)itemId
{
    AdvItem *item = [_currentLocation getItemById:itemId];
    if (item.isObject)
    {
        return [self handleObject:itemId event:@"onuse"];
    }
    else
    {
        for (AdvActionHandler *handler in item.actionHandlers)
        {
            if ([handler.type isEqualToString:@"onuse"])
            {
                [self execute:handler.commands enteringLocation:NO];
                return YES;
            }
        }
    }
    return NO;
}

- (void) takeItem:(NSString *)itemId fromPosition:(CGPoint)point
{
    [_ingameLayer hideText];
    
    [self takeItemPrivate:itemId];
    [_ingameLayer moveObjectToInventory:itemId fromPosition:point];
    [_ingameLayer updateInventoryPositionsAnimated:YES];
    [self playSound:@"take.wav"];
}

- (void) takeItemPrivate:(NSString *)itemId
{
    [_player take:itemId];
    
    [_ingameLayer.locationLayer setNodeVisible:itemId visible:NO];
    [_ingameLayer addInventoryObject:itemId];
}

- (BOOL) lookAtItem:(NSString *)itemId
{
    AdvItem *item = [_currentLocation getItemById:itemId];
    if (!item || item.isObject) // if item is not in location, than maybe it's an object, too.
    {
        return [self handleObject:itemId event:@"onlookat"];
    }
    else
    {
        for (AdvActionHandler *handler in item.actionHandlers)
        {
            if ([handler.type isEqualToString:@"onlookat"])
            {
                [self execute:handler.commands enteringLocation:NO];
                return YES;
            }
        }
    }
    return NO;
}

- (void) useItem:(NSString *)item1Id with:(NSString *)item2Id;
{
    BOOL openInventory = YES;
    if (![self handleUseWith:item2Id handlers:[_adventure getObjectItemById:item1Id].actionHandlers])
	{
		if (![self handleUseWith:item1Id handlers:[_adventure getObjectItemById:item2Id].actionHandlers])
		{
			if ([self handleUseWith:item1Id handlers:[_currentLocation getItemById:item2Id].actionHandlers])
			{
                openInventory = NO;
			}
            else
            {
                [_ingameLayer updateInventoryPositionsAnimated:YES];
                [self playSound:@"move.wav"];
            }
		}
	}
    if (openInventory && ![_ingameLayer isInventoryOpen])
    {
        [_ingameLayer openInventory];
    }
}

- (BOOL) handleUseWith:(NSString *)useWithId handlers:(NSMutableArray*)handlers
{
    if (handlers)
    {
        for (AdvActionHandler *handler in handlers)
        {
            if (   [handler.type isEqualToString:@"onusewith"]
                && [handler.itemId isEqualToString:useWithId])
            {
                [self execute:handler.commands enteringLocation:NO];
                return YES;
            }
        }
    }
	return NO;
}

- (void) giveItem:(NSString *)itemId
{
    if ([self handleObjectInLocation:itemId event:@"ongive"])
    {
        [_ingameLayer closeInventory];
    }
    else
    {
        // not given
        BOOL handled = NO;
        for (AdvActionHandler *handler in _currentLocation.objectActionHandlers)
        {
            if ([handler.type isEqualToString:@"onnoneed"])
            {
                [self execute:handler.commands enteringLocation:NO];
                handled = YES;
                break;
            }
        }
        if (!handled)
        {
            [_ingameLayer updateInventoryPositionsAnimated:YES];
        }
    }
}

- (BOOL) handleObject:(NSString *)itemId event:(NSString *)event
{
    BOOL handled = [self handleObjectInLocation:itemId event:event];
    if (!handled)
    {
        handled = [self handleObjectInDefs:itemId event:event];
    }
    return handled;
}

- (BOOL) handleObjectInLocation:(NSString *)itemId event:(NSString *)event
{
    for (AdvActionHandler *handler in _currentLocation.objectActionHandlers)
    {
        if ([handler.type isEqualToString:event] && [handler.itemId isEqualToString:itemId])
        {
            [self execute:handler.commands enteringLocation:NO];
            return YES;
        }
    }
    return NO;
}

- (BOOL) handleObjectInDefs:(NSString *)itemId event:(NSString *)event
{
    AdvItem *item = [_adventure getObjectItemById:itemId];
    for (AdvActionHandler *handler in item.actionHandlers)
    {
        if ([handler.type isEqualToString:event])
        {
            [self execute:handler.commands enteringLocation:NO];
            return YES;
        }
    }
    return NO;
}

- (BOOL) isItemAvailable:(NSString *)itemId
{
    AdvItem *item = [_currentLocation getItemById:itemId];
    if ([self getItemStatus:itemId] != AdvItemStatusVisible)
    {
        return NO;
    }
    if (item.isObject)
    {
        if ([_player isObjectTaken:itemId])
        {
            return NO;
        }
    }
    return YES;
}

- (AdvItemStatus) getItemStatus:(NSString *)itemId
{
    AdvLocationItemSettings *settings = [_player getLocationItemSettings:_currentLocation.locationId itemId:itemId create:NO];
    if (settings && settings.status != AdvItemStatusUndefined)
    {
        return settings.status;
    }
    return [_currentLocation getItemById:itemId].defaultStatus;
}

- (NSString *) getItemAnim:(NSString *)itemId
{
    AdvLocationItemSettings *settings = [_player getLocationItemSettings:_currentLocation.locationId itemId:itemId create:NO];
    if (settings && settings.anim)
    {
        return settings.anim;
    }
    return nil;
}

- (AdvItem*) getObjectItem:(NSString *)itemId
{
    return [_adventure getObjectItemById:itemId];
}

- (NSString *) getAdvInfo
{
    return _adventure.info;
}

- (void) playMusic:(NSString *)music
{
    if (!_currentMusic || ![_currentMusic isEqualToString:music])
    {
        _currentMusic = music;

        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        
        if (audio.backgroundTrack.playing)
        {
            [audio.backgroundTrack fadeTo:0 duration:0.5 target:self selector:@selector(onMusicFadedOut:)];
        }
        else
        {
            [self onMusicFadedOut:nil];
        }
    }
}

- (void) onMusicFadedOut:(OALAudioTrack*)track
{
    if (_currentMusic)
    {
        NSString *musicFile = [@"music/" stringByAppendingString:_currentMusic];
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        [audio stopBg];
        audio.backgroundTrack.volume = 1;
        [audio playBg:musicFile loop:TRUE];
    }
}

- (void) stopMusic
{
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio stopBg];
    _currentMusic = nil;
}

- (void) playSound:(NSString *)sound
{
    NSString *soundFile = [@"sounds/" stringByAppendingString:sound];
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:soundFile];
}

@end
