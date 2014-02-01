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

@interface LocationLayer()
{
    AdvNode* _selectedNode;
    AdvNode* _overNode;
}
@end

@implementation LocationLayer

- (id) init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = YES;
        self.claimsUserInteraction = YES;

        CGSize winSize = [[CCDirector sharedDirector] viewSize];
        self.contentSize = winSize;
    }
    return self;
}

- (void) showLocationImage:(NSString*)filename
{
    [_currentLocationLayer removeFromParent];
    
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
    for (int i = _currentLocationLayer.children.count - 1; i >= 0; i--)
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
    node.visible = visible;
}

- (void) unselect
{
    _selectedNode = nil;
}

- (AdvNode*) getNodeById:(NSString*)itemId
{
    for (int i = _currentLocationLayer.children.count - 1; i >= 0; i--)
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
    for (int i = _currentLocationLayer.children.count - 1; i >= 0; i--)
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
    
    [[[AdvController sharedController] ingameLayer] unselect];
    [[[AdvController sharedController] ingameLayer] closeInventory];
    
    _overNode =  [self getNodeAtPosition:location];
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
                [[AdvController sharedController] takeObject:advNode.itemId];
            }
            else
            {
                [[AdvController sharedController] useItem:advNode.itemId];
            }
            _selectedNode = nil;
        }
        else
        {
            // first tap
            _selectedNode = advNode;
            if (advNode.isObject)
            {
                [[AdvController sharedController] lookAtObject:advNode.itemId];
            }
            else
            {
                BOOL handled = [[AdvController sharedController] lookAtItem:advNode.itemId];
                if (!handled)
                {
                    [[AdvController sharedController] useItem:advNode.itemId];
                }
            }
        }
    }
    else
    {
        _selectedNode = nil;
        [[[AdvController sharedController] ingameLayer] hideText];
    }
    _overNode = nil;
}

@end
