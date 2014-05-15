//
//  AboutLayer.m
//  mobtale
//
//  Created by Timo Kloss on 09/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "AboutLayer.h"
#import "MenuLayer.h"
#import "AdvController.h"

@interface AboutLayer()
{
    CCLabelTTF *_labelText;
    CCNodeColor *_nodeBackground;
    CGFloat _bgOpacity;
}
@end

@implementation AboutLayer

- (id) init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = YES;
        self.claimsUserInteraction = YES;
        self.cascadeOpacityEnabled = YES;
        
        CGSize winSize = [[CCDirector sharedDirector] viewSize];
        self.contentSize = winSize;
    }
    return self;
}

- (void) didLoadFromCCB
{
    _nodeBackground.cascadeOpacityEnabled = YES;
    _bgOpacity = _nodeBackground.opacity;
}

- (void) setMenu:(MenuLayer*)menuLayer
{
    _menuLayer = menuLayer;
}

- (void) onShow
{
    NSString* text = [[AdvController sharedController] getAdvInfo];
    [self setText:text];
}

- (void) setText:(NSString*)text
{
    _labelText.string = text;
}

- (void) setOpacity:(CGFloat)opacity
{
    super.opacity = opacity;
    _nodeBackground.opacity = opacity * _bgOpacity;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.opacity == 1)
    {
        [[AdvController sharedController] playSound:@"click.wav"];
    }
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.opacity == 1)
    {
        [_menuLayer hideAbout];
    }
}

@end
