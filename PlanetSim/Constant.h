//
//  Constant.h
//  PlanetSim
//
//  Created by Chance Hudson on 2/26/13.
//  Copyright (c) 2013 Chance Hudson. All rights reserved.
//

#define TRACE_PATH YES

typedef struct {
    float x;
    float y;
} MFVector;

static MFVector MFCreateVector(float x, float y){
    MFVector returnVec;
    returnVec.x = x;
    returnVec.y = y;
    return returnVec;
}

CGFloat g_ScreenWidth;
CGFloat g_ScreenHeight;