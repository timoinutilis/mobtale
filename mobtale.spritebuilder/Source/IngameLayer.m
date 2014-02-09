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

@interface IngameLayer()
{
    CCButton* _buttonMenu;
    CCButton* _buttonInventory;
    CCButton* _buttonTake;
    CCButton* _buttonUse;
    CCNode* _nodeCenter;
    CCNode* _nodeTextWindow;
    CCNode* _nodeActionsContainer;
    CCLabelTTF* _labelText;
    CCNode* _nodeInventoryWindow;
    CCNode* _inventoryBox;
    
    BOOL _objectMoved;
    CGPoint _dragStartPoint;
    AdvObjectSprite* _draggingObject;
    AdvNode* _draggingOverNode;
    AdvObjectSprite* _draggingOverObject;
    BOOL _dragginOverLocation;
    AdvObjectSprite* _selectedObject;
    
    NSMutableArray* _inventorySprites;
}
@end

@implementation IngameLayer

- (id) init
{
	if ((self = [super init]))
    {
        _inventorySprites = [[NSMutableArray alloc] init];
        
        _locationLayer = [[LocationLayer alloc] init];
        [self addChild:_locationLayer z:-1];
        
        self.userInteractionEnabled = YES;
        self.claimsUserInteraction = YES;
    }
    return self;
}

- (void) didLoadFromCCB
{
}

- (void) onMenu
{
    if (![[AdvController sharedController] isExecuting])
    {
        [[AdvController sharedController] goToMenu];
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

- (void) showText:(NSString*)text
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
    [_nodeCenter runAction: [CCActionEaseInOut actionWithAction:[CCActionMoveTo actionWithDuration:0.3f position:ccp(_nodeCenter.position.x, 50.0f)] rate:3.0f]];
}

- (void) closeInventory
{
    _isInventoryOpen = NO;
    [_nodeCenter stopAllActions];
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
    
    if ([[AdvController sharedController] isExecuting])
    {
        return;
    }

    // inventory
    if ([_nodeInventoryWindow hitTestWithWorldPos:location])
    {
        [_locationLayer unselect];
        AdvObjectSprite *sprite = [self getAdvObjectAtPosition:location];
        if (sprite)
        {
            _dragStartPoint = location;
            _draggingObject = sprite;
            _objectMoved = NO;
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
                [self hideText];
                
                _objectMoved = YES;
                _selectedObject = nil;

                [_draggingObject removeFromParent];
                _draggingObject.position = [self convertToNodeSpace:location];
                [self addChild:_draggingObject];
                _draggingObject.scale *= 1.5f;
            }
        }
        else
        {
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
                _draggingOverNode = overNode;
            }
            
            if ([self isInventoryOpen])
            {
                [self closeInventory];
            }
        }
    }
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([[AdvController sharedController] isExecuting])
    {
        if ([self isTextVisible])
        {
            [self hideText];
        }
        [[AdvController sharedController] continueExecution];
        return;
    }
    else if (_draggingObject)
    {
        if (_objectMoved)
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
                [self updateInventoryPositionsAnimated:YES];
            }
        }
        else
        {
            // tapped
            if (_draggingObject == _selectedObject)
            {
                // second tap
                BOOL handled = [[AdvController sharedController] useObject:_draggingObject.objectId];
                if (handled)
                {
                    _selectedObject = nil;
                }
            }
            else
            {
                // first tap
                [[AdvController sharedController] lookAtObject:_draggingObject.objectId];
                _selectedObject = _draggingObject;
            }
        }
        
        _draggingObject = nil;
        _draggingOverNode = nil;
        _draggingOverObject = nil;
        _dragginOverLocation = NO;
    }
    else
    {
        if ([self isTextVisible])
        {
            [self hideText];
        }
        _selectedObject = nil;
    }
}

- (void) addInventoryObject:(NSString*)objectId
{
    NSString* filename = [self getFilenameForObject:objectId];
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
            CCActionCallBlock* actionCall = [CCActionCallBlock actionWithBlock:^{
                [sprite removeFromParent];
            }];
            [sprite runAction:[CCActionSequence actions:[CCActionSpawn actions:
                                                   [CCActionFadeOut actionWithDuration:0.25f],
                                                   [CCActionScaleTo actionWithDuration:0.25f scale:0.1f],
                                                   nil],
                                                   actionCall, nil]];
            
            [_inventorySprites removeObject:sprite];
            break;
        }
    }
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
}

- (void) unselect
{
    _selectedObject = nil;
}

- (void) moveObjectToInventory:(NSString*)objectId fromPosition:(CGPoint)point
{
    NSString* filename = [self getFilenameForObject:objectId];
    CCSprite* sprite = [AdvObjectSprite spriteWithImageNamed:filename];
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

- (NSString*) getFilenameForObject:(NSString*)objectId
{
    NSString* filename = @"objects/";
    filename = [filename stringByAppendingString:objectId];
    filename = [filename stringByAppendingString:@".png"];
    return filename;
}

@end


@implementation AdvObjectSprite

@end
