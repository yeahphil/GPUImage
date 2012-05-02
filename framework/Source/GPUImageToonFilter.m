#import "GPUImageToonFilter.h"
#import "GPUImageSobelEdgeDetectionFilter.h"
#import "GPUImage3x3ConvolutionFilter.h"

// Code from "Graphics Shaders: Theory and Practice" by M. Bailey and S. Cunningham 
NSString *const kGPUImageToonFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 varying vec2 leftTextureCoordinate;
 varying vec2 rightTextureCoordinate;
 
 varying vec2 topTextureCoordinate;
 varying vec2 topLeftTextureCoordinate;
 varying vec2 topRightTextureCoordinate;
 
 varying vec2 bottomTextureCoordinate;
 varying vec2 bottomLeftTextureCoordinate;
 varying vec2 bottomRightTextureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float intensity;
 uniform highp float threshold;
 uniform highp float quantizationLevels;
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     float bottomLeftIntensity = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
     float topRightIntensity = texture2D(inputImageTexture, topRightTextureCoordinate).r;
     float topLeftIntensity = texture2D(inputImageTexture, topLeftTextureCoordinate).r;
     float bottomRightIntensity = texture2D(inputImageTexture, bottomRightTextureCoordinate).r;
     float leftIntensity = texture2D(inputImageTexture, leftTextureCoordinate).r;
     float rightIntensity = texture2D(inputImageTexture, rightTextureCoordinate).r;
     float bottomIntensity = texture2D(inputImageTexture, bottomTextureCoordinate).r;
     float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;
     float h = -topLeftIntensity - 2.0 * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0 * bottomIntensity + bottomRightIntensity;
     float v = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
     
     float mag = length(vec2(h, v));

     vec3 posterizedImageColor = floor((textureColor.rgb * quantizationLevels) + 0.5) / quantizationLevels;
     
     float thresholdTest = 1.0 - step(threshold, mag);
     
     gl_FragColor = vec4(posterizedImageColor * thresholdTest, textureColor.a);

     /*
     if (mag > threshold)
     {
         gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
     }
     else
     {
         textureColor *= vec3(quantize);
         textureColor += vec3(0.5);
         textureColor = floor(textureColor) / quantize;
         gl_FragColor = vec4(textureColor, texture2D(inputImageTexture, topTextureCoordinate).w);
     }
      */
 }
);

@implementation GPUImageToonFilter

@synthesize imageWidthFactor = _imageWidthFactor; 
@synthesize imageHeightFactor = _imageHeightFactor; 
@synthesize threshold = _threshold; 
@synthesize quantizationLevels = _quantizationLevels; 

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithVertexShaderFromString:kGPUImageNearbyTexelSamplingVertexShaderString fragmentShaderFromString:kGPUImageToonFragmentShaderString]))
    {
		return nil;
    }
    
    hasOverriddenImageSizeFactor = NO;
    
    imageWidthFactorUniform = [filterProgram uniformIndex:@"imageWidthFactor"];
    imageHeightFactorUniform = [filterProgram uniformIndex:@"imageHeightFactor"];
    thresholdUniform = [filterProgram uniformIndex:@"threshold"];
    quantizationLevelsUniform = [filterProgram uniformIndex:@"quantizationLevels"];
    
    self.threshold = 0.2;
    self.quantizationLevels = 10.0;    

    return self;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    if (!hasOverriddenImageSizeFactor)
    {
        _imageWidthFactor = filterFrameSize.width;
        _imageHeightFactor = filterFrameSize.height;
        
        [GPUImageOpenGLESContext useImageProcessingContext];
        [filterProgram use];
        glUniform1f(imageWidthFactorUniform, 1.0 / _imageWidthFactor);
        glUniform1f(imageHeightFactorUniform, 1.0 / _imageHeightFactor);
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setImageWidthFactor:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _imageWidthFactor = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(imageWidthFactorUniform, 1.0 / _imageWidthFactor);
}

- (void)setImageHeightFactor:(CGFloat)newValue;
{
    hasOverriddenImageSizeFactor = YES;
    _imageHeightFactor = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(imageHeightFactorUniform, 1.0 / _imageHeightFactor);
}

- (void)setThreshold:(CGFloat)newValue;
{
    _threshold = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(thresholdUniform, _threshold);
}

- (void)setQuantizationLevels:(CGFloat)newValue;
{
    _quantizationLevels = newValue;
    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(quantizationLevelsUniform, _quantizationLevels);
}


@end

