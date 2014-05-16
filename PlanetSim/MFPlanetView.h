//
//  MFPlanetView.h
//  PlanetSim
//
//  Created by Chance Hudson on 2/26/13.
//  Copyright (c) 2013 Chance Hudson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFGLImage.h"
#import "MFGLBatchRenderer.h"
#import "MFDebugWindowController.h"

#define BASE_PLANET_ARRAY_SIZE (200)

enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEX,
    ATTRIB_COLOR,
}; // gl attribs used for shaders

typedef struct _vertex {
    GLfloat x;
    GLfloat y;
} vertex;

typedef struct _buffer {
    GLuint bufferID;
    size_t size;
} BufferInfo;

typedef struct _planet{
    long double mass;
    long double radius;
    MFGLVector velocity;
    CGPoint location;
    int tag;
//    MFGLLine path;
    NSColor *color;
    BOOL usesColorForPath;
} Planet;

@interface MFPlanetView : NSOpenGLView {
    CVDisplayLinkRef displayLink;
    Planet *planets;
    int planetArrayCount;
    int planetArraySize;
    MFGLImage planetImage;
    MFGLBatchRenderer *batchRenderer;
    GLuint defaultProgram;
    GLuint vertexArrayObject;
    GLuint pathVertexArrayObject;
    GLuint pathShader;
    
    GLuint textureFrameBuffer;
    MFGLImage bufferImage;
    
    MFDebugWindowController *debugWindow;
    CFAbsoluteTime lastFrame;
    int frameCount;
    float frameAverage;
}

@end
