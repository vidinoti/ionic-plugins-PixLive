/********* PixLive.m Cordova Plugin Implementation *******/

#import "PixLive.h"
#import <Cordova/CDV.h>
#import <VDARSDK/VDARSDK.h>
#import "MyCameraImageSource.h"
#import "IonicARViewController.h"



@implementation PixLive {
    NSMutableDictionary *arViewControllers;
    NSMutableDictionary *arViewSizes;
}

#pragma mark - Cordova methods

- (void)onAppTerminate {
    //Save SDK
    [[VDARSDKController sharedInstance] save];
}

- (void)onMemoryWarning {
    for(IonicARViewController * ctrl in [arViewControllers allValues]) {
        [ctrl didReceiveMemoryWarning];
    }
}

- (void)onReset {
    //Destroy all views
    for(NSNumber *key in [arViewControllers allKeys]) {
        
        IonicARViewController * ctrl = [arViewControllers objectForKey:key];
        
        if(ctrl.view.superview) {
            [ctrl viewWillDisappear:NO];
            [ctrl.view removeFromSuperview];
            [ctrl viewDidDisappear:NO];
        }
    }
    
    [arViewControllers removeAllObjects];
    [arViewSizes removeAllObjects];
}

- (void)dispose {
    
}

#pragma mark - Plugin methods

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (PixLive*)[super initWithWebView:theWebView];
    
    arViewControllers = [NSMutableDictionary dictionary];
    arViewSizes = [NSMutableDictionary dictionary];
    
    return self;
}

-(void)beforeLeave:(CDVInvokedUrlCommand *)command {
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    if (argc < 1) {
        return;
    }
    
    NSUInteger ctrlID = [[arguments objectAtIndex:0] unsignedIntegerValue];
    IonicARViewController * ctrl = [arViewControllers objectForKey:[NSNumber numberWithUnsignedInteger:ctrlID]];
    
    [ctrl viewWillDisappear:NO];
}

-(void)afterLeave:(CDVInvokedUrlCommand *)command {
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    if (argc < 1) {
        return;
    }
    
    NSUInteger ctrlID = [[arguments objectAtIndex:0] unsignedIntegerValue];
    IonicARViewController * ctrl = [arViewControllers objectForKey:[NSNumber numberWithUnsignedInteger:ctrlID]];
    
    [ctrl.view removeFromSuperview];
    
    [ctrl viewDidDisappear:NO];
    
}

-(void)beforeEnter:(CDVInvokedUrlCommand *)command {
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    if (argc < 1) {
        return;
    }
    
    NSUInteger ctrlID = [[arguments objectAtIndex:0] unsignedIntegerValue];
    IonicARViewController * ctrl = [arViewControllers objectForKey:[NSNumber numberWithUnsignedInteger:ctrlID]];
    
    NSValue * val = arViewSizes[[NSNumber numberWithUnsignedInteger:ctrlID]];
    
    if(val) {
        CGRect r = [val CGRectValue];
        ctrl.view.frame = r;
    }
    
    [ [ [ self viewController ] view ] addSubview:ctrl.view];
    
    [ctrl viewWillAppear:NO];
    
    [ctrl.view setNeedsLayout];
}

-(void)afterEnter:(CDVInvokedUrlCommand *)command {
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    if (argc < 1) {
        return;
    }
    
    NSUInteger ctrlID = [[arguments objectAtIndex:0] unsignedIntegerValue];
    IonicARViewController * ctrl = [arViewControllers objectForKey:[NSNumber numberWithUnsignedInteger:ctrlID]];
    
    [ctrl viewDidAppear:NO];

}
-(void)init:(CDVInvokedUrlCommand *)command {
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    if (argc < 2) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:arguments[0]];
    
    [VDARSDKController startSDK:[url path] withLicenseKey:arguments[1]];
    
    [VDARSDKController sharedInstance].enableCodesRecognition=YES;
    [VDARSDKController sharedInstance].enableNotifications=YES;
    
    MyCameraImageSource *cameraSource=[[MyCameraImageSource alloc] init];
    
    [VDARSDKController sharedInstance].imageSender=cameraSource;
}

