//
//  STAMAppDelegate.m
//  ActionsManager
//
//  Created by Maxim Grigoriev on 04/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STAMAppDelegate.h"

@interface STAMAppDelegate()

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation STAMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	application.applicationIconBadgeNumber = 0;
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if(launchOptions!=nil){
        
        NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSString *msg = [NSString stringWithFormat:@"didFinishLaunchingWithOptions: %@", [[remoteNotification objectForKey:@"aps"] objectForKey:@"alert"]];
        NSLog(@"didFinishLaunchingWithOptions %@",msg);
        [self createAlert:msg];
        
    }
    
    return YES;
    
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self sendRequest];
    completionHandler(UIBackgroundFetchResultNewData);
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
	NSLog(@"deviceToken: %@", deviceToken);
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    
	NSLog(@"Failed to register with error : %@", error);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    application.applicationIconBadgeNumber = 0;
    NSString *msg = [NSString stringWithFormat:@"%@", userInfo];
    NSLog(@"didReceiveRemoteNotification %@",msg);
    [self createAlert:msg];
    [self sendRequest];
    completionHandler(UIBackgroundFetchResultNewData);
    
}

- (void)createAlert:(NSString *)msg {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Received" message:[NSString stringWithFormat:@"%@", msg]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}

- (void)sendRequest {
    
    NSURL *url = [NSURL URLWithString:@"http://10.0.0.4/~grimax/srvcs/check_apns.php"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) {
        NSLog(@"connection error");
    }
    
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    NSLog(@"errorMessage %@", errorMessage);

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];

    self.responseData = [NSMutableData data];

    if (statusCode == 200) {
        
        NSString *lastModified = [headers objectForKey:@"Last-Modified"];
        if (lastModified) {
            NSLog(@"lastModified %@", lastModified);
        }
        NSLog(@"200");
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 10;
        
    } else if (statusCode == 304) {
        
        NSLog(@"304 Not Modified");
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    //    self.responseData = [NSData dataWithContentsOfFile:dataPath];
    
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSLog(@"connectionDidFinishLoading responseData %@", responseString);

}


@end
