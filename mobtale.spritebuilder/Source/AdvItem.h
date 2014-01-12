//
//  AdvItem.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdvItem : NSObject

@property (retain) NSString *itemId;
@property (retain) NSString *name;
@property (readonly) NSMutableArray *actionHandlers;

- (id) initWithId:(NSString*)itemId name:(NSString*)name;

@end
