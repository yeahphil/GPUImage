#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface SimpleImageViewController : UIViewController
{
    GPUImagePicture *sourcePicture;
    GPUImageOutput<GPUImageInput> *sepiaFilter, *sepiaFilter2;
    
    UISlider *imageSlider;
}

- (void)setupImageResampling;


@end
