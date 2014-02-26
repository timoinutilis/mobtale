//
//  DialogLayer.h
//  mobtale
//
//  Created by Timo Kloss on 23/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "cocos2d.h"

@interface DialogLayer : CCNodeColor

- (void) clearItems;
- (void) addItemWithText:(NSString*)text itemId:(NSString*)itemId;

@end
