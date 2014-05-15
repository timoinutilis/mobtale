//
//  LocationLayer.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 28/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "LocationLayer.h"
#import "CCBReader.h"
#import "AdvController.h"
#import "AdvNode.h"
#import "AdvObject.h"

@interface LocationLayer()
{
    IngameLayer* _ingameLayer;
    AdvNode* _selectedNode;
    AdvNode* _overNode;
}
@end

@implementation LocationLayer

- (id) initWithIngameLayer:(IngameLayer*)ingame
{
    if (self = [super init])
    {
        _ingameLayer = ingame;

        self.userInteractionEnabled = YES;
        self.claimsUserInteraction = YES;

        CGSize winSize = [[CCDirector sharedDirector] viewSize];
        self.contentSize = winSize;
    }
    return self;
}

- (void) showLocationImage:(NSString*)filename
{
    if (_currentLocationLayer)
    {
        CCNode* oldLayer = _currentLocationLayer;
        oldLayer.zOrder = 1;
        oldLayer.cascadeOpacityEnabled = YES;
        [oldLayer runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.5f] two:[CCActionCallBlock actionWithBlock:^{
            [oldLayer removeFromParent];
        }]]];
    }
    
    _currentLocationLayer = [CCBReader load:filename];
    
    CGSize winSize = [[CCDirector sharedDirector] viewSize];
    float scale = max(winSize.width / _currentLocationLayer.contentSize.width, winSize.height / _currentLocationLayer.contentSize.height);
    _currentLocationLayer.scale = scale;
    _currentLocationLayer.position = ccp((winSize.width - _currentLocationLayer.contentSize.width * scale) * 0.5f, (winSize.height - _currentLocationLayer.contentSize.height * scale) * 0.5f);
    
    [self refreshNodes];
    [self addChild:_currentLocationLayer];
}

- (void) refreshNodes
{
    AdvController* controller = [AdvController sharedController];
    for (int i = (int)_currentLocationLayer.children.count - 1; i >= 0; i--)
    {
        CCNode *node = [_currentLocationLayer.children objectAtIndex:i];
        if ([node isKindOfClass:[AdvNode class]])
        {
            AdvNode* advNode = (AdvNode*)node;
            if (![controller isNodeAvailable:advNode])
            {
                advNode.visible = NO;
            }
        }
    }
}

- (void) setNodeVisible:(NSString*)itemId visible:(BOOL)visible
{
    CCNode *node = [self getNodeById:itemId];
    if (visible)
    {
        node.opacity = 0.0f;
        node.visible = YES;
        [node runAction:[CCActionFadeIn actionWithDuration:0.25f]];
    }
    else
    {
        [node runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.25f] two:[CCActionHide action]]];
    }
}

- (void) setNodeAnim:(NSString*)itemId timeline:(NSString*)timeline
{
    CCNode *node = [self getNodeById:itemId];
    if (node.visible)
    {
        CCNode *child = node.children[0];
        CCBAnimationManager *animManager = child.userObject;
        [animManager runAnimationsForSequenceNamed:timeline];
    }
}

- (void) unselect
{
    _selectedNode = nil;
}

- (AdvNode*) getNodeById:(NSString*)itemId
{
    for (int i = (int)_currentLocationLayer.children.count - 1; i >= 0; i--)
    {
        CCNode *node = [_currentLocationLayer.children objectAtIndex:i];
        if ([node isKindOfClass:[AdvNode class]])
        {
            AdvNode* advNode = (AdvNode*)node;
            if ([advNode.itemId isEqualToString:itemId])
            {
                return advNode;
            }
        }
    }
    return nil;
}

- (AdvNode*) getNodeAtPosition:(CGPoint)location
{
    for (int i = (int)_currentLocationLayer.children.count - 1; i >= 0; i--)
    {
        CCNode *node = [_currentLocationLayer.children objectAtIndex:i];
        if ([node isKindOfClass:[AdvNode class]])
        {
            AdvNode* advNode = (AdvNode*)node;
            if (   [advNode hitTestWithWorldPos:location]
                && [[AdvController sharedController] isNodeAvailable:advNode] )
            {
                return advNode;
            }
        }
    }
    return nil;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInWorld];
    
    [_ingameLayer unselect];
    [_ingameLayer closeInventory];
    
    _overNode = [self getNodeAtPosition:location];
    if (_overNode)
    {
        [[AdvController sharedController] playSound:@"touch.wav"];
    }
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInWorld];

    AdvNode* advNode = [self getNodeAtPosition:location];
    if (advNode && advNode == _overNode)
    {
        if (advNode == _selectedNode)
        {
            // second tap
            if (advNode.isObject)
            {
                [[AdvController sharedController] takeObject:advNode.itemId fromPosition:location];
            }
            _selectedNode = nil;
        }
        else
        {
            // first tap
            _selectedNode = advNode;
            if (advNode.isObject)
            {
                AdvObject *advObject = [[AdvController sharedController] getAdvObject:advNode.itemId];
                [_ingameLayer showObjectInfoFor:advNode text:advObject.name];
            }
            else
            {
                [[AdvController sharedController] useItem:advNode.itemId];
                _selectedNode = nil;
            }
        }
    }
    else
    {
        _selectedNode = nil;
        [_ingameLayer hideObjectInfo];
    }
    _overNode = nil;
}

@end
