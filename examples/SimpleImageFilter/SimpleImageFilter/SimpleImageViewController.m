#import "SimpleImageViewController.h"

@implementation SimpleImageViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{    
    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];	

	self.view = [[UIImageView alloc] initWithFrame:mainScreenFrame];
    
    [self setupImageResampling];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Image filtering

- (void)setupImageResampling;
{
    UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];

    // Lanczos downsampling
    GPUImageLanczosResamplingFilter *lanczosResamplingFilter = [[GPUImageLanczosResamplingFilter alloc] init];
    [lanczosResamplingFilter forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
    
    UIImage *lanczosImage = [lanczosResamplingFilter imageByFilteringImage:inputImage];

    [(UIImageView *)self.view setImage:lanczosImage];
}

@end
