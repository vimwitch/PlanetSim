//
//  MFPlanetView.m
//  PlanetSim
//
//  Created by Chance Hudson on 2/26/13.
//  Copyright (c) 2013 Chance Hudson. All rights reserved.
//

#import "MFPlanetView.h"
#import "Constant.h"
#import <math.h>
#import "MFGLShaderLoader.h"
#import <OpenGL/gl.h>
#import <QuartzCore/QuartzCore.h>
#import "MFGLConfig.h"

static BufferInfo *bufferInfoArray;
static int bufferInfoArrayCount = 0;

@implementation MFPlanetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBase];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if((self = [super initWithCoder:aDecoder])){
        [self setupBase];
    }
    return self;
}

-(void)setupGL{
    [self setOpenGLContext:self.openGLContext];
    
    planets = calloc(BASE_PLANET_ARRAY_SIZE, sizeof(Planet));
    planetArraySize = BASE_PLANET_ARRAY_SIZE;
    planetArrayCount = 0;
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"particle" ofType:@"png"]];
    planetImage = MFGLImageCreateWithImage(image);
    [image release];
    
    batchRenderer = [[MFGLBatchRenderer alloc] initWithViewSize:self.frame.size scale:1.0];
    
    MFGLShaderLoader *shaderLoader = [[MFGLShaderLoader alloc] initWithShaderPath:[[NSBundle mainBundle] resourcePath] name:@"Shader"];
    defaultProgram = [shaderLoader loadShadersWithBindingCode:^(GLuint prog) {
        glBindAttribLocation(prog, ATTRIB_VERTEX, "position");
        glBindAttribLocation(prog, ATTRIB_COLOR, "color");
        glBindAttribLocation(prog, ATTRIB_TEX, "texPosIn");
    }];
    
    [shaderLoader release];
    shaderLoader = [[MFGLShaderLoader alloc] initWithShaderPath:[[NSBundle mainBundle] resourcePath] name:@"PathShader"];
    pathShader = [shaderLoader loadShadersWithBindingCode:^(GLuint prog) {
        glBindAttribLocation(prog, ATTRIB_VERTEX, "position");
        glBindAttribLocation(prog, ATTRIB_TEX, "texPosIn");
    }];
    [shaderLoader release];
    shaderLoader = nil;
    
    glGenVertexArraysAPPLE(1, &vertexArrayObject);
    glBindVertexArrayAPPLE(vertexArrayObject);
    glVertexPointer(2, GL_FLOAT, sizeof(GLfloat)*8, 0);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, 0);
    glVertexAttribPointer(ATTRIB_TEX, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (void*)(sizeof(GLfloat)*2));
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (void*)(sizeof(GLfloat)*4));
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);
    glEnableVertexAttribArray(3);
    glBindVertexArrayAPPLE(0);
//    glEnable(GL_LINE_SMOOTH);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    [batchRenderer setVertexArray:vertexArrayObject];
    [batchRenderer setAttributeCount:8];
    [batchRenderer setRenderProgram:defaultProgram];
    
    //load the framebuffer
    GLint defaultFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
    glGenFramebuffers(1, &textureFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, textureFrameBuffer);
    bufferImage = MFGLImageCreateRenderable(self.frame.size, 1.0);
    glClearColor(0, 0.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO);
    glUseProgram(defaultProgram);
    bufferImageNeedsClearing = NO;
    
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
    
    [self startRendering];
}

-(void)setupBase{
    [self setupGL];
//    debugWindow = [[MFDebugWindowController alloc] initWithWindowNibName:@"MFDebugWindowController"];
//    [debugWindow loadWindow];
//    [debugWindow showWindow:nil];
    
    [self setupPlanetSunForm];
//    [self setupQuadForm];
}

-(BOOL)acceptsFirstResponder{
    return YES;
}

-(void)setupPlanetSunForm{
    float mass = 10000000000000;
    float sunRad = 30;
    Planet sun;
    sun.mass = mass;
    sun.radius = sunRad;
    sun.location = CGPointMake((self.frame.size.width/2.0), (self.frame.size.height/2.0));
    sun.velocity = MFGLVectorZero;
    sun.color = [NSColor redColor];
    sun.tag = 0;
    
    Planet earth;
    earth.mass = 100000000000000;
    earth.radius = 10;
    earth.location = CGPointMake((self.frame.size.width/2.0)+350, self.frame.size.height/2.0);
    earth.velocity = MFGLVectorMake(0, 1.59346772);
    earth.color = [NSColor blueColor];
    earth.tag = 2000;
    
    Planet moon;
    moon.mass = 1;
    moon.radius = 5;
    moon.location = mfvaddv(earth.location, MFGLVectorMake(100, 0));
    moon.velocity = MFGLVectorMake(0, 7.615773106+.389346772);
    moon.tag = 3000;
    moon.color = [NSColor greenColor];
    
    planets[planetArrayCount++] = sun;
    planets[planetArrayCount++] = earth;
//    planets[planetArrayCount++] = moon;
}

