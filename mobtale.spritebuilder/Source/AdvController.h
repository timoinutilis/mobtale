//
//  AdvController.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 07/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "IngameLayer.h"

@class Adventure;
@class AdvLocation;
@class AdvNode;
@class AdvItem;

@interface AdvController : NSObject

@property (readonly) AdvLocation* currentLocation;
@property (readonly) IngameLayer* ingameLayer;

+(AdvController*) sharedController;

- (void) start;
- (void) goToMenu;
- (void) startNewGame;
- (void) continueGame;
- (BOOL) canContinueGame;
- (void) saveCurrentGame;

- (void) onViewEvent:(ViewEventType)event;
- (void) setLocation:(NSString*)locationId;
- (void) execute:(NSMutableArray*)commands enteringLocation:(BOOL)enteredLocation;
- (void) continueExecution;
- (BOOL) isExecuting;
- (BOOL) isExpressionTrue:(NSString*)expression;

- (void) useItem:(NSString*)itemId;
- (void) takeObject:(NSString*)itemId fromPosition:(CGPoint)point;
- (BOOL) lookAtItem:(NSString*)itemId;
- (BOOL) useObject:(NSString*)itemId;
- (void) useObject:(NSString*)item1Id with:(NSString*)item2Id;
- (void) lookAtObject:(NSString*)itemId;
- (void) giveObject:(NSString*)itemId;

- (BOOL) isNodeAvailable:(AdvNode*)advNode;
- (AdvItem*) getAdvObject:(NSString*)itemId;
- (NSString*) getAdvInfo;

- (void) playSound:(NSString*)sound;

@end
