//
//  MySampleProjectAppDelegate.h
//  MySampleProject
//
//  Created by Eric Wing on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MySampleProjectViewController;

@interface MySampleProjectAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MySampleProjectViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MySampleProjectViewController *viewController;

@end

