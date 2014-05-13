//
//  MenuLayer.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 07/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "MenuLayer.h"
#import "AdvController.h"
#import "CCBReader.h"
#import "AboutLayer.h"

@interface MenuLayer()
{
    CCButton* _buttonContinue;
    CCNode* _image;
    AboutLayer* _aboutLayer;
    CCNode* _nodeMenu;
}
@end

@implementation MenuLayer

-(void)dealloc
{
    _aboutLayer.menuLayer = nil;
    if (_image)
    {
        [self removeChild:_image];
    }
}

- (void) didLoadFromCCB
{
    _aboutLayer.visible = NO;
    _aboutLayer.menuLayer = self;
    _nodeMenu.cascadeOpacityEnabled = YES;
    _buttonContinue.visible = [[AdvController sharedController] canContinueGame];
}

-(void) loadImage:(NSString*)name
{
    _image = (CCNode*) [CCBReader load:name owner:self];

    CGSize winSize = [[CCDirector sharedDirector] viewSize];
    float scale = max(winSize.width / _image.contentSize.width, winSize.height / _image.contentSize.height);
    _image.scale = scale;
    _image.position = ccp((winSize.width - _image.contentSize.width * scale) * 0.5f, (winSize.height - _image.contentSize.height * scale) * 0.5f);
    [self addChild:_image z:-1];
}

-(void) onContinue
{
    [[AdvController sharedController] continueGame];
}

-(void) onStart
{
    if ([[AdvController sharedController] canContinueGame])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The Current Game Will Be Lost"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Start New Game", @"Cancel", nil];
        [alert show];
    }
    else
    {
        [[AdvController sharedController] startNewGame];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex)
    {
        [[AdvController sharedController] startNewGame];
    }
}

-(void) onAbout
{
    [_aboutLayer onShow];
    _aboutLayer.visible = YES;
    [_aboutLayer runAction:[CCActionFadeIn actionWithDuration:0.5]];
    
    [_nodeMenu runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.5] two:[CCActionHide action]]];
}

- (void) hideAbout
{
    [_aboutLayer runAction:[CCActionSequence actionOne:[CCActionFadeOut actionWithDuration:0.5] two:[CCActionHide action]]];
    
    _nodeMenu.visible = YES;
    [_nodeMenu runAction:[CCActionFadeIn actionWithDuration:0.5]];
}

@end
