//
//  Shader.vsh
//  Stacker
//
//  Created by Chance Hudson on 3/2/13.
//  Copyright (c) 2013 Chance Hudson. All rights reserved.
//

attribute vec4 position;

attribute vec2 texPosIn;
varying vec2 texPosOut;

attribute vec4 color;
varying vec4 colorOut;

void main() {
    gl_Position = position;
    texPosOut = texPosIn;
    colorOut = color;
}