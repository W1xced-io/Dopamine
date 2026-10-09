//
//  SceneDelegate.m
//  Dopamine
//
//  Created by Lars Fröder on 23.09.23.
//

#import "DOSceneDelegate.h"
#import "DONavigationController.h"

NSString *const DOAutoJailbreakRequestedNotification = @"DOAutoJailbreakRequestedNotification";
NSString *const DOAutoJailbreakPendingKey = @"DOAutoJailbreakPending";

static BOOL DOURLRequestsJailbreak(NSURL *url)
{
    if (!url) return NO;
    NSString *scheme = url.scheme.lowercaseString;
    if (![scheme isEqualToString:@"dopamine"]) return NO;
    NSString *host = url.host.lowercaseString;
    NSString *path = url.path.lowercaseString;
    if ([host isEqualToString:@"jailbreak"]) return YES;
    if ([path containsString:@"jailbreak"]) return YES;
    // dopamine:// alone also means jailbreak for widget convenience
    if (host.length == 0 && path.length <= 1) return YES;
    return NO;
}

static void DOPostAutoJailbreakRequest(void)
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DOAutoJailbreakPendingKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:DOAutoJailbreakRequestedNotification object:nil];
}

@interface DOSceneDelegate ()

@end

@implementation DOSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    window.rootViewController = [[DONavigationController alloc] init];
    [window makeKeyAndVisible];
    self.window = window;

    for (UIOpenURLContext *urlContext in connectionOptions.URLContexts) {
        if (DOURLRequestsJailbreak(urlContext.URL)) {
            DOPostAutoJailbreakRequest();
            break;
        }
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    for (UIOpenURLContext *urlContext in URLContexts) {
        if (DOURLRequestsJailbreak(urlContext.URL)) {
            DOPostAutoJailbreakRequest();
            break;
        }
    }
}

+ (void)relaunch
{
    UIWindowScene *windowScene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
    DOSceneDelegate *instance = (DOSceneDelegate *)windowScene.delegate;

    [UIView animateWithDuration:0.3 animations:^{
        instance.window.alpha = 0;
    } completion:^(BOOL finished) {
        UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)instance.window.windowScene];
        window.rootViewController = [[DONavigationController alloc] init];
        [window makeKeyAndVisible];
        instance.window = window;
        instance.window.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            instance.window.alpha = 1;
        }];
    }];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
