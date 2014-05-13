//
//  DialogLayer.m
//  mobtale
//
//  Created by Timo Kloss on 23/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DialogLayer.h"
#import "DialogItem.h"

@interface DialogLayer()
{
    CCNodeColor *_nodeBackground;
    CCLabelTTF *_labelTemplate;
    CCNode *_nodeItemsContainer;
    NSMutableArray *_items;
    CGPoint _currentPosition;
    CGFloat _bgOpacity;
    BOOL _enabled;
}
@end

@implementation DialogLayer

- (id) init
{
    if (self = [super init])
    {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) didLoadFromCCB
{
    _bgOpacity = _nodeBackground.opacity;
    _labelTemplate.visible = NO;
    _nodeItemsContainer = [CCNode node];
    _nodeItemsContainer.cascadeOpacityEnabled = YES;
    [[_labelTemplate parent] addChild:_nodeItemsContainer];
}

- (void) clearItems
{
    for (DialogItem *item in _items)
    {
        [item removeFromParent];
    }
    [_items removeAllObjects];
    _currentPosition = _labelTemplate.positionInPoints;
}

- (void) addItemWithText:(NSString*)text itemId:(NSString*)itemId
{
    DialogItem *item = [[DialogItem alloc] initWithText:text itemId:itemId labelTemplate:_labelTemplate];
    [_items addObject:item];
    
    item.position = _currentPosition;
    [_nodeItemsContainer addChild:item];
    
    _currentPosition.y -= item.contentSize.height;
}

- (void) show
{
    [self stopAllActions];
    _enabled = YES;
    self.opacity = 1;
    self.visible = YES;
}

- (void) hide
{
    [self stopAllActions];
    _enabled = NO;
    self.visible = NO;
}

- (void) fadeIn
{
    if (_enabled)
    {
        [self stopAllActions];
        self.visible = YES;
        [self runAction:[CCActionFadeIn actionWithDuration:0.3]];
    }
}

- (void) fadeOut
{
    if (_enabled)
    {
        [self stopAllActions];
        [self runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.3] two:[CCActionHide action]]];
    }
}

- (void) setOpacity:(CGFloat)opacity
{
    _nodeBackground.opacity = opacity * _bgOpacity;
    _nodeItemsContainer.opacity = opacity;
}

@end
