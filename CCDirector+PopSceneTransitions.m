/*
 *  CCDirector+PopSceneTransitions.m
 *  Created by Jan Willms [ http://massively.eu ]
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

- (void) popSceneWithTransition:(Class)transitionClass duration:(ccTime)t
{
    NSAssert( _runningScene != nil, @"A running Scene is needed" );
    
    CCScene *current = [_scenesStack lastObject];
    if ( [current isRunning] ) {
        [current onExitTransitionDidStart];
        [current onExit];
    }
    [current cleanup];
    [_scenesStack removeLastObject];
    
    NSUInteger c = [_scenesStack count];
    if ( c == 0 ) {
        [self end];
        return;
    }
    
    CCScene* scene = [transitionClass transitionWithDuration:t scene:[_scenesStack objectAtIndex:c-1]];
    [_scenesStack replaceObjectAtIndex:c-1 withObject:scene];
    _nextScene = scene;

    _sendCleanupToScene = NO;
}

- (void) replaceSceneStackWithScene:(CCScene *)scene
{
	NSAssert( _runningScene, @"Use runWithScene: instead to start the director" );
	NSAssert( scene != nil, @"Argument must be non-nil" );
    
    CCScene *current = [_scenesStack firstObject];
    if ( [current isRunning] ) {
        [current onExitTransitionDidStart];
        [current onExit];
    }
    [current cleanup];

	[_scenesStack replaceObjectAtIndex:0 withObject:scene];

    [self popToRootScene];
    
    _sendCleanupToScene = NO;
}

- (void) popToSceneStackLevel:(NSUInteger)level withTransition:(Class)transitionClass duration:(ccTime)t
{
    NSAssert( _runningScene != nil, @"A running Scene is needed" );
    
    NSUInteger c = [_scenesStack count];
    
    if ( level == 0 ) {
        [self end];
		return;
    }
    
    if ( level >= c) {
		return;
    }

	while ( c > level ) {
		CCScene *current = [_scenesStack lastObject];
		if ( [current isRunning] ) {
			[current onExitTransitionDidStart];
			[current onExit];
		}
		[current cleanup];
        
		[_scenesStack removeLastObject];
		c--;
	}
    
    _sendCleanupToScene = NO;
    
    CCScene *scene = [transitionClass transitionWithDuration:t scene:[_scenesStack lastObject]];
    
	[_runningScene release];
	_runningScene = [scene retain];
	_nextScene = nil;
   
	[_runningScene onEnter];
	[_runningScene onEnterTransitionDidFinish];
}

- (void) popToSceneStackLevel:(NSUInteger)level replaceWithScene:(CCScene *)scene
{
    NSAssert( _runningScene != nil, @"A running Scene is needed" );
    
    NSUInteger c = [_scenesStack count];
    
    if ( level == 0 ) {
        [self end];
		return;
    }
    
    if ( level >= c) {
		return;
    }
    
	while ( c >= level ) {
		CCScene *current = [_scenesStack lastObject];
		if ( [current isRunning] ) {
			[current onExitTransitionDidStart];
			[current onExit];
		}
		[current cleanup];
        
		[_scenesStack removeLastObject];
		c--;
	}
    
    [_scenesStack addObject:scene];
    _nextScene = scene;
    
    _sendCleanupToScene = NO;
}

- (CCScene *) nextScene
{
    return [_scenesStack lastObject];
}

@end
