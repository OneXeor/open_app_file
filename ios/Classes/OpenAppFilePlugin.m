#import "OpenAppFilePlugin.h"

@interface OpenAppFilePlugin ()<UIDocumentInteractionControllerDelegate>
@end

static NSString *const CHANNEL_NAME = @"open_app_file";

@implementation OpenAppFilePlugin{
    FlutterResult _result;
    UIDocumentInteractionController *_documentController;
    UIDocumentInteractionController *_interactionController;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL_NAME
                                     binaryMessenger:[registrar messenger]];
    OpenAppFilePlugin* instance = [[OpenAppFilePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"open_app_file" isEqualToString:call.method]) {
        _result = result;
        NSString *msg = call.arguments[@"file_path"];

        _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:msg]];
        _documentController.delegate = self;
        NSString *uti = call.arguments[@"uti"];
        BOOL isBlank = [self isBlankString:uti];
        if(!isBlank){
            _documentController.UTI = uti;
        }
        UIViewController *presenter = [self topViewController];
        if (presenter == nil) {
            [self finishWithMessage:@"No view controller to present the file from" type:@-4];
            return;
        }
        @try {
            BOOL previewSucceeded = [_documentController presentPreviewAnimated:YES];
            if(!previewSucceeded){
                BOOL menuShown = [_documentController presentOpenInMenuFromRect:CGRectMake(500,20,100,100) inView:presenter.view animated:YES];
                if (!menuShown) {
                    [self finishWithMessage:@"No app can open this file" type:@-1];
                }
            }
        }@catch (NSException *exception) {
            NSDictionary * dict = @{@"message":@"File opened incorrectly。", @"type":@-4};
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            result(json);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    NSDictionary * dict = @{@"message":@"done", @"type":@0};
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    _result(json);
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
      NSDictionary * dict = @{@"message":@"done", @"type":@0};
      NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
      NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

      _result(json);
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return [self topViewController];
}

// Resolved on every call: the host app may build or replace its window and root view controller
// after plugins are registered, so a controller captured at registration can be nil or detached.
- (UIViewController *)topViewController {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (window == nil) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
                    if (candidate.isKeyWindow) {
                        window = candidate;
                    }
                }
            }
        }
    }
    UIViewController *controller = window.rootViewController;
    while (controller.presentedViewController != nil && !controller.presentedViewController.isBeingDismissed) {
        controller = controller.presentedViewController;
    }
    return controller;
}

- (void)finishWithMessage:(NSString *)message type:(NSNumber *)type {
    if (_result == nil) {
        return;
    }
    NSDictionary * dict = @{@"message":message, @"type":type};
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    _result(json);
    _result = nil;
}

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0){
        return YES;
    }
    return NO;
}
@end