-(void)setupQuadForm{
    float mass = 100000000000000;
    float radius = 10;
    float offset = 240;
    float baseVel = 3;
    Planet planet1;
    planet1.mass = mass;
    planet1.radius = radius;
    planet1.location = CGPointMake((self.frame.size.width/2.0f)+offset, (self.frame.size.height/2.0f)+offset);
    planet1.velocity = MFGLVectorMake(-1*baseVel, baseVel);
    planet1.color = [NSColor redColor];
    planet1.tag = 1000;
    
    Planet planet2;
    planet2.mass = mass;
    planet2.radius = radius;
    planet2.location = CGPointMake((self.frame.size.width/2.0f)-offset, (self.frame.size.height/2.0f)+offset);
    planet2.velocity = MFGLVectorMake(-1*baseVel, -1*baseVel);
    planet2.color = [NSColor blueColor];
    planet2.tag = 2000;
    
    Planet planet3;
    planet3.mass = mass;
    planet3.radius = radius;
    planet3.location = CGPointMake((self.frame.size.width/2.0f)-offset, (self.frame.size.height/2.0f)-offset);
    planet3.velocity = MFGLVectorMake(baseVel, -1*baseVel);
    planet3.color = [NSColor greenColor];
    planet3.tag = 3000;
    
    Planet planet4;
    planet4.mass = mass;
    planet4.radius = radius;
    planet4.location = CGPointMake((self.frame.size.width/2.0f)+offset, (self.frame.size.height/2.0f)-offset);
    planet4.velocity = MFGLVectorMake(baseVel, baseVel);
    planet4.color = [NSColor yellowColor];
    planet4.tag = 4000;
    
    planets[planetArrayCount] = planet1;
    planets[planetArrayCount+1] = planet2;
    planets[planetArrayCount+2] = planet3;
    planets[planetArrayCount+3] = planet4;
    planetArrayCount += 4;
}

static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [(MFPlanetView*)displayLinkContext display];
    [pool drain];
    return kCVReturnSuccess;
}

void getAttribArrayFromColor(NSColor *color, GLfloat *arr){
    CGFloat f[4];
    [color getRed:&f[0] green:&f[1] blue:&f[2] alpha:&f[3]];
    arr[0] = f[0];
    arr[1] = f[1];
    arr[2] = f[2];
    arr[3] = f[3];
}

-(void)drawRect:(NSRect)dirtyRect{
    int x = 0;
    int stepsPerFrame = 1000;
    while(x < stepsPerFrame){
        x++;
        [self step:1000];
    }
    //update the paths first
    GLint defaultFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, textureFrameBuffer);
    //draw here
    if(bufferImageNeedsClearing){
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT);
        bufferImageNeedsClearing = NO;
    }
    for(int o = 0; o < planetArrayCount; o++){
        Planet obj = planets[o];
        if(obj.tag == 0)
            continue;
        GLfloat color[4] = {1.0,1.0,1.0,1.0};
        [batchRenderer
         addLineFromPoint:MFGLVectorMake(obj.location.x+obj.radius-(obj.velocity.x/1.0), obj.location.y+obj.radius-(obj.velocity.y/1.0))
         toPoint:MFGLVectorMake(obj.location.x+obj.radius, obj.location.y+obj.radius)
         shouldRenderAlpha:NO
         attribs:color
         attribCount:4
         offset:MFGLVectorZero];
    }
    [batchRenderer finishAndDrawBatch];
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    //draw the paths
    [batchRenderer addFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) forImage:bufferImage renderAlpha:NO offset:MFGLVectorZero attribs:NULL attribCount:0];
    glUseProgram(pathShader);
    [batchRenderer drawBatch];
    [batchRenderer resetHolderArrays];
    glUseProgram(defaultProgram);
    for(int x = 0; x < planetArrayCount; x++){
        Planet obj = planets[x];
        GLfloat color[4];
        getAttribArrayFromColor(obj.color, color);
//        [batchRenderer addFrame:CGRectMake(obj.location.x, obj.location.y, obj.radius*2, obj.radius*2) forImage:planetImage renderAlpha:YES offset:MFGLVectorZero attribs:color attribCount:4];
        [batchRenderer addCircleAtPoint:MFGLVectorMake(obj.location.x+obj.radius, obj.location.y+obj.radius) radius:obj.radius vertexCount:30 shouldRenderAlpha:YES offset:mfvaddv(planets[1].location, MFGLVectorMake(self.frame.size.width/-2.0, self.frame.size.height/-2.0)) attribs:color attribCount:4];
//        [batchRenderer addFrame:CGRectMake(obj.location.x, obj.location.y, obj.radius*2, obj.radius*2) withAlpha:1.0 forImage:planetImage renderAlpha:YES offset:0 color:obj.color renderMode:GL_TRIANGLES];
//        [batchRenderer addLine:obj.path offset:0];
    }
    [batchRenderer finishAndDrawBatch];
    glFlush();
    
    CFAbsoluteTime current = CFAbsoluteTimeGetCurrent();
    float frameTime = 1.0f/(current-lastFrame);
    frameAverage += frameTime;
    lastFrame = current;
    [debugWindow.planetCountField setStringValue:[NSString stringWithFormat:@"%u", planetArrayCount]];
    frameCount++;
    if(frameCount == 50){
        [debugWindow.fpsField setStringValue:[NSString stringWithFormat:@"%f", frameAverage/50.0]];
        frameAverage = 0;
        frameCount = 0;
    }
}

