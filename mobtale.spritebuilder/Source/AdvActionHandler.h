//
//  AdvActionHandler.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 09/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdvActionHandler : NSObject

@property (retain) NSString* type;
@property (retain) NSString* objectId;
@property (readonly) NSMutableArray* commands;

- (id) initWithType:(NSString*)type;

@end