- (void) resize:(CDVInvokedUrlCommand *)command
{
    
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    if (argc < 5) { // at a minimum we need x origin, y origin and width...
        return;
    }
    
    CGFloat originx,originy,width, height;
    
    originx = [[arguments objectAtIndex:1] floatValue];
    originy = [[arguments objectAtIndex:2] floatValue];
    width = [[arguments objectAtIndex:3] floatValue];
    height = [[arguments objectAtIndex:4] floatValue];
    
    NSUInteger ctrlID = [[arguments objectAtIndex:0] unsignedIntegerValue];
    
    CGRect viewRect = CGRectMake(
                                 originx,
                                 originy,
                                 width,
                                 height
                                 );
    
    IonicARViewController * ctrl = [arViewControllers objectForKey:[NSNumber numberWithUnsignedInteger:ctrlID]];

    arViewSizes[[NSNumber numberWithUnsignedInteger:ctrlID]] = [NSValue valueWithCGRect:viewRect];
    
    if(ctrl.view.superview) {
        ctrl.view.frame = viewRect;
    
        
        UIInterfaceOrientation o = ctrl.interfaceOrientation;
        
        [ctrl willRotateToInterfaceOrientation:self.viewController.interfaceOrientation duration:0];
        [ctrl didRotateFromInterfaceOrientation:o];
    }
}


-(void)destroy:(CDVInvokedUrlCommand *)command {
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    if (argc < 1) {
        return;
    }
    
    NSUInteger ctrlID = [[arguments objectAtIndex:0] unsignedIntegerValue];
    IonicARViewController * ctrl = [arViewControllers objectForKey:[NSNumber numberWithUnsignedInteger:ctrlID]];
    
    [ctrl.view removeFromSuperview];
    
    [arViewControllers removeObjectForKey:[NSNumber numberWithUnsignedInteger:ctrlID]];
    [arViewSizes removeObjectForKey:[NSNumber numberWithUnsignedInteger:ctrlID]];
}

-(void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [self.viewController presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void) createARView:(CDVInvokedUrlCommand *)command
{
    
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    if (argc < 5) { // at a minimum we need x origin, y origin and width...
        return;
    }
    
    CGFloat originx,originy,width,height;
    
    originx = [[arguments objectAtIndex:0] floatValue];
    originy = [[arguments objectAtIndex:1] floatValue];
    width = [[arguments objectAtIndex:2] floatValue];
    height = [[arguments objectAtIndex:3] floatValue];
    
    NSUInteger ctrlID = [[arguments objectAtIndex:4] unsignedIntegerValue];
    
    CGRect viewRect = CGRectMake(
                                 originx,
                                 originy,
                                 width,
                                 height
                                 );
    
    IonicARViewController * ctrl = arViewControllers[[NSNumber numberWithUnsignedInteger:ctrlID]] = [[IonicARViewController alloc] initWithPlugin:self];
    
    [ctrl view]; //Load the view
    //Manually triggers the events
    [ctrl viewDidLoad];
    
    ctrl.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [ [ [ self viewController ] view ] addSubview:ctrl.view];
    
    ctrl.view.frame = viewRect;
    
    arViewSizes[[NSNumber numberWithUnsignedInteger:ctrlID]] = [NSValue valueWithCGRect:viewRect];
    
    [ctrl.view setNeedsLayout];
    
    [ctrl viewWillAppear:NO];
    
    [ctrl viewDidAppear:NO];
    
    
}

#pragma mark - Remote controller

- (void) synchronize:(CDVInvokedUrlCommand *)command
{
    
    NSArray* arguments = [command arguments];
    
    NSUInteger argc = [arguments count];
    
    NSArray *arrTags = argc > 0 ? arguments[0] : @[];

    [[VDARSDKController sharedInstance].afterLoadingQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[VDARRemoteController sharedInstance] syncRemoteModelsAsynchronouslyWithPriors:arrTags withCompletionBlock:^(id result, NSError *err) {
                
                CDVPluginResult* pluginResult = nil;
                
                if (err==nil && result) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[err localizedDescription]];
                }
                
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                
            }];
        });
    }];
    
}


@end