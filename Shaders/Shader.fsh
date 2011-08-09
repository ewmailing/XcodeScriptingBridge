//
//  Shader.fsh
//  MySampleProject
//
//  Created by Eric Wing on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
