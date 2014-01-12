//
//  MenuLayer.h
//  WebTale for iOS
//
//  Created by Timo Kloss on 07/12/13.
//  Copyright (c) 2013 Timo Kloss. All rights reserved.
//

#import "cocos2d.h"

@interface MenuLayer : CCScene
{
    CCButton* _buttonContinue;
    
    CCNode* _image;
}

-(void) loadImage:(NSString*)name;

@end

