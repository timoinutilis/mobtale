//
//  IngameLayer.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 17/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "cocos2d.h"

@class LocationLayer;
@class DialogLayer;

@interface ObjectSprite : CCSprite

@property NSString *itemId;

@end

// Main Class

@interface IngameLayer : CCScene

typedef NS_ENUM(int, ViewEventType)
{
    ViewEventNone,
    ViewEventTextHidden,
    ViewEventInventoryOpened,
    ViewEventInventoryClosed,
    ViewEventObjectsMoved
};

@property (readonly) LocationLayer *locationLayer;
@property (readonly) DialogLayer *dialogLayer;
@property (readonly) BOOL isInventoryOpen;

- (void) setExecutionMode:(BOOL)active;
- (void) showObjectInfoFor:(CCNode *)node text:(NSString *)text;
- (void) hideObjectInfo;
- (void) showText:(NSString *)text;
- (void) hideText;
- (BOOL) isTextVisible;
- (void) openInventory;
- (void) closeInventory;
- (void) addInventoryObject:(NSString *)itemId;
- (void) removeInventoryObject:(NSString *)itemId;
- (void) updateInventoryPositionsAnimated:(BOOL)animated;
- (BOOL) areObjectsMoving;
- (BOOL) isDragging:(NSString *)itemId;
- (void) unselect;
- (void) moveObjectToInventory:(NSString *)itemId fromPosition:(CGPoint)point;

@end
