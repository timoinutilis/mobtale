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

@interface MenuLayer()
{
    CCButton* _buttonContinue;
    CCNode* _image;
}
@end

@implementation MenuLayer

-(void)dealloc
{
    if (_image)
    {
        [self removeChild:_image];
    }
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
    CCLOG(@"Click Continue");
}

-(void) onStart
{
    CCLOG(@"Click Start");
    [[AdvController sharedController] startNewGame];
}

-(void) onAbout
{
    CCLOG(@"Click About");
}

@end
