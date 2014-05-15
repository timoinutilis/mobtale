//
//  AdvParser.m
//  WebTale for iOS
//
//  Created by Timo Kloss on 08/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "AdvParser.h"
#import "AdvLocation.h"
#import "AdvItem.h"
#import "AdvObject.h"
#import "AdvActionHandler.h"
#import "AdvCommand.h"

@interface AdvParser()
{
    Adventure* _adventure;
    AdvLocation* _currentLocation;
    AdvItem* _currentItem;
    AdvObject* _currentObject;
    AdvActionHandler* _currentActionHandler;
    AdvCommand* _currentCommand;
    NSString* _currentElement;
    
    NSMutableArray* _commandsTarget;
    NSMutableArray* _commandsTargetStack;
}
@end

@implementation AdvParser

- (Adventure*) createAdventureFromXMLFile:(NSString *)pathToFile
{
    _commandsTargetStack = [[NSMutableArray alloc] init];
    
    NSURL *xmlURL = [NSURL fileURLWithPath:pathToFile];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
    
    return _adventure;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSString *attrId;
    NSString *attrName;
    NSString *attrImage;
    NSString *attrType;
    NSString *attrStatus;
    
    if ([elementName isEqualToString:@"adventure"])
    {
        attrName = [attributeDict objectForKey:@"name"];
        _adventure = [[Adventure alloc] initWithName:attrName];
        return;
    }
    
    if ([elementName isEqualToString:@"info"])
    {
        _currentElement = elementName;
    }
    
    if ([elementName isEqualToString:@"location"])
    {
        attrId = [attributeDict objectForKey:@"id"];
        attrName = [attributeDict objectForKey:@"name"];
        attrImage = [attributeDict objectForKey:@"image"];
        attrType = [attributeDict objectForKey:@"type"];
        AdvLocationType type = AdvLocationTypeNormal;
        if ([attrType isEqualToString:@"person"])
        {
            type = AdvLocationTypePerson;
        }
        _currentLocation = [[AdvLocation alloc] initWithId:attrId name:attrName image:attrImage type:type];
        return;
    }

    if ([elementName isEqualToString:@"init"])
    {
        _commandsTarget = _currentLocation.locationInitCommands;
        return;
    }

    if ([elementName isEqualToString:@"objects"])
    {
        return;
    }
    
    if ([elementName isEqualToString:@"item"])
    {
        attrId = [attributeDict objectForKey:@"id"];
        attrName = [attributeDict objectForKey:@"name"];
        attrStatus = [attributeDict objectForKey:@"status"];
        AdvItemStatus status = AdvItemStatusVisible;
        if ([attrStatus isEqualToString:@"hidden"])
        {
            status = AdvItemStatusHidden;
        }
        _currentItem = [[AdvItem alloc] initWithId:attrId name:attrName defaultStatus:status];
        
        // default action handler "onuse"
        _currentActionHandler = [[AdvActionHandler alloc] initWithType:@"onuse"];
        _commandsTarget = _currentActionHandler.commands;
        return;
    }
    
    if ([elementName isEqualToString:@"object"])
    {
        attrId = [attributeDict objectForKey:@"id"];
        attrName = [attributeDict objectForKey:@"name"];
        _currentObject = [[AdvObject alloc] initWithId:attrId name:attrName];
        return;
    }

    if ([elementName isEqualToString:@"objectdef"])
    {
        attrId = [attributeDict objectForKey:@"id"];
        _currentObject = [_adventure getObjectById:attrId];
        if (!_currentObject)
        {
            attrName = [attributeDict objectForKey:@"name"];
            _currentObject = [[AdvObject alloc] initWithId:attrId name:attrName];
        }

        // default action handler "onuse"
        _currentActionHandler = [[AdvActionHandler alloc] initWithType:@"onuse"];
        _commandsTarget = _currentActionHandler.commands;
        return;
    }
    
    if ([elementName hasPrefix:@"on"])
    {
        // delete default action handler
        _currentActionHandler = nil;
        
        attrId = [attributeDict objectForKey:@"id"];
        _currentActionHandler = [[AdvActionHandler alloc] initWithType:elementName];
        if (attrId)
        {
            _currentActionHandler.objectId = attrId;
        }
        _commandsTarget = _currentActionHandler.commands;
        return;
    }
    
    if (_commandsTarget)
    {
        _currentCommand = [[AdvCommand alloc] initWithType:elementName attributes:[NSMutableDictionary dictionaryWithDictionary:attributeDict]];
        [_commandsTarget addObject:_currentCommand];

        if ([elementName isEqualToString:@"do"])
        {
            [_commandsTargetStack addObject:_commandsTarget];
            _commandsTarget = [_currentCommand createCommandsArray];
        }
        return;
    }

}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_commandsTarget)
    {
        NSString* text = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if ([text length] > 0)
        {
            text = [self cleanString:text];
            if (_currentCommand != nil && [_currentCommand.type isEqualToString:@"say"])
            {
                [_currentCommand.attributeDict setValue:text forKey:@"text"];
            }
            else
            {
                NSMutableDictionary* attributeDict = [[NSMutableDictionary alloc] init];
                [attributeDict setValue:text forKey:@"text"];
                AdvCommand* textCommand = [[AdvCommand alloc] initWithType:@"say" attributes:attributeDict];
                [_commandsTarget addObject:textCommand];
            }
        }
    }
    else if ([_currentElement isEqualToString:@"info"])
    {
        NSString* text = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([text length] > 0)
        {
            text = [self cleanString:text];
            _adventure.info = text;
        }
    }
}

