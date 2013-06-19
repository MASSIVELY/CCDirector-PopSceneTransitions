/*
 *  CCDirector+PopSceneTransitions.m
 *  Created by Jan Willms on 10.06.13.
 *
 *  The MIT License (MIT)
 *
 *  Copyright (c) 2013 MASSIVELY Interactive UG (haftungsbeschränkt).
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 */

#import "CCDirector+PopSceneTransitions.h"
#import "CCTransition.h"

@implementation CCDirector (PopSceneTransitions)

- (NSUInteger) scenesStackCount
{
    return [_scenesStack count];
}

- (void) popSceneWithTransition:(Class)s duration:(ccTime)t;
{
    NSAssert( _runningScene != nil, @"A running Scene is needed" );
    
    [_scenesStack removeLastObject];
    NSUInteger c = [_scenesStack count];
    if ( c == 0 ) {
        [self end];
    } else {
        CCScene* scene = [s transitionWithDuration:t scene:[_scenesStack objectAtIndex:c-1]];
        [_scenesStack replaceObjectAtIndex:c-1 withObject:scene];
        _nextScene = scene;
    }
}

- (void) replaceSceneStackWithScene:(CCScene *)scene
{
	NSAssert( _runningScene, @"Use runWithScene: instead to start the director" );
	NSAssert( scene != nil, @"Argument must be non-nil" );
    
	_sendCleanupToScene = YES;
	[_scenesStack replaceObjectAtIndex:0 withObject:scene];

    [self popToRootScene];
}

@end
