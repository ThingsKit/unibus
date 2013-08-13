//
//  CHAppDelegate.h
//  Warwick Unibus
//
//  Created by Chris Howell on 24/07/2013.
//  Copyright (c) 2013 Chris Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

/*
 curl -X POST \
 -H "X-Parse-Application-Id: wBUuq6l2XgbYmlkP8lIv33vkcaRMShknhMxsf2Wz" \
 -H "X-Parse-REST-API-Key: uFmRsluHFpcZLBEnon7bhIbrb5mdQuUMjt2xkalN" \
 -H "Content-Type: image/jpeg" \
 --data-binary '@photo (1).jpg' \
 https://api.parse.com/1/files/pic.jpg 
 
 curl -X POST \
 -H "X-Parse-Application-Id: wBUuq6l2XgbYmlkP8lIv33vkcaRMShknhMxsf2Wz" \
 -H "X-Parse-REST-API-Key: uFmRsluHFpcZLBEnon7bhIbrb5mdQuUMjt2xkalN" \
 -H "Content-Type: application/json" \
 -d '{
 "name": "Andrew",
 "picture": {
 "name": "115765ff-c067-409a-a4c6-ca9238726e5c-pic.jpg",
 "__type": "File"
 }
 }' \
 https://api.parse.com/1/classes/Images
 */
