//
//  AdvItem.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 06/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>

enum AdvItemStatus : int {
    AdvItemStatusUndefined,
    AdvItemStatusVisible,
    AdvItemStatusHidden
};
typedef enum AdvItemStatus : int AdvItemStatus;


@interface AdvItem : NSObject

@property (retain) NSString *itemId;
@property BOOL isObject;
@property (retain) NSString *name;
@property (readonly) NSMutableArray *actionHandlers;
@property (readonly) AdvItemStatus defaultStatus;

- (id) initWithId:(NSString*)itemId isObject:(BOOL)isObject name:(NSString*)name defaultStatus:(AdvItemStatus)status;

@end
