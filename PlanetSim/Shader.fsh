//
//  Shader.fsh
//  Stacker
//
//  Created by Chance Hudson on 3/2/13.
//  Copyright (c) 2013 Chance Hudson. All rights reserved.
//

varying vec2 texPosOut;
uniform sampler2D Texture;

varying vec4 colorOut;

void main() {
    vec4 orig = texture2D(Texture, texPosOut);
    vec4 c = vec4(colorOut.x*orig.w,colorOut.y*orig.w,colorOut.z*orig.w,colorOut.w*orig.w);
    vec4 o = vec4(orig.x*orig.w,orig.y*orig.w,orig.z*orig.w,orig.w);
    vec4 n = vec4(1.0-colorOut.x, 1.0-colorOut.y, 1.0-colorOut.z, orig.w);
//    gl_FragColor = (c+o);
    gl_FragColor = colorOut;
}