//
//  AdvObject.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdvObject : NSObject

@property (retain) NSString* objectId;
@property (retain) NSString* name;
@property (readonly) NSMutableArray* actionHandlers;

- (id) initWithId:(NSString*)objectId name:(NSString*)name;

@end
