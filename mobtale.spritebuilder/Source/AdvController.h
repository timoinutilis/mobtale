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
@class AdvObject;

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

- (void) useItem:(NSString*)objectId;
- (void) takeObject:(NSString*)objectId fromPosition:(CGPoint)point;
- (BOOL) lookAtItem:(NSString*)objectId;
- (BOOL) useObject:(NSString*)objectId;
- (void) useObject:(NSString*)object1Id with:(NSString*)object2Id;
- (void) lookAtObject:(NSString*)objectId;
- (void) giveObject:(NSString*)objectId;

- (BOOL) isNodeAvailable:(AdvNode*)advNode;
- (AdvObject*) getAdvObject:(NSString*)objectId;
- (NSString*) getAdvInfo;

- (void) playSound:(NSString*)sound;

@end
