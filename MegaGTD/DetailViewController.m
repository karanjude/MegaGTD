//
//  DetailViewController.m
//  MegaGTD
//
//  Created by Karan Singh on 11/22/14.
//  Copyright (c) 2014 Karan Singh. All rights reserved.
//

#import "DetailViewController.h"
#import "Task.h"
#import "MasterViewController.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

@interface DetailViewController ()

@property NSArray *backGroundColors;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

static NSString* const NEXT_ACTIONS = @"Next Actions";
static NSString* const PROJECT = @"Project";
static NSString* const WAITING_FOR = @"Waiting For";
static NSString* const DONE = @"Done";
static NSDictionary* categoryTitles;


@implementation DetailViewController

#pragma mark - Managing the detail item


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        categoryTitles = @{
                         @"in": @"In",
                         @"done": @"Done",
                         @"project": @"Project",
                         @"waiting": @"Waiting For",
                         @"next": @"Next Actions",
                         };
    });
}


- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        //self.detailDescriptionLabel.text = [self.detailItem description];
    }
    
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    self.backGroundColors = @[
                              [UIColor colorWithRed:0.540631 green:0.788434 blue:1 alpha:.1],
                              [UIColor colorWithRed:0.787005 green:0.74631 blue:0.954487 alpha:.1],
                              [UIColor colorWithRed:0.954487 green:0.867666 blue:0.605737 alpha:.1],
                              [UIColor colorWithRed:0.625421 green:0.954487 blue:0.89896 alpha:.1],
                               UIColorFromRGB(0xa4e786,.1)
                              ];

    //self.tableView.backgroundColor = self.color;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self setTitle: [self titleForCategory:self.category]];

    [[UINavigationBar appearance] setBarTintColor:self.backColor];

    [[UINavigationBar appearance] setTintColor:[UIColor grayColor]];
    
    
 
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor grayColor], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"Arial" size:21.0], NSFontAttributeName, nil]];
    
    /*
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(home:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
*/
    
}


-(void)home:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reload_data" object:self];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*) titleForCategory: (NSString*) category {
    return categoryTitles[self.category];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [popup buttonTitleAtIndex:buttonIndex];
    UIColor* color = nil;
    NSString * storyboardName = @"Main";
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Task *selectedTask = (Task *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSError *error;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DetailViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"TaskDetails"];
    
    if  ([buttonTitle isEqualToString:NEXT_ACTIONS]) {
        selectedTask.category = @"next";
        [self.managedObjectContext save:&error];
        
        [controller setBackColor:self.backGroundColors[1]];
        controller.category = @"next";
        controller.managedObjectContext = self.managedObjectContext;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [self presentViewController:navController animated:NO completion:nil];

        
    }else if ([buttonTitle isEqualToString:PROJECT]){
        selectedTask.category = @"project";
        [self.managedObjectContext save:&error];

        [controller setBackColor:self.backGroundColors[2]];
        controller.category = @"project";
        controller.managedObjectContext = self.managedObjectContext;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [self presentViewController:navController animated:NO completion:nil];
        
    }else if([buttonTitle isEqualToString:WAITING_FOR]){
        selectedTask.category = @"waiting";
        [self.managedObjectContext save:&error];
        
        [controller setBackColor:self.backGroundColors[3]];
        controller.category = @"waiting";
        controller.managedObjectContext = self.managedObjectContext;

        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [self presentViewController:navController animated:NO completion:nil];

    }else if([buttonTitle isEqualToString:@"Delete"]){
        [self.managedObjectContext deleteObject:selectedTask];
        [self.managedObjectContext save:&error];

        [self.tableView reloadData];
    }else if([buttonTitle isEqualToString:DONE]){
        selectedTask.category = @"done";
        [self.managedObjectContext save:&error];
        
        [controller setBackColor:self.backGroundColors[4]];
        controller.category = @"done";
        controller.managedObjectContext = self.managedObjectContext;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [self presentViewController:navController animated:NO completion:nil];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Move Task To :"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:NEXT_ACTIONS, PROJECT, WAITING_FOR, DONE, nil];
    
    [actionSheet showInView:self.view];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellId = @"DetailCell1";
    
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text =  task.taskDescription;
    cell.textLabel.backgroundColor = self.backColor;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
    
    cell.contentView.backgroundColor = self.backColor;
    cell.backgroundColor = self.backColor;
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width , 1)];
    separatorLineView.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:separatorLineView];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    [view setAlpha:0.5F];
    
    return view;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;    
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *startDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    NSArray *sortDescriptors = @[startDateDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", self.category];
    [fetchRequest setPredicate:predicate];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"startDate" cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"mainSegue"]) {
        
        
        
        MasterViewController *controller = (MasterViewController *)[[segue destinationViewController] topViewController];
        controller.managedObjectContext = self.managedObjectContext;
        
        //controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end
