//
//  IngameLayer.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 17/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "IngameLayer.h"
#import "AdvController.h"

@implementation IngameLayer

- (id) init
{
	if ((self = [super init]))
    {
        _inventorySprites = [[NSMutableArray alloc] init];
        
        _locationLayer = [[LocationLayer alloc] init];
        [self addChild:_locationLayer];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) didLoadFromCCB
{
}

- (void) onMenu
{
    [[AdvController sharedController] goToMenu];
}

- (void) onInventory
{
    if (_isInventoryOpen)
    {
        [self closeInventory];
    }
    else
    {
        [self openInventory];
    }
}

- (void) onTake:(id)sender
{
    CCLOG(@"Click Take");
    [[AdvController sharedController] takeObject:_selectedObjectId];
}

- (void) onUse:(id)sender
{
    CCLOG(@"Click Use");
    if (_selectedIsItem)
    {
        [[AdvController sharedController] useItem:_selectedObjectId];
    }
    else
    {
        [[AdvController sharedController] useObject:_selectedObjectId];
    }
}

- (void) showText:(NSString*)text
{
    _selectedObjectId = nil;
    _nodeActionsContainer.visible = NO;
    _labelText.string = text;
    _nodeTextWindow.visible = YES;
//    [_nodeTextWindow stopAllActions];
//    [_nodeTextWindow runAction: [CCFadeIn actionWithDuration:0.5f]];
}

- (void) hideText
{
    _nodeActionsContainer.visible = NO;
    _selectedObjectId = nil;
    _nodeTextWindow.visible = NO;
//    [_nodeTextWindow stopAllActions];
//    [_nodeTextWindow runAction: [CCFadeOut actionWithDuration:0.5f]];
}

- (BOOL) isTextVisible
{
    return _nodeTextWindow.visible;
}

- (void) showTakeForObjectId:(NSString*)objectId
{
    _selectedObjectId = objectId;
    _nodeActionsContainer.visible = YES;
    _buttonTake.visible = YES;
    _buttonUse.visible = NO;
}

- (void) showUseForObjectId:(NSString*)objectId isItem:(BOOL)isItem
{
    _selectedObjectId = objectId;
    _selectedIsItem = isItem;
    _nodeActionsContainer.visible = YES;
    _buttonTake.visible = NO;
    _buttonUse.visible = YES;
}

- (void) openInventory
{
    _isInventoryOpen = YES;
    [_nodeCenter runAction: [CCActionEaseInOut actionWithAction:[CCActionMoveTo actionWithDuration:0.3f position:ccp(_nodeCenter.position.x, 50.0f)] rate:3.0f]];
}

- (void) closeInventory
{
    _isInventoryOpen = NO;
    [_nodeCenter runAction: [CCActionEaseInOut actionWithAction:[CCActionMoveTo actionWithDuration:0.3f position:ccp(_nodeCenter.position.x, 0.0f)] rate:3.0f]];
}

- (AdvObjectSprite*) getAdvObjectAtPosition:(CGPoint)location
{
    for (int i = _inventoryBox.children.count - 1; i >= 0; i--)
    {
        AdvObjectSprite *sprite = [_inventoryBox.children objectAtIndex:i];
        if (sprite != _draggingObject && [sprite hitTestWithWorldPos:location])
        {
            return sprite;
        }
    }
    return nil;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInWorld];

    // text window
    if ([self isTextVisible])
    {
        BOOL clickedInsideText = [_nodeTextWindow hitTestWithWorldPos:location];
        [self hideText];
        if (clickedInsideText)
        {
            return;
        }
    }

    // inventory
    if ([_nodeInventoryWindow hitTestWithWorldPos:location])
    {
        AdvObjectSprite *sprite = [self getAdvObjectAtPosition:location];
        if (sprite)
        {
            CCLOG(@"  object: %@", sprite.objectId);
            [sprite removeFromParent];
            
            sprite.position = [self convertToNodeSpace:location];
            [self addChild:sprite];
            sprite.scale *= 1.5f;
            _draggingObject = sprite;
        }
        return;
    }

    [super touchBegan:touch withEvent:event];
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_draggingObject)
    {
        CGPoint location = [touch locationInWorld];
        _draggingObject.position = [self convertToNodeSpace:location];
        
        // inventory
        if ([_nodeInventoryWindow hitTestWithWorldPos:location])
        {
            _dragginOverLocation = NO;
            if (_draggingOverNode)
            {
                _draggingOverNode = nil;
            }
            AdvObjectSprite *sprite = [self getAdvObjectAtPosition:location];
            if (sprite != _draggingOverObject)
            {
                CCLOG(@"Drag over %@", sprite.objectId);
                _draggingOverObject = sprite;
            }
            return;
        }

        // location
        _dragginOverLocation = YES;
        if (_draggingOverObject)
        {
            _draggingOverObject = nil;
        }

        AdvNode* overNode = [_locationLayer getNodeAtPosition:location];
        if (overNode != _draggingOverNode)
        {
            CCLOG(@"Drag over %@", overNode.itemId);
            _draggingOverNode = overNode;
        }
        
        if ([self isInventoryOpen])
        {
            [self closeInventory];
        }

    }
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_draggingObject)
    {
        CGPoint worldPoint = [_draggingObject convertToWorldSpaceAR:ccp(0,0)];
        [_draggingObject removeFromParent];
        [_inventoryBox addChild:_draggingObject];
        _draggingObject.position = [_inventoryBox convertToNodeSpace:worldPoint];

        if (_dragginOverLocation)
        {
            if (_draggingOverNode)
            {
                [[AdvController sharedController] useObject:_draggingObject.objectId with:_draggingOverNode.itemId];
            }
            else if ([[AdvController sharedController] currentLocation].type == AdvLocationTypePerson)
            {
                [[AdvController sharedController] giveObject:_draggingObject.objectId];
            }
            else
            {
                [self updateInventoryPositionsAnimated:YES];
                if (!_isInventoryOpen)
                {
                    [self openInventory];
                }
            }
        }
        else if (_draggingOverObject)
        {
            [[AdvController sharedController] useObject:_draggingObject.objectId with:_draggingOverObject.objectId];
        }
        else
        {
            [[AdvController sharedController] lookAtObject:_draggingObject.objectId inventory:YES];
        }
        
        _draggingObject = nil;
        _draggingOverNode = nil;
        _draggingOverObject = nil;
        _dragginOverLocation = NO;
    }
}