static void subOrBufferData(GLenum buffer, GLuint bufferID, size_t size, const GLvoid *data, GLenum usage){
    for(int x = 0; x < bufferInfoArrayCount; x++){
        if(bufferInfoArray[x].bufferID == bufferID){
            if(bufferInfoArray[x].size == size){
                glBufferSubData(buffer, 0, size, data);
            }
            else{
                glBufferData(buffer, size, data, usage);
                bufferInfoArray[x].size = size;
            }
            return;
        }
    }
    bufferInfoArrayCount++;
    bufferInfoArray = realloc(bufferInfoArray, bufferInfoArrayCount);
    bufferInfoArray[bufferInfoArrayCount-1] = (BufferInfo){bufferID, size};
    glBufferData(buffer, size, data, usage);
}

-(void)startRendering{
    CVDisplayLinkStart(displayLink);
}

-(void)stopRendering{
    CVDisplayLinkStop(displayLink);
}

-(void)step:(float)time{
    unsigned long planetCount = planetArrayCount;
    //set tag to 0 to prevent acceleration
    for(int x = 0; x < planetCount; x++){
        Planet obj = planets[x];
        double xAccel = 0;
        double yAccel = 0;
        for(int y = 0; y < planetCount; y++){
            Planet obj2 = planets[y];
            if(obj2.tag != obj.tag) {
                double hypotenuse = sqrtf(powf((obj2.location.x+obj2.radius)-(obj.location.x+obj.radius), 2)+powf((obj2.location.y+obj2.radius)-(obj.location.y+obj.radius), 2));
                double x = abs((obj2.location.x+obj2.radius)-(obj.location.x+obj.radius));
                
                double gAccel = obj2.mass/(hypotenuse*hypotenuse);
                gAccel = gAccel*6.67398*powf(10,-11);
                double theta = acosf(x/hypotenuse);
                double xAccelTemp = gAccel*cos(theta);
                double yAccelTemp = gAccel*sin(theta);
                
                //determine direction of accel
                xAccelTemp = xAccelTemp*(((obj2.location.x+obj2.radius) < (obj.location.x+obj.radius))?-1:1);
                yAccelTemp = yAccelTemp*(((obj2.location.y+obj2.radius) < (obj.location.y+obj.radius))?-1:1);
                
                //draw acceleration lines
//                GLfloat color[4] = {1.0,1.0,1.0,1.0};
//                float lineRatio = 50;
//                [batchRenderer addLineFromPoint:MFGLVectorMake(obj.location.x+obj.radius, obj.location.y+obj.radius) toPoint:MFGLVectorMake(obj.location.x+obj.radius+(xAccelTemp*lineRatio), obj.location.y+obj.radius+(yAccelTemp*lineRatio)) shouldRenderAlpha:NO attribs:color attribCount:4 offset:MFGLVectorZero];
                
                xAccel += xAccelTemp;
                yAccel += yAccelTemp;
            }
        }
        xAccel /= time;
        yAccel /= time;
        if(obj.tag != 0){
            obj.velocity = MFGLVectorMake(obj.velocity.x+xAccel, obj.velocity.y+yAccel);
            obj.location = CGPointMake(obj.location.x+(obj.velocity.x/time), obj.location.y+(obj.velocity.y/time));
        }
        planets[x] = obj;
    }
    //simulate any planet collisions
    for(int x = 0; x < planetArrayCount; x++){
        for(int y = x+1; y < planetArrayCount; y++){
            if([self isPlanetColliding:planets[x] withPlanet:planets[y]])
                [self collide:planets[x] with:planets[y]];
        }
//        [self simulatePlanetCollisions:planets[x]];
    }
}

