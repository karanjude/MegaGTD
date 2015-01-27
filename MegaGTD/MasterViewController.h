//
//  MasterViewController.h
//  MegaGTD
//
//  Created by Karan Singh on 11/22/14.
//  Copyright (c) 2014 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "EAIntroView.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController<NSFetchedResultsControllerDelegate, EAIntroDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

