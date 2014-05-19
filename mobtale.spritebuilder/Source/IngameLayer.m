//
//  IngameLayer.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 17/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "IngameLayer.h"
#import "AdvController.h"
#import "Support/CGPointExtension.h"
#import "DialogLayer.h"
#import "LocationLayer.h"
#import "AdvItem.h"
#import "Adventure.h"
#import "AdvNode.h"

@implementation IngameLayer
{
    CCButton *_buttonMenu;
    CCButton *_buttonInventory;
    CCButton *_buttonTake;
    CCButton *_buttonUse;
    CCNode *_nodeCenter;
    CCNode *_nodeTextWindow;
    CCNode *_nodeActionsContainer;
    CCLabelTTF *_labelText;
    CCNode *_nodeInventoryWindow;
    CCNode *_inventoryBox;
    
    CCNode *_objectInfo;
    CCNode *_objectInfoTarget;
    CCLabelTTF *_infoLabel;
    
    BOOL _objectMoved;
    CGPoint _dragStartPoint;
    ObjectSprite *_draggingObject;
    AdvNode *_draggingOverNode;
    ObjectSprite *_draggingOverObject;
    BOOL _draggingOverLocation;
    ObjectSprite *_selectedObject;
    
    NSMutableArray *_inventorySprites;
    BOOL _areObjectsMoving;
    BOOL _objectsDirty;
}

- (id) init
{
	if ((self = [super init]))
    {
        _inventorySprites = [[NSMutableArray alloc] init];
        
        self.userInteractionEnabled = YES;
        self.claimsUserInteraction = YES;
    }
    return self;
}

- (void) didLoadFromCCB
{
    _dialogLayer.zOrder = -1;
    _dialogLayer.visible = NO;

    _locationLayer = [[LocationLayer alloc] initWithIngameLayer:self];
    [self addChild:_locationLayer z:-2];
    
    _objectInfo = [CCBReader load:@"ObjectInfo.ccbi" owner:self];
    
    [self hideText];
}

- (void) onMenu
{
    if (![[AdvController sharedController] isExecuting])
    {
        [[AdvController sharedController] goToMenu:0.5];
    }
}

- (void) onInventory
{
    if (![[AdvController sharedController] isExecuting])
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
}

- (void) setExecutionMode:(BOOL)active
{
    if (active)
    {
        _buttonInventory.visible = NO;
        _buttonMenu.visible = NO;
    }
    else
    {
        _buttonInventory.visible = YES;
        _buttonMenu.visible = YES;
    }
}

- (void) showObjectInfoFor:(CCNode *)node text:(NSString *)text
{
    [self hideObjectInfo];
    
    _objectInfoTarget = node;
    _infoLabel.string = text;
    [self addChild:_objectInfo];
    [self updateObjectInfo];
}

- (void) showObjectInfoFor:(CCNode *)node useItemId:(NSString *)itemId
{
    AdvItem *item = [[AdvController sharedController] getObjectItem:itemId];
    NSString *info = [NSString stringWithFormat:@"Use %@ with...", item.name];
    [self showObjectInfoFor:node text:info];
}

- (void) showObjectInfoFor:(CCNode *)node useItemId:(NSString *)item1Id withItemId:(NSString *)item2Id
{
    AdvItem *item1 = [[AdvController sharedController] getObjectItem:item1Id];
    AdvItem *item2 = [[AdvController sharedController] getObjectItem:item2Id];
    if (!item2)
    {
        item2 = [[[AdvController sharedController] currentLocation] getItemById:item2Id];
    }
    NSString *info = [NSString stringWithFormat:@"Use %@ with %@", item1.name, item2.name];
    [self showObjectInfoFor:node text:info];
}

- (void) showObjectInfoFor:(CCNode *)node giveItemId:(NSString *)itemId
{
    AdvItem *item = [[AdvController sharedController] getObjectItem:itemId];
    NSString *info = [NSString stringWithFormat:@"Give %@", item.name];
    [self showObjectInfoFor:node text:info];
}

- (void) hideObjectInfo
{
    if (_objectInfoTarget)
    {
        [_objectInfo removeFromParent];
        _objectInfoTarget = nil;
    }
}

