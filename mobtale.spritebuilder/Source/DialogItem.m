//
//  DialogItem.m
//  mobtale
//
//  Created by Timo Kloss on 24/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DialogItem.h"
#import "CCControlSubclass.h"
#import "AdvController.h"

@interface DialogItem()

@property CCLabelTTF *label;
@property CCColor *colorNormal;
@property CCColor *colorHighlight;

@end

@implementation DialogItem

- (id) initWithText:(NSString*)text itemId:(NSString*)itemId labelTemplate:(CCLabelTTF*)labelTemplate
{
    if (self = [super init])
    {
        self.itemId = itemId;
        self.colorNormal = labelTemplate.fontColor;
        self.colorHighlight = [CCColor colorWithRed:1.0f green:0.0f blue:0.0f];
        
        self.label = [[CCLabelTTF alloc] initWithString:text fontName:labelTemplate.fontName fontSize:labelTemplate.fontSize dimensions:labelTemplate.dimensions];
        _label.anchorPoint = ccp(0, 0);
        _label.horizontalAlignment = labelTemplate.horizontalAlignment;
        _label.verticalAlignment = labelTemplate.verticalAlignment;
        _label.fontColor = labelTemplate.fontColor;
        _label.outlineColor = labelTemplate.outlineColor;
        _label.outlineWidth = labelTemplate.outlineWidth;
        _label.shadowColor = labelTemplate.shadowColor;
        _label.shadowBlurRadius = labelTemplate.shadowBlurRadius;
        _label.shadowOffset = labelTemplate.shadowOffset;
        _label.shadowOffsetType = labelTemplate.shadowOffsetType;
        
        [self addChild:_label];
        
        self.anchorPoint = labelTemplate.anchorPoint;
        self.contentSize = _label.contentSize;
    }
    return self;
}

- (void) touchEntered:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    self.highlighted = YES;
    [[AdvController sharedController] playSound:@"click.wav"];
}

- (void) touchExited:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void) touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.enabled)
    {
        [self triggerAction];
    }
    self.highlighted = NO;
}

- (void) touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void) triggerAction
{
    [super triggerAction];
    [[AdvController sharedController] useItem:_itemId];
}

- (void) stateChanged
{
    if (self.highlighted)
    {
        _label.fontColor = _colorHighlight;
    }
    else
    {
        _label.fontColor = _colorNormal;
    }
    [self needsLayout];
}

@end
