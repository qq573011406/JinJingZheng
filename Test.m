//
//  Test.m
//  JinJingZheng
//
//  Created by WDY on 2016/10/18.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "Test.h"
#import <QuartzCore/QuartzCore.h>
#import <PassKit/PassKit.h> 

@interface Test ()<UITableViewDataSource, PKAddPassesViewControllerDelegate>

@end

@implementation Test

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage * uiimage = [UIImage imageNamed:@"bg.jpg"];
    UIImage * blur = [self blur:uiimage];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:blur];
    
    //self.view.backgroundColor = [UIColor clearColor];
    //self.modalPresentationStyle = UIModalPresentationCurrentContext;
    //[self presentModalViewController:modalVC animated:YES];
    
    
    UIViewController * contributeViewController = [[UIViewController alloc] init];
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *beView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    beView.frame = self.view.bounds;
    
    contributeViewController.view.frame = self.view.bounds;
    contributeViewController.view.backgroundColor = [UIColor clearColor];
    [contributeViewController.view insertSubview:beView atIndex:0];
    contributeViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [self presentViewController:contributeViewController animated:YES completion:nil];
    
    
    NSString* resourcePath =
    [[NSBundle mainBundle] resourcePath];
    
    NSArray* passFiles = [[NSFileManager defaultManager]
                          contentsOfDirectoryAtPath:resourcePath
                          error:nil];
    
    NSString * passPath;
    //3 loop over the resource files
    for (NSString* passFile in passFiles) {
        if ( [passFile hasSuffix:@".pkpass"] ) {
            passPath = passFile;
        }  
    }
    
    if (![PKPassLibrary isPassLibraryAvailable]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"PassKit not available"
                                   delegate:nil
                          cancelButtonTitle:@"Pitty"
                          otherButtonTitles: nil] show];
        return;
    } else{
        [self openPassWithName:@"boardingPass.pkpass"];
    }
    
}

-(void)openPassWithName:(NSString*)name {
    //2
    NSString* passFile = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent: name];
    
    //3
    NSData *passData = [NSData dataWithContentsOfFile:passFile];
    
    //4
    NSError* error = nil;
    PKPass *newPass = [[PKPass alloc] initWithData:passData
                                             error:&error];
    //5
    if (error!=nil) {
        [[[UIAlertView alloc] initWithTitle:@"Passes error"
                                    message:[error
                                             localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"Ooops"
                          otherButtonTitles: nil] show];
        return;
    }
    
    //6
    PKAddPassesViewController *addController =
    [[PKAddPassesViewController alloc] initWithPass:newPass];
    
    addController.delegate = self;
    [self presentViewController:addController
                       animated:YES
                     completion:nil];
}


- (UIImage*) blur:(UIImage*)theImage {
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
