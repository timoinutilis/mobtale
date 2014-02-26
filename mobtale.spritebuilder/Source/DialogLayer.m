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
    CCLabelTTF *_labelTemplate;
    NSMutableArray *_items;
    CGPoint _currentPosition;
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
    _labelTemplate.visible = NO;
    _currentPosition = _labelTemplate.position;
}

- (void) clearItems
{
    for (DialogItem *item in _items)
    {
        [item removeFromParent];
    }
    [_items removeAllObjects];
    _currentPosition = _labelTemplate.position;
}

- (void) addItemWithText:(NSString*)text itemId:(NSString*)itemId
{
    DialogItem *item = [[DialogItem alloc] initWithText:text itemId:itemId labelTemplate:_labelTemplate];
    [_items addObject:item];
    
    item.position = _currentPosition;
    [[_labelTemplate parent] addChild:item];
    
    _currentPosition.y -= item.contentSize.height;
}

@end
