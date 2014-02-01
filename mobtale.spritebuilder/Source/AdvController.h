//
//  AdvController.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 07/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Adventure.h"
#import "AdvLocation.h"
#import "IngameLayer.h"
#import "AdvNode.h"

@interface AdvController : NSObject

@property (readonly) AdvLocation* currentLocation;
@property (readonly) IngameLayer* ingameLayer;

+(AdvController*) sharedController;

-(void) loadXML;
-(void) goToMenu;
-(void) startNewGame;
-(void) continueGame;
-(void) setLocation:(NSString*)locationId;
-(BOOL) execute:(NSMutableArray*)commands;
-(BOOL) isExpressionTrue:(NSString*)expression;

-(void) useItem:(NSString*)objectId;
-(void) takeObject:(NSString*)objectId;
-(BOOL) lookAtItem:(NSString*)objectId;
-(BOOL) useObject:(NSString*)objectId;
-(void) useObject:(NSString*)object1Id with:(NSString*)object2Id;
-(void) lookAtObject:(NSString*)objectId;
-(void) giveObject:(NSString*)objectId;

- (BOOL) isNodeAvailable:(AdvNode*)advNode;

@end
