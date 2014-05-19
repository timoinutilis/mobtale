//
//  AdvParser.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 08/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adventure.h"

@interface AdvParser : NSObject <NSXMLParserDelegate>

- (Adventure *) createAdventureFromXMLFile:(NSString *)pathToFile;

@end