- (void) addInventoryObject:(NSString*)objectId
{
    NSString* filename = @"gamedata/objects/";
    filename = [filename stringByAppendingString:objectId];
    filename = [filename stringByAppendingString:@".png"];
    AdvObjectSprite* sprite = [AdvObjectSprite spriteWithImageNamed:filename];
    sprite.objectId = objectId;
    
    [_inventoryBox addChild:sprite];
    [_inventorySprites addObject:sprite];
}

- (void) removeInventoryObject:(NSString*)objectId
{
    for (int i = _inventorySprites.count - 1; i >= 0; i--)
    {
        AdvObjectSprite *sprite = [_inventorySprites objectAtIndex:i];
        if ([sprite.objectId isEqualToString:objectId])
        {
            CCActionCallFunc* actionCallFunc = [CCActionCallFunc actionWithTarget:self selector:@selector(removeFromScreen:)];
            [sprite runAction:[CCActionSequence actions:[CCActionSpawn actions:
                                                   [CCActionFadeOut actionWithDuration:0.25f],
                                                   [CCActionScaleTo actionWithDuration:0.25f scale:0.1f],
                                                   nil],
                                                   actionCallFunc, nil]];
            
            [_inventorySprites removeObject:sprite];
            break;
        }
    }
}

- (void) removeFromScreen:(CCNode*)node
{
    [node removeFromParent];
}

- (void) updateInventoryPositionsAnimated:(BOOL)animated
{
    CGRect box = _inventoryBox.boundingBox;
    float distX = box.size.height;
    CGPoint point;
    point.x = box.size.width - distX * 0.5f;
    point.y = box.size.height * 0.5f;
    for (int i = _inventorySprites.count - 1; i >= 0; i--)
    {
        AdvObjectSprite *sprite = [_inventorySprites objectAtIndex:i];
        float finalScale = box.size.height / sprite.contentSize.height;
        [sprite stopAllActions];
        if (animated)
        {
            if (sprite.position.x == 0)
            {
                // new object
                sprite.position = point;
                sprite.opacity = 0;
                sprite.scale = 0.1f;
                [sprite runAction:[CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5f scale:finalScale] rate:3.0f]];
                [sprite runAction:[CCActionFadeIn actionWithDuration:0.5f]];
            }
            else
            {
                // old object
                sprite.opacity = 255;
                if (sprite.scale != finalScale)
                {
                    [sprite runAction:[CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5f scale:finalScale] rate:3.0f]];
                }
                [sprite runAction:[CCActionEaseInOut actionWithAction:[CCActionMoveTo actionWithDuration:0.5f position:point] rate:3.0f]];
            }
        }
        else
        {
            sprite.position = point;
            sprite.scale = finalScale;
        }
        point.x -= distX;
    }
}

@end


@implementation AdvObjectSprite

@end
