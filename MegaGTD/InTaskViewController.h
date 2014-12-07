//
//  InTaskViewController.h
//  MegaGTD
//
//  Created by Karan Singh on 11/26/14.
//  Copyright (c) 2014 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InTaskViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