- (void) updateObjectInfo
{
    if (_objectInfoTarget)
    {
        CGSize size = _objectInfoTarget.contentSize;
        CGPoint point = [_objectInfoTarget convertToWorldSpace:ccp(size.width * 0.5f, size.height)];
        _objectInfo.position = [self convertToNodeSpace:point];
    }
}

- (void) showText:(NSString *)text
{
    _nodeActionsContainer.visible = NO;
    _labelText.string = text;
    _nodeTextWindow.visible = YES;
}

- (void) hideText
{
    _nodeActionsContainer.visible = NO;
    _nodeTextWindow.visible = NO;
}

- (BOOL) isTextVisible
{
    return _nodeTextWindow.visible;
}

- (void) openInventory
{
    _isInventoryOpen = YES;
    [_nodeCenter stopAllActions];
    CCActionEaseInOut *actionMove = [CCActionEaseInOut actionWithAction:[CCActionMoveTo actionWithDuration:0.3f position:ccp(_nodeCenter.position.x, 50.0f)] rate:3.0f];
    [_nodeCenter runAction:[CCActionSequence actionOne:actionMove two:[CCActionCallBlock actionWithBlock:^{
        [[AdvController sharedController] onViewEvent:ViewEventInventoryOpened];
    }]]];
    
    [_dialogLayer fadeOut];
}

- (void) closeInventory
{
    if (_isInventoryOpen)
    {
        _isInventoryOpen = NO;
        [_nodeCenter stopAllActions];
        CCActionEaseInOut *actionMove = [CCActionEaseInOut actionWithAction:[CCActionMoveTo actionWithDuration:0.3f position:ccp(_nodeCenter.position.x, 0.0f)] rate:3.0f];
        [_nodeCenter runAction:[CCActionSequence actionOne:actionMove two:[CCActionCallBlock actionWithBlock:^{
            [[AdvController sharedController] onViewEvent:ViewEventInventoryClosed];
        }]]];

        if (!_draggingObject)
        {
            [_dialogLayer fadeIn];
        }
    }
}

