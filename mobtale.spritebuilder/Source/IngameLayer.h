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

@interface AdvObjectSprite : CCSprite

@property (retain) NSString* objectId;

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

@property (readonly) LocationLayer* locationLayer;
@property (readonly) DialogLayer* dialogLayer;

@property (readonly) BOOL isInventoryOpen;

- (void) setExecutionMode:(BOOL)active;
- (void) showObjectInfoFor:(CCNode*)node text:(NSString*)text;
- (void) hideObjectInfo;
- (void) showText:(NSString*)text;
- (void) hideText;
- (BOOL) isTextVisible;
- (void) openInventory;
- (void) closeInventory;
- (void) addInventoryObject:(NSString*)objectId;
- (void) removeInventoryObject:(NSString*)objectId;
- (void) updateInventoryPositionsAnimated:(BOOL)animated;
- (BOOL) areObjectsMoving;
- (BOOL) isDragging:(NSString*)objectId;
- (void) unselect;
- (void) moveObjectToInventory:(NSString*)objectId fromPosition:(CGPoint)point;

@end
