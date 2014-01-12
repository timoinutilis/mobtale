//
//  AdvCommand.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdvCommand : NSObject

@property (retain) NSString* type;
@property (retain) NSDictionary* attributeDict;
@property (readonly) NSMutableArray* commands;

- (id) initWithType:(NSString*)type attributes:(NSDictionary*)attributeDict;
- (NSMutableArray*) createCommandsArray;
- (NSString*) condition;

@end