-(BOOL)isPlanetColliding:(Planet)planet1 withPlanet:(Planet)planet2
{
    double dist = powf((planet1.location.x+planet1.radius)-(planet2.location.x+planet2.radius), 2)+powf((planet1.location.y+planet1.radius)-(planet2.location.y+planet2.radius), 2);
    return sqrt(dist) < (planet1.radius+planet2.radius);
}

-(void)simulatePlanetCollisions:(Planet)planet
{
    for(int x = 0; x < planetArrayCount; x++){
        if(planets[x].tag == planet.tag)
            continue;
        if([self isPlanetColliding:planet withPlanet:planets[x]])
            [self collide:planet with:planets[x]];
    }
}

-(void)collide:(Planet)planet1 with:(Planet)planet2{
    if(![self isPlanetColliding:planet1 withPlanet:planet2])
        return; //planets aren't actuall colliding
    //simulate elastic collision
    Planet largerPlanet = (planet1.mass>planet2.mass)?planet1:planet2;
    Planet smallerPlanet = (planet1.mass<planet2.mass)?planet1:planet2;
    // (1/2)mv^2=Uk
    largerPlanet.radius = (largerPlanet.radius*(smallerPlanet.mass+largerPlanet.mass))/largerPlanet.mass;
    double xKineticEnergy = (0.5)*(largerPlanet.mass*powf(largerPlanet.velocity.x,2)+smallerPlanet.mass*powf(smallerPlanet.velocity.x,2));
    double yKineticEnergy = (0.5)*(largerPlanet.mass*powf(largerPlanet.velocity.y,2)+smallerPlanet.mass*powf(smallerPlanet.velocity.y,2));
    largerPlanet.mass += smallerPlanet.mass;
    largerPlanet.velocity.x = ((largerPlanet.velocity.x>0)?1:-1)*sqrt((2*xKineticEnergy)/largerPlanet.mass);
    largerPlanet.velocity.y = ((largerPlanet.velocity.y>0)?1:-1)*sqrt((2*yKineticEnergy)/largerPlanet.mass);
    [self removePlanetWithTag:smallerPlanet.tag];
    for(int x = 0; x < planetArrayCount; x++){
        if(planets[x].tag == largerPlanet.tag){
            planets[x] = largerPlanet;
            break;
        }
    }
}

#pragma mark Planet array handling

-(void)replacePlanetWithTag:(int)tag withPlanet:(Planet)planet{
    for(int x = 0; x < planetArrayCount; x++){
        if(planets[x].tag == tag){
            planet.tag = tag;
            planets[x] = planet;
            break;
        }
    }
}

-(void)removePlanetWithTag:(int)tag{
    for(int x = 0; x < planetArrayCount; x++){
        if(planets[x].tag == tag){
            for(int y = x; y < planetArrayCount-1; y++){
                planets[y] = planets[y+1];
            }
            planetArrayCount--;
            break;
        }
    }
}

#pragma mark click detection

-(void)keyUp:(NSEvent *)theEvent{
    if(theEvent.keyCode == 8 /*c key*/)
        //clear the
        bufferImageNeedsClearing = YES;
//    NSLog(@"%i", theEvent.keyCode);
}

-(void)mouseUp:(NSEvent *)theEvent{
//    float mass = 10000000000000000;
    float mass = (arc4random()%10000000)+1;
    float radius = 5;
    float baseVel = 0;
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    Planet planet;
    planet.mass = mass;
    planet.radius = radius;
    planet.location = CGPointMake(mouseLoc.x, self.frame.size.height-mouseLoc.y);
    planet.velocity = MFGLVectorMake(-1*baseVel, baseVel);
    planet.color = [NSColor redColor];
    planet.tag = planetArrayCount+1;
    
    planets[planetArrayCount] = planet;
    planetArrayCount++;
}

@end
