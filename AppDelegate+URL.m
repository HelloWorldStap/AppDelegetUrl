//
//  AppDelegate+URL.m
//  appdelget
//
//  Created by mac on 2019/10/24.
//  Copyright © 2019 mac. All rights reserved.
//

#import "AppDelegate+URL.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import "AppDelegateProtocol.h"
//NSArray* ZGClassesConformToProtocol(Protocol* protocol) {
//    NSMutableArray* modules = [NSMutableArray new];
//    unsigned int outCount;
//
//    Class *classes = objc_copyClassList(&outCount);
//    for (int i = 0; i < outCount; i++) {
//        Class cla = classes[i];
//        if (cla && class_conformsToProtocol(cla, protocol)) {
//            [modules addObject:cla];
//        }
//    }
//    free(classes);
//    return modules;
//}

@interface AppDelegate ()

@property(nonatomic,strong)NSArray *objArray;

@end

NSArray* ZGClassesConformToProtocol(Protocol* protocol) {
    NSMutableArray* modules = [NSMutableArray new];
    
    unsigned int count;
    const char **classes;
    Dl_info info;

    //1.获取app的路径
    dladdr(&_mh_execute_header, &info);

    //2.返回当前运行的app的所有类的名字，并传出个数
    //classes：二维数组 存放所有类的列表名称
    //count：所有的类的个数
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);
    for (int i = 0; i < count; i++) {
        //3.遍历并打印，转换Objective-C的字符串
        NSString *className = [NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding];
        Class class = NSClassFromString(className);
        //根据类名调用
        if (class && class_conformsToProtocol(class, protocol)) {
            
            id obj = [[class alloc]init];

            
            [modules addObject:obj];
        }

    }
    free(classes);
    return modules;
}

//objc_lookUpClass
@implementation AppDelegate (URL)
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
  self.objArray =  ZGClassesConformToProtocol(@protocol(AppDelegateProtocol));
    
    [self performSel:@selector(application:didFinishLaunchingWithOptions:) WithParam:@[application,launchOptions]];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self performSel:@selector(applicationWillResignActive:) WithParam:@[application]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self performSel:@selector(applicationDidEnterBackground:) WithParam:@[application]];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self performSel:@selector(applicationWillEnterForeground:) WithParam:@[application]];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self performSel:@selector(applicationDidBecomeActive:) WithParam:@[application]];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self performSel:@selector(applicationWillTerminate:) WithParam:@[application]];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self performSel:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) WithParam:@[application,deviceToken]];

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self performSel:@selector(application:didFailToRegisterForRemoteNotificationsWithError:) WithParam:@[application,error]];
    
}

- (void)application:(UIApplication *)application
  didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [self performSel:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:) WithParam:@[application,userInfo,completionHandler]];
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    
    [self performSel:@selector(userNotificationCenter:willPresentNotification:withCompletionHandler:) WithParam:@[center,notification,completionHandler]];
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
{
    [self performSel:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:) WithParam:@[center,response,completionHandler]];
    
}


-(void)setObjArray:(NSArray *)objArray
{
    objc_setAssociatedObject(self, @"objArrayKey",objArray , OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}
-(NSArray *)objArray
{
    
    return objc_getAssociatedObject(self, @"objArrayKey");
}
-(void)performSel:(SEL)sel WithParam:(NSArray *)array
{
        
    for (NSInteger i=0; i<self.objArray.count; i++) {
           
        id<AppDelegateProtocol> obj  = self.objArray[i];
       
        [self invocation:sel WithParam:array Withobj:obj];
                   
       }
}
-(void)invocation:(SEL)sel WithParam:(NSArray *)array Withobj:(id)obj
{
    
    
    if ([obj respondsToSelector:sel]) {

        NSMethodSignature *signature = [[obj class] instanceMethodSignatureForSelector:sel];

        if (signature == nil) {
            
        }

        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = obj;
        invocation.selector = sel;

        NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
        paramsCount = MIN(paramsCount, array.count);
        for (NSInteger i = 0; i < paramsCount; i++) {
            id object = array[i];
            if ([object isKindOfClass:[NSNull class]]) continue;
            [invocation setArgument:&object atIndex:i + 2];
        }

        [invocation invoke];

//        id returnValue = nil;
//        if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
//            [invocation getReturnValue:&returnValue];
//        }
//
//        return returnValue;


    }
    

    
}

@end
