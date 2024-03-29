//
//  CHAppDelegate.m
//  Warwick Unibus
//
//  Created by Chris Howell on 24/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <Parse/Parse.h>
#import "CHAppDelegate.h"
#import "CHNavigationViewController.h"
#import "CHMainViewViewController.h"
#import "CHDataLoader.h"
#import "CHLoadingViewController.h"
#import "CoreData+MagicalRecord.h"

@interface CHAppDelegate()
@property (nonatomic, strong) CHMainViewViewController *mainViewCon;
@property (nonatomic, strong) CHNavigationViewController *navController;
@property (nonatomic, strong) CHLoadingViewController *loadingViewController;
@property (nonatomic, strong) NSTimer *clockTimer;
@end

@implementation CHAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataSaved:) name:@"coreDataUpdated" object:nil];
    
    // Parse
    [Parse setApplicationId:@"wBUuq6l2XgbYmlkP8lIv33vkcaRMShknhMxsf2Wz"
                  clientKey:@"3ac40HQwfrSEmyMei2mxWjCUZFmN2hXJuhFTITAD"];

    self.navController = [[CHNavigationViewController alloc] init];
    self.loadingViewController = [[CHLoadingViewController alloc] init];

    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor clearColor];
    self.window.opaque = NO;
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.loadingViewController.view];
    
    // Magical record
    
    //Setup store coordinator and default context
    [MagicalRecord setupCoreDataStack];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    // Decide if it is the first run. If it is, prepopulate the selected bus stops with defaults
    BOOL hasRanBefore = [prefs boolForKey:@"hasRanBefore"];
    if (!hasRanBefore)
    {
        NSMutableArray *stops = [[NSMutableArray alloc] init];
        [stops addObject:[NSNumber numberWithInt:1]];
        [stops addObject:[NSNumber numberWithInt:34]];
        
        [prefs setObject:stops forKey:@"stops"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasRanBefore"];
        [prefs synchronize];
    }
    CHDataLoader *dataLoader = [[CHDataLoader alloc] init];
    [dataLoader loadData];
    
    
    
    return YES;
}

- (void)timerTick:(NSTimer *)timer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TimeChange" object:nil];
}

- (void) coreDataSaved: (NSNotification *) notification
{
    [self.loadingViewController fadeOutLoadingViewWithCompletion:^(void){
    
    }];
    
    self.mainViewCon = [[CHMainViewViewController alloc] init];
    [self.navController pushViewController:self.mainViewCon];
    self.navController.rootViewController = self.mainViewCon;
    self.mainViewCon.navigationController = self.navController;
    
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.mainViewCon attemptImageDownload];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Warwick_Unibus" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Warwick_Unibus.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