- (NSString*) cleanString:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@"\\s+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, string.length)];
    string = [string stringByReplacingOccurrencesOfString:@" ?\\\\n ?" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, string.length)];
    return string;
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (_currentElement && [elementName isEqualToString:_currentElement])
    {
        _currentElement = nil;
    }
    
    if ([elementName isEqualToString:@"location"])
    {
        [_adventure.locations addObject:_currentLocation];
        _currentLocation = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"init"])
    {
        _commandsTarget = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"objects"])
    {
        return;
    }
    
    if ([elementName isEqualToString:@"item"])
    {
        if (_currentActionHandler)
        {
            [_currentItem.actionHandlers addObject:_currentActionHandler];
            _currentActionHandler = nil;
            _commandsTarget = nil;
        }
        [_currentLocation.items addObject:_currentItem];
        _currentItem = nil;
        _commandsTarget = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"object"])
    {
        [_adventure.objects addObject:_currentObject];
        [_currentLocation.objects addObject:_currentObject];
        _currentObject = nil;
        return;
    }
    
    if ([elementName isEqualToString:@"objectdef"])
    {
        if (_currentActionHandler)
        {
            if (_currentActionHandler.commands.count > 0)
            {
                [_currentObject.actionHandlers addObject:_currentActionHandler];
            }
            _currentActionHandler = nil;
            _commandsTarget = nil;
        }
        if ([_adventure getObjectById:_currentObject.objectId] == nil)
        {
            [_adventure.objects addObject:_currentObject];
        }
        _currentObject = nil;
        _commandsTarget = nil;
        return;
    }
    
    if ([elementName hasPrefix:@"on"])
    {
        if (_currentLocation)
        {
            if (_currentItem)
            {
                [_currentItem.actionHandlers addObject:_currentActionHandler];
            }
            else
            {
                [_currentLocation.objectActionHandlers addObject:_currentActionHandler];
            }
        }
        else
        {
            [_currentObject.actionHandlers addObject:_currentActionHandler];
        }
        _currentActionHandler = nil;
        _commandsTarget = nil;
        return;
    }
    
    if (_commandsTarget)
    {
        if ([elementName isEqualToString:@"do"])
        {
            _commandsTarget = [_commandsTargetStack lastObject];
            [_commandsTargetStack removeLastObject];
        }

        _currentCommand = nil;
        return;
    }

}

@end
