//
//  AboutLayer.h
//  mobtale
//
//  Created by Timo Kloss on 09/05/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "cocos2d.h"

@class MenuLayer;

@interface AboutLayer : CCNode

@property MenuLayer* menuLayer;

- (void) onShow;

@end
