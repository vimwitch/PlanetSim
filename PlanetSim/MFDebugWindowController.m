//
//  MFDebugWindowController.m
//  PlanetSim
//
//  Created by Chance Hudson on 4/29/13.
//  Copyright (c) 2013 Chance Hudson. All rights reserved.
//

#import "MFDebugWindowController.h"

@interface MFDebugWindowController ()

@end

@implementation MFDebugWindowController

@synthesize fpsField, planetCountField;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
