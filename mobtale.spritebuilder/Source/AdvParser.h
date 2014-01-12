//
//  AdvParser.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 08/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adventure.h"
#import "AdvLocation.h"
#import "AdvItem.h"
#import "AdvObject.h"
#import "AdvActionHandler.h"
#import "AdvCommand.h"

@interface AdvParser : NSObject <NSXMLParserDelegate>
{
    Adventure* _adventure;
    AdvLocation* _currentLocation;
    AdvItem* _currentItem;
    AdvObject* _currentObject;
    AdvActionHandler* _currentActionHandler;
    AdvCommand* _currentCommand;

    NSMutableArray* _commandsTarget;
    NSMutableArray* _commandsTargetStack;
}

- (Adventure*)createAdventureFromXMLFile:(NSString *)pathToFile;

@end
