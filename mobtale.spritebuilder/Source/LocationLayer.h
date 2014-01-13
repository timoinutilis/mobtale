//
//  LocationLayer.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 28/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "cocos2d.h"
#import "AdvNode.h"

@interface LocationLayer : CCNode
{
}

@property (readonly) CCNode* currentLocationLayer;

- (void) showLocationImage:(NSString*)filename;
- (void) setNodeVisible:(NSString*)itemId visible:(BOOL)visible;
- (AdvNode*) getNodeAtPosition:(CGPoint)location;
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;

@end
