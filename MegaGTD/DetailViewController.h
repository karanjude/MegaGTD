//
//  DetailViewController.h
//  MegaGTD
//
//  Created by Karan Singh on 11/22/14.
//  Copyright (c) 2014 Karan Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DetailViewController : UITableViewController <UIActionSheetDelegate, NSFetchedResultsControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) UIColor* foreColor;
@property (strong, nonatomic) UIColor* backColor;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString* category;

- (NSString*) titleForCategory: (NSString*) category;

@end

