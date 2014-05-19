//
//  LocationLayer.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 28/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "cocos2d.h"

@class IngameLayer;
@class AdvNode;

@interface LocationLayer : CCNode

@property (readonly) CCNode *currentLocationLayer;

- (id) initWithIngameLayer:(IngameLayer *)ingame;
- (void) showLocationImage:(NSString *)filename;
- (void) setNodeVisible:(NSString *)itemId visible:(BOOL)visible;
- (void) setNodeAnim:(NSString *)itemId timeline:(NSString *)timeline;
- (void) unselect;
- (AdvNode *) getNodeAtPosition:(CGPoint)location;
- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

@end
