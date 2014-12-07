//
//  MasterViewController.m
//  MegaGTD
//
//  Created by Karan Singh on 11/22/14.
//  Copyright (c) 2014 Karan Singh. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "InTaskViewController.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface MasterViewController ()

@property NSMutableArray *objects;
@property NSArray *colors;
@property NSArray *backGroundColors;
@property NSArray *categories;
@property NSArray *categoryKeys;
@property NSMutableDictionary* categoryCount;
@property NSFetchRequest *fetchRequest;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    /*
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
     */
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.colors = @[
                    [UIColor colorWithRed:0.540631 green:0.788434 blue:1 alpha:.5],
                    [UIColor colorWithRed:0.787005 green:0.74631 blue:0.954487 alpha:.5],
                    [UIColor colorWithRed:0.954487 green:0.867666 blue:0.605737 alpha:.5],
                    [UIColor colorWithRed:0.625421 green:0.954487 blue:0.89896 alpha:.5],
                    UIColorFromRGB(0xa4e786,.5)
                    ];
    
    self.backGroundColors = @[
                    [UIColor colorWithRed:0.540631 green:0.788434 blue:1 alpha:.1],
                    [UIColor colorWithRed:0.787005 green:0.74631 blue:0.954487 alpha:.1],
                    [UIColor colorWithRed:0.954487 green:0.867666 blue:0.605737 alpha:.1],
                    [UIColor colorWithRed:0.625421 green:0.954487 blue:0.89896 alpha:.1],
                    UIColorFromRGB(0xa4e786,.1)
                    ];
    
    self.categories = @[
                        @"In",
                        @"Next Actions",
                        @"Project",
                        @"Waiting For",
                        @"Done"
                        ];
    
    self.categoryKeys = @[
                        @"in",
                        @"next",
                        @"project",
                        @"waiting",
                        @"done"
                        ];
    
    
    // Create and configure a fetch request with the Book entity.
    self.fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [self.fetchRequest setEntity:entity];
    
    NSAttributeDescription* statusDesc = [entity.attributesByName objectForKey:@"category"];
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"startDate"]; // Does not really matter
    NSExpression *countExpression = [NSExpression expressionForFunction: @"count:"
                                                              arguments: [NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName: @"count"];
    [expressionDescription setExpression: countExpression];
    [expressionDescription setExpressionResultType: NSInteger32AttributeType];
    
    [self.fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:statusDesc, expressionDescription, nil]];
    [self.fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:statusDesc]];
    [self.fetchRequest setResultType:NSDictionaryResultType];
    
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:self.fetchRequest
                                                             error:&error];
    
     self.categoryCount = [[NSMutableDictionary alloc]initWithCapacity:[self.categoryKeys count]];

    id object;
    for (object in results) {
        NSDictionary* resultDict = object;
        NSString* categoryValue = resultDict[@"category"];
        NSInteger countValue = [resultDict[@"count"] integerValue];
        
        NSNumber *tempNumber = [[NSNumber alloc] initWithInteger:countValue];
        self.categoryCount[categoryValue] = tempNumber;
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle_data) name:@"reload_data" object:nil];
    
    [[UINavigationBar appearance] setBarTintColor: UIColorFromRGB(0xf7f7f7,.1) ];
    
    [[UINavigationBar appearance] setTintColor:[UIColor grayColor]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor grayColor], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"Arial" size:21.0], NSFontAttributeName, nil]];

    
    
}

-(void)handle_data
{
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:self.fetchRequest
                                                                error:&error];
    
    id object;
    for (object in results) {
        NSDictionary* resultDict = object;
        NSString* categoryValue = resultDict[@"category"];
        NSInteger countValue = [resultDict[@"count"] integerValue];
        
        NSNumber *tempNumber = [[NSNumber alloc] initWithInteger:countValue];
        self.categoryCount[categoryValue] = tempNumber;
        
    }
    

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    /*
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UINavigationController * vc = [storyboard instantiateViewControllerWithIdentifier:@"InTaskViewController"];
    
    InTaskViewController* inTaskViewController = [vc.viewControllers objectAtIndex:0];
    inTaskViewController.managedObjectContext = self.managedObjectContext;
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSString* category = self.categoryKeys[indexPath.section];
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        [controller setBackColor:self.backGroundColors[indexPath.section]];
        controller.managedObjectContext = self.managedObjectContext;
        controller.category = category;
        
        //controller.navigationController.navigationBar.backgroundColor  = [UIColor greenColor];
        //controller.navigationController.navigationBar.barTintColor  = [UIColor greenColor];
        
        //controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        //controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellId = nil;
    NSString * cellText = nil;
    UIColor * color = nil;
    
    NSNumber* categoryCount = self.categoryCount[self.categoryKeys[indexPath.section]];
    
    if (categoryCount != nil) {
        cellText = [NSString stringWithFormat:@"%@ (%@)", self.categories[indexPath.section], categoryCount];
    }else{
        cellText = [NSString stringWithFormat:@"%@", self.categories[indexPath.section]];
    }
    
    
    
    switch (indexPath.section) {
        case 0:
            cellId = @"Cell1";
            break;

        case 1:
            cellId = @"Cell2";

            break;
        case 2:
            cellId = @"Cell3";

            break;
            
        case 3:
            cellId = @"Cell4";

            break;
        case 4:
            cellId = @"Cell5";
            color = UIColorFromRGB(0xa4e786,.5);
            
            break;
            
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];

    
    cell.textLabel.text = cellText;
    

    // create background color view, to set background for cell and accessory view
    //UIView* myView = [[UIView alloc] initWithFrame:CGRectZero];
    //myView.backgroundColor = color;
    
    // create the separator line for the cells
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width , 2)];
    separatorLineView.backgroundColor = [UIColor grayColor];
    
    if(!(color == nil)){
        cell.contentView.backgroundColor = color;
    }
    
    [cell.contentView addSubview:separatorLineView];
    
    //cell.backgroundView = myView;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]init];
    [view setAlpha:0.0F];
    return view;
}



@end
