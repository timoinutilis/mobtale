//
//  IngameLayer.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 17/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "cocos2d.h"
#import "LocationLayer.h"

@interface AdvObjectSprite : CCSprite

@property (retain) NSString* objectId;

@end

// Main Class

@interface IngameLayer : CCScene

@property (readonly) LocationLayer* locationLayer;
@property (readonly) BOOL isInventoryOpen;

- (void) showText:(NSString*)text;
- (void) hideText;
- (BOOL) isTextVisible;
- (void) showTakeForObjectId:(NSString*)objectId;
- (void) showUseForObjectId:(NSString*)objectId isItem:(BOOL)isItem;
- (void) openInventory;
- (void) closeInventory;
- (void) addInventoryObject:(NSString*)objectId;
- (void) removeInventoryObject:(NSString*)objectId;
- (void) updateInventoryPositionsAnimated:(BOOL)animated;

@end
