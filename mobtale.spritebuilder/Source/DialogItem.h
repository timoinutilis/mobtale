//
//  DialogItem.h
//  mobtale
//
//  Created by Timo Kloss on 24/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "cocos2d.h"

@interface DialogItem : CCControl

@property NSString* itemId;

- (id) initWithText:(NSString*)text itemId:(NSString*)itemId labelTemplate:(CCLabelTTF*)labelTemplate;

@end
