//
//  MFDebugWindowController.h
//  PlanetSim
//
//  Created by Chance Hudson on 4/29/13.
//  Copyright (c) 2013 Chance Hudson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MFDebugWindowController : NSWindowController

@property (nonatomic, retain) IBOutlet NSTextField *fpsField;
@property (nonatomic, retain) IBOutlet NSTextField *planetCountField;

@end