- (ObjectSprite *) getInventoryObjectAtPosition:(CGPoint)location
{
    for (int i = (int)_inventoryBox.children.count - 1; i >= 0; i--)
    {
        ObjectSprite *sprite = [_inventoryBox.children objectAtIndex:i];
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
    
    if ([[AdvController sharedController] isExecuting])
    {
        return;
    }

    // inventory
    if ([_nodeInventoryWindow hitTestWithWorldPos:location])
    {
        [_locationLayer unselect];
        ObjectSprite *sprite = [self getInventoryObjectAtPosition:location];
        if (sprite)
        {
            _dragStartPoint = location;
            _draggingObject = sprite;
            _objectMoved = NO;
            [[AdvController sharedController] playSound:@"touch.wav"];
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
        
        if (!_objectMoved)
        {
            CGFloat dist = ccpDistance(location, _dragStartPoint);
            if (dist >= 10)
            {
                [self showObjectInfoFor:_draggingObject useItemId:_draggingObject.itemId];
                
                _objectMoved = YES;
                _selectedObject = nil;

                [_draggingObject removeFromParent];
                _draggingObject.position = [self convertToNodeSpace:location];
                [self addChild:_draggingObject];
                _draggingObject.scale *= 1.5f;

                [self updateObjectInfo];
            }
        }
        else
        {
            _draggingObject.position = [self convertToNodeSpace:location];
            [self updateObjectInfo];
            
            // inventory
            if ([_nodeInventoryWindow hitTestWithWorldPos:location])
            {
                _draggingOverLocation = NO;
                if (_draggingOverNode)
                {
                    _draggingOverNode = nil;
                }
                ObjectSprite *sprite = [self getInventoryObjectAtPosition:location];
                if (sprite != _draggingOverObject)
                {
                    _draggingOverObject = sprite;
                    
                    if (_draggingOverObject)
                    {
                        [self showObjectInfoFor:_draggingObject useItemId:_draggingObject.itemId withItemId:_draggingOverObject.itemId];
                    }
                    else
                    {
                        [self showObjectInfoFor:_draggingObject useItemId:_draggingObject.itemId];
                    }
                }
                return;
            }

            // location
            if (!_draggingOverLocation)
            {
                [self closeInventory];
                if ([[[AdvController sharedController] currentLocation] type] == AdvLocationTypePerson)
                {
                    [self showObjectInfoFor:_draggingObject giveItemId:_draggingObject.itemId];
                }
            }
            _draggingOverLocation = YES;
            if (_draggingOverObject)
            {
                _draggingOverObject = nil;
            }

            AdvNode *overNode = [_locationLayer getNodeAtPosition:location];
            if (overNode != _draggingOverNode)
            {
                _draggingOverNode = overNode;
                
                if (_draggingOverNode)
                {
                    [self showObjectInfoFor:_draggingObject useItemId:_draggingObject.itemId withItemId:_draggingOverNode.itemId];
                }
                else
                {
                    [self showObjectInfoFor:_draggingObject useItemId:_draggingObject.itemId];
                }
            }
        }
    }
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([self isTextVisible])
    {
        [self hideText];
        [[AdvController sharedController] onViewEvent:ViewEventTextHidden];
        return;
    }

    if (_draggingObject)
    {
        if (_objectMoved)
        {
            [self hideObjectInfo];
            
            CGPoint worldPoint = [_draggingObject convertToWorldSpaceAR:ccp(0,0)];
            [_draggingObject removeFromParent];
            [_inventoryBox addChild:_draggingObject];
            _draggingObject.position = [_inventoryBox convertToNodeSpace:worldPoint];
            _objectsDirty = YES;
            
            if (_draggingOverLocation)
            {
                if (_draggingOverNode)
                {
                    [[AdvController sharedController] useItem:_draggingObject.itemId with:_draggingOverNode.itemId];
                }
                else if ([[AdvController sharedController] currentLocation].type == AdvLocationTypePerson)
                {
                    [[AdvController sharedController] giveItem:_draggingObject.itemId];
                }
                else
                {
                    if (!_isInventoryOpen)
                    {
                        [self openInventory];
                    }
                    [self updateInventoryPositionsAnimated:YES];
                    [[AdvController sharedController] playSound:@"move.wav"];
                }
            }
            else if (_draggingOverObject)
            {
                [[AdvController sharedController] useItem:_draggingObject.itemId with:_draggingOverObject.itemId];
            }
            else
            {
                [self updateInventoryPositionsAnimated:YES];
                [[AdvController sharedController] playSound:@"move.wav"];
            }
        }
        else
        {
            // tapped
            if (_draggingObject == _selectedObject)
            {
                // second tap
                BOOL handled = [[AdvController sharedController] useItem:_draggingObject.itemId];
                if (handled)
                {
                    [self hideObjectInfo];
                    _selectedObject = nil;
                }
            }
            else
            {
                // first tap
                AdvItem *item = [[AdvController sharedController] getObjectItem:_draggingObject.itemId];
                [self showObjectInfoFor:_draggingObject text:item.name];
                _selectedObject = _draggingObject;
            }
        }
        
        _draggingObject = nil;
        _draggingOverNode = nil;
        _draggingOverObject = nil;
        _draggingOverLocation = NO;
    }
    else
    {
        _selectedObject = nil;
    }
}

- (void) addInventoryObject:(NSString *)itemId
{
    NSString *filename = [self getFilenameForObject:itemId];
    ObjectSprite *sprite = [ObjectSprite spriteWithImageNamed:filename];
    sprite.itemId = itemId;
    
    [_inventoryBox addChild:sprite];
    [_inventorySprites addObject:sprite];
    _objectsDirty = YES;
}

- (void) removeInventoryObject:(NSString *)itemId
{
    for (int i = (int)_inventorySprites.count - 1; i >= 0; i--)
    {
        ObjectSprite *sprite = [_inventorySprites objectAtIndex:i];
        if ([sprite.itemId isEqualToString:itemId])
        {
            CCActionCallBlock *actionCall = [CCActionCallBlock actionWithBlock:^{
                [sprite removeFromParent];
            }];
            [sprite runAction:[CCActionSequence actions:[CCActionSpawn actions:
                                                   [CCActionFadeOut actionWithDuration:0.25f],
                                                   [CCActionScaleTo actionWithDuration:0.25f scale:0.1f],
                                                   nil],
                                                   actionCall, nil]];
            
            [_inventorySprites removeObject:sprite];
            _objectsDirty = YES;
            break;
        }
    }
}

- (void) updateInventoryPositionsAnimated:(BOOL)animated
{
    if (!_objectsDirty)
        return;
    
    CCLOG(@"updateInventoryPositionsAnimated");
    CGRect box = _inventoryBox.boundingBox;
    float distX = box.size.height;
    CGPoint point;
    point.x = box.size.width - distX * 0.5f;
    point.y = box.size.height * 0.5f;
    for (int i = (int)_inventorySprites.count - 1; i >= 0; i--)
    {
        ObjectSprite *sprite = [_inventorySprites objectAtIndex:i];
        float finalScale = box.size.height / sprite.contentSize.height;
        [sprite stopAllActions];
        if (animated)
        {
            if (sprite.position.x == 0)
            {
                // new object
                sprite.position = point;
                sprite.opacity = 0.0f;
                sprite.scale = 0.1f;
                [sprite runAction:[CCActionEaseInOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5f scale:finalScale] rate:3.0f]];
                [sprite runAction:[CCActionFadeIn actionWithDuration:0.5f]];
            }
            else
            {
                // old object
                sprite.opacity = 1.0f;
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
    if (animated)
    {
        _areObjectsMoving = YES;
        [self runAction:[CCActionSequence actionOne:[CCActionDelay actionWithDuration:0.5f] two:[CCActionCallBlock actionWithBlock:^{
            _areObjectsMoving = NO;
            [[AdvController sharedController] onViewEvent:ViewEventObjectsMoved];
        }]]];
    }
    _objectsDirty = NO;
}

- (BOOL) areObjectsMoving
{
    return _objectsDirty || _areObjectsMoving;
}

- (BOOL) isDragging:(NSString *)itemId
{
    return _draggingObject != nil && [_draggingObject.itemId isEqualToString:itemId];
}

- (void) unselect
{
    [self hideObjectInfo];
    _selectedObject = nil;
}

- (void) moveObjectToInventory:(NSString *)itemId fromPosition:(CGPoint)point
{
    NSString *filename = [self getFilenameForObject:itemId];
    CCSprite *sprite = [ObjectSprite spriteWithImageNamed:filename];
    sprite.scale = 0.3f;
    sprite.position = point;
    [self addChild:sprite z:1];
    CGPoint toPoint = [_buttonInventory convertToWorldSpaceAR:ccp(0, 0)];
    
    CCActionFadeIn *actionFadeIn = [CCActionFadeIn actionWithDuration:0.5f];
//    CCActionEaseInOut *actionMove = [CCActionEaseInOut actionWithAction:[CCActionMoveTo actionWithDuration:1.0f position:toPoint] rate:3.0f];

    CGPoint control1 = ccp(point.x * 0.75 + toPoint.x * 0.25f, point.y * 0.75f + toPoint.y * 0.25f + 100.0f);
    CGPoint control2 = ccp(point.x * 0.25 + toPoint.x * 0.75f, point.y * 0.25f + toPoint.y * 0.75f + 100.0f);
    ccBezierConfig bezier = {toPoint, control1, control2};
    CCActionBezierTo *actionMove = [CCActionBezierTo actionWithDuration:1.0f bezier:bezier];
    
    CCActionSpawn *actionFadeOut = [CCActionSpawn actions:
                                   [CCActionFadeOut actionWithDuration:0.25f],
                                   [CCActionScaleTo actionWithDuration:0.25f scale:0.1f],
                                   nil];
    CCActionCallBlock *actionCall = [CCActionCallBlock actionWithBlock:^{
        [sprite removeFromParent];
    }];

    [sprite runAction:[CCActionSequence actions:[CCActionSpawn actionOne:actionFadeIn two:actionMove], actionFadeOut, actionCall, nil]];

}

- (NSString *) getFilenameForObject:(NSString *)itemId
{
    NSString *filename = @"objects/";
    filename = [filename stringByAppendingString:itemId];
    filename = [filename stringByAppendingString:@".png"];
    return filename;
}

@end


@implementation ObjectSprite

@end
