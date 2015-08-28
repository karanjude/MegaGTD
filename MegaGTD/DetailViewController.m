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
#import "SWTableViewCell.h"

#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view

@interface DetailViewController ()

@property NSArray *backGroundColors;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property UIPickerView *picker;
@property UIView *snapShot;
@property UIBarButtonItem *doneButton;

@property NSArray *scheduleTypes;
@property NSArray *scheduleWeekly;
@property NSArray *weekDayMap;
@property NSArray *scheduleMonthly;
@property NSArray *scheduleHourly;
@property NSArray *scheduleMinutes;
@property NSArray *emptyArray;
@property NSInteger selectedSchedule;
@property Task * selectedTask;

@property (nonatomic, strong) UITableViewCell *prototypeCell;

@end

static NSString* const SCHEDULE = @"Schedule";
static NSString* const NEXT_ACTIONS = @"Next Actions";
static NSString* const PROJECT = @"Project";
static NSString* const WAITING_FOR = @"Waiting For";
static NSString* const DONE = @"Done";
static NSDictionary* categoryTitles;


@implementation DetailViewController

#pragma mark - Managing the detail item


- (UITableViewCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailCell1"];
    }
    return _prototypeCell;
}

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
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done_clicked:)];


    self.scheduleTypes = [[NSArray alloc] initWithObjects:
                          @"Daily",@"Weekly",@"Month", nil];
    
    self.emptyArray = [[NSArray alloc] initWithObjects:
                       @"", nil];
    
    self.scheduleWeekly = [[NSArray alloc] initWithObjects:
                            @"Day",
                            @"Mon",@"Tue",@"Wed",@"Thu",@"Fri",
                                @"Sat",@"Sun", nil
                           ];

    self.scheduleHourly = [[NSArray alloc] initWithObjects:
                           @"Hr",@"00",
                           @"01",@"02",@"03",@"04",@"05",
                           @"06",@"07",@"08",@"09",@"10",
                           @"11",@"12",@"13",@"14",@"15",
                           @"16",@"17",@"18",@"19",@"20",
                           @"21",@"22",@"23",
                           nil];
    
    self.weekDayMap = @[@0,@7,@1,@2,@3,@4,@5,@6];

    
    self.scheduleMinutes = [[NSArray alloc] initWithObjects:
                            @"Mins",
                            @"00",@"05",@"10",@"15",@"20",
                            @"25",@"30",@"35",@"40",@"45",
                            @"50",@"55",
                            nil];

    self.scheduleMonthly = [[NSArray alloc] initWithObjects:
                           @"Day",@"00",
                           @"01",@"02",@"03",@"04",@"05",
                           @"06",@"07",@"08",@"09",@"10",
                           @"11",@"12",@"13",@"14",@"15",
                           @"16",@"17",@"18",@"19",@"20",
                           @"21",@"22",@"23",@"24",@"25",
                            @"26",@"27",@"28",@"29",@"30",
                            @"31",
                           nil];

    
    
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
        
        UILocalNotification *notificationToCancel=nil;

        for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            if([[aNotif.userInfo objectForKey:@"ID"] isEqualToString:selectedTask.objectID.description]) {
                notificationToCancel=aNotif;
                break;
            }
        }
        
        if(nil != notificationToCancel){
            [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
        }
        
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
    }else if([buttonTitle isEqualToString:SCHEDULE]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        CGRect frame = CGRectMake(CGRectGetMinX(cell.frame) - self.tableView.contentOffset.x, CGRectGetMaxY(cell.frame) , CGRectGetWidth(cell.frame), CGRectGetHeight(self.view.frame) - self.tableView.contentOffset.y);
        
        
        
        self.snapShot = [self.view resizableSnapshotViewFromRect:frame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        
        self.picker = [[UIPickerView alloc]initWithFrame:frame];
        self.picker.dataSource = self;
        self.picker.delegate = self;
        self.picker.backgroundColor = [UIColor whiteColor];
        
        
        self.snapShot.frame = frame;
        [self.view addSubview:self.snapShot];
        [self.view addSubview:self.picker];
        
        [self.view insertSubview:self.snapShot aboveSubview:self.picker];
        
        
        NSDate* date = selectedTask.startDate;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
        NSDateComponents *nowComponents = [calendar components:NSCalendarUnitYear |NSCalendarUnitMonth| NSCalendarUnitWeekOfMonth | NSCalendarUnitHour | NSWeekdayCalendarUnit| NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
        
        NSInteger hour = [nowComponents hour] + 1;
        NSInteger mins = [nowComponents minute];
        NSInteger weekday = [nowComponents weekday];
        NSInteger month = [nowComponents month];
        NSInteger minutes = ((int)(mins / 5 ))  + 1;
        
        NSLog(@"Task category %@", selectedTask.category);
        
        if([selectedTask.category hasSuffix:@"Weekly"]){
            [self.picker selectRow:1 inComponent:0 animated:NO];
            [self.picker reloadComponent:1];

            if(weekday == 1){
                weekday = 7;
            }else {
                weekday = weekday - 1;
            }
            
            [self.picker selectRow:weekday inComponent:1 animated:NO];
            self.selectedSchedule = 1;
        }else if([selectedTask.category hasSuffix:@"Month"]){
            [self.picker selectRow:2 inComponent:0 animated:NO];
            [self.picker selectRow:month inComponent:1 animated:NO];
            self.selectedSchedule = 2;
        }else{
            [self.picker selectRow:0 inComponent:0 animated:NO];
            self.selectedSchedule = 0;
        }

        [self.picker selectRow:hour inComponent:2 animated:NO];
        [self.picker selectRow:minutes inComponent:3 animated:NO];
        
        
        [UIView animateWithDuration:2 animations:^{
            self.snapShot.frame = CGRectOffset(self.snapShot.frame, 0, CGRectGetHeight(self.picker.frame));
            
            self.navigationItem.rightBarButtonItem= self.doneButton;

        }];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
        if (component == 0) {
            [pickerView reloadComponent:1];
            
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }

}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (0 == component) {
        return [self.scheduleTypes count];
    }else if (1 == component){
        NSInteger selectedRow = [self.picker selectedRowInComponent:0];
        //NSInteger selectedRow = self.selectedSchedule;
        if(1 == selectedRow){
            return [self.scheduleWeekly count];
        }else if(2 == selectedRow){
            return [self.scheduleMonthly count];
        }
        
        return 0;
    }else if (2 == component){
        return [self.scheduleHourly count];
    }else if(3 == component){
        return [self.scheduleMinutes count];
    }
    
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component
{
    if (0 == component) {
        return [self.scheduleTypes objectAtIndex:row];
    }else if (1 == component){
        NSUInteger selectedRow = [self.picker selectedRowInComponent:0];
        //NSInteger selectedRow = self.selectedSchedule;
        if(1 == selectedRow){
            return [self.scheduleWeekly objectAtIndex:row];
        }else if(2 == selectedRow){
            return [self.scheduleMonthly objectAtIndex:row];
        }
        
        return @"";
    }else if (2 == component){
        return [self.scheduleHourly objectAtIndex:row];
    }else if(3 == component){
        return [self.scheduleMinutes objectAtIndex:row];
    }

    return nil;
}

-(void)done_clicked:(UIBarButtonItem *)sender {
    if(nil != self.picker){

        NSString *v1 = [self.picker.delegate pickerView:self.picker titleForRow:[self.picker  selectedRowInComponent:0] forComponent:0];
        NSString *v2 = [self.picker.delegate pickerView:self.picker titleForRow:[self.picker  selectedRowInComponent:1] forComponent:1];
        NSString *v3 = [self.picker.delegate pickerView:self.picker titleForRow:[self.picker  selectedRowInComponent:2] forComponent:2];
        NSString *v4 = [self.picker.delegate pickerView:self.picker titleForRow:[self.picker  selectedRowInComponent:3] forComponent:3];
        
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Task *selectedTask = (Task *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        NSLog(@" Value: %@", @[v1, v2, v3, v4, selectedTask.objectID.description ]);


        if([v3 isEqualToString:@"Hr"] || [v4 isEqualToString:@"Mins"]){
            return;
        }
        
        NSInteger hourValue = [v3 integerValue];
        NSInteger minuteValue = [v4 integerValue ];
        NSInteger interval = ( hourValue * 60 * 60) + (minuteValue * 60);
        
        NSLog([NSString stringWithFormat:@"Interval %@", @(interval)]);
        
        [UIView animateWithDuration:.5
                         animations:^{
                             self.snapShot.frame = CGRectOffset(self.snapShot.frame, 0, - CGRectGetHeight(self.picker.frame));
                         
                         }
                         completion:^(BOOL finished){
                             
                             UILocalNotification *notificationToCancel=nil;
                             
                             /**
                              Delete existing notification
                              **/
                             for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                                 if([[aNotif.userInfo objectForKey:@"ID"] isEqualToString:selectedTask.objectID.description]) {
                                     notificationToCancel=aNotif;
                                     break;
                                 }
                             }
                             
                             if(nil != notificationToCancel){
                                 [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
                             }

                             /**
                              Schedule new notification
                              **/
                             UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                             localNotification.alertBody = selectedTask.taskDescription;
                             localNotification.timeZone = [NSTimeZone defaultTimeZone];
                             localNotification.soundName = UILocalNotificationDefaultSoundName;
                             localNotification.applicationIconBadgeNumber = 1;
                             //localNotification.hasAction = YES;
                             //localNotification.alertAction = @"Snooze";
                             localNotification.category = @"ACTIONABLE";
                             
                             NSDictionary *dict = @{@"ID": selectedTask.objectID.description};
                             localNotification.userInfo = dict;
                             localNotification.repeatCalendar = [NSCalendar currentCalendar];
                             
                             if([v1 isEqualToString:@"Daily"]){
                                 NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                                 calendar.timeZone = [NSTimeZone systemTimeZone];
                                 calendar.locale = [NSLocale currentLocale];
                                 
                                 NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
                                 [dateComponents setDay:1];
                                 
                                 NSDate *currentDate = [[NSCalendar currentCalendar]
                                                        dateByAddingComponents:dateComponents
                                                        toDate:[NSDate date] options:0];
                                 
                                 NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                                            fromDate:[NSDate date]];
                                 
                                 [components setHour:hourValue];
                                 [components setMinute:minuteValue];
                                 [components setSecond:0];
                                 
                                 NSDate *nextDate = [calendar dateFromComponents:components];;

                                 localNotification.fireDate = nextDate;
                                 localNotification.repeatInterval =NSCalendarUnitDay;
                                 
                                 selectedTask.startDate = nextDate;
                             }else if([v1 isEqualToString:@"Weekly"]){
                                 NSInteger weekday = 1; // Sunday
                                 
                                 if([v2 isEqualToString:@"Mon"]){
                                     weekday = 2;
                                 }else if([v2 isEqualToString:@"Tue"]){
                                     weekday = 3;
                                 }else if([v2 isEqualToString:@"Wed"]){
                                     weekday = 4;
                                 }else if([v2 isEqualToString:@"Thu"]){
                                     weekday = 5;
                                 }else if([v2 isEqualToString:@"Fri"]){
                                     weekday = 6;
                                 }else if([v2 isEqualToString:@"Sat"]){
                                     weekday = 7;
                                 }
                                 
                                 NSDate *today = [NSDate date];
                                 NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

                                 [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
                                 NSDateComponents *nowComponents = [calendar components:NSCalendarUnitYear |NSCalendarUnitMonth| NSCalendarUnitWeekOfMonth | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:today];

                                 
                                 [nowComponents setWeekday:weekday]; //Sunday
                                 [nowComponents setHour:hourValue]; // 12:00 AM = midnight (12:00 PM would be 12)
                                 [nowComponents setMinute:minuteValue];
                                 [nowComponents setSecond:0];
                                 NSDate *fireDate = [calendar dateFromComponents:nowComponents];

                                 localNotification.fireDate = fireDate;
                                 localNotification.repeatInterval =NSCalendarUnitWeekday;
                                 
                                 selectedTask.startDate = fireDate;
                             }else if([v1 isEqualToString:@"Month"]){
                                 
                                 NSInteger day = [v2 integerValue];
                                 NSDate *today = [NSDate date];
                                 
                                 NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                                 
                                 [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
                                 NSDateComponents *nowComponents = [calendar components:NSCalendarUnitYear |NSCalendarUnitMonth| NSCalendarUnitWeekOfMonth | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:today];

                                 [nowComponents setDay:day]; //Sunday
                                 [nowComponents setHour:hourValue]; // 12:00 AM = midnight (12:00 PM would be 12)
                                 [nowComponents setMinute:minuteValue];
                                 [nowComponents setSecond:0];
                                 NSDate *fireDate = [calendar dateFromComponents:nowComponents];
                                 
                                 localNotification.fireDate = fireDate;
                                 localNotification.repeatInterval=NSCalendarUnitMonth;
                             
                                 selectedTask.startDate = fireDate;
                             }
                             
                             NSString *dateString = [NSDateFormatter
                                                     localizedStringFromDate:selectedTask.startDate
                                                                                   dateStyle:NSDateFormatterShortStyle
                                                                                   timeStyle:NSDateFormatterFullStyle];
                             
                             NSArray *array = [selectedTask.category componentsSeparatedByString:@":"];
                             selectedTask.category = [NSString stringWithFormat:@"%@:%@", array[0], v1];
                             
                             NSLog(@" Task : %@", @[selectedTask.taskDescription, selectedTask.category,  dateString ]);
                             
                             NSError* error;
                             [self.managedObjectContext save:&error];

                             [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

                             [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                             
                             [self.picker removeFromSuperview];
                             [self.snapShot removeFromSuperview];
                             self.navigationItem.rightBarButtonItem= nil;
                             
                             [self.tableView reloadData];
                             
                             self.picker = nil;
                             self.snapShot = nil;
                         }
        ];
        
        
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(nil != self.picker){
        [UIView animateWithDuration:.5
                         animations:^{
                             self.snapShot.frame = CGRectOffset(self.snapShot.frame, 0, - CGRectGetHeight(self.picker.frame));
                             
                         }
                         completion:^(BOOL finished){
                             [self.picker removeFromSuperview];
                             [self.snapShot removeFromSuperview];
                             self.navigationItem.rightBarButtonItem= nil;

                             
                             self.picker = nil;
                             self.snapShot = nil;
                         }
         ];
        
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Move Task To :"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete"
                                                        otherButtonTitles:SCHEDULE, NEXT_ACTIONS, PROJECT, WAITING_FOR, DONE, nil];
        
        
        [actionSheet showInView:self.view];
        
    }

    
    
}

- (NSArray *)rightButtons
{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    /*
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];*/
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor grayColor]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
/*
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
*/
    


    return leftUtilityButtons;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellId = @"DetailCell1";
    
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    
    if([task.category hasPrefix:@"project"]){
        //        cell.leftUtilityButtons = [self leftButtons];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
    } 
    
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text =  task.taskDescription;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.backgroundColor = self.backColor;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
    cell.contentView.backgroundColor = self.backColor;

    if([task.category hasPrefix:@"project"] && task.updateDate != nil && task.updateCount != nil){
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:task.updateDate
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterShortStyle];
        
        NSString* suffix = @"times";
        if([task.updateCount longValue] == 1){
            suffix = @"time";
        }
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@" %@  Updated: %@ %@", dateString, [task.updateCount stringValue] , suffix ];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0];
    }
    
 /*
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 1)];
    separatorLineView.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:separatorLineView];
 */
    
    return cell;
}

// click event on right utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    if(index == 0){
        NSIndexPath *cellindexPath = [self.tableView indexPathForCell:cell];

        Task *taskfForCell = (Task *)[[self fetchedResultsController] objectAtIndexPath:cellindexPath];
        taskfForCell.updateDate = [NSDate date];
        if(taskfForCell.updateCount == nil){
            taskfForCell.updateCount = [NSNumber numberWithLong:0];
        }else{
            long updateCount = 1 + [taskfForCell.updateCount longValue];
            taskfForCell.updateCount = [NSNumber numberWithLong:updateCount];
        }
        
        NSLog(@"clock button was pressed for %@", taskfForCell.taskDescription );
        
        NSError* error;
        if([self.managedObjectContext save:&error]){
            NSError* error;
            [self.fetchedResultsController performFetch:&error ];
            
            [cell hideUtilityButtonsAnimated:YES];
            [self.tableView reloadData];
        }

        [cell hideUtilityButtonsAnimated:YES];

    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath;
{

    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
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
    NSSortDescriptor *updateDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateDate" ascending:YES];

    NSArray *sortDescriptors = @[updateDateDescriptor, startDateDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", self.category];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category BEGINSWITH %@", self.category];
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    NSError* error;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView
                                 cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
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
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];

            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CGSize maximumLabelSize = CGSizeMake(310, CGFLOAT_MAX);
    CGRect textRect = [task.taskDescription boundingRectWithSize:maximumLabelSize
                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                          attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]}
                                             context:nil];
    CGRect detailTextRect = [@"boo" boundingRectWithSize:maximumLabelSize
                                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                            attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0]}
                                                               context:nil];
    
    return textRect.size.height * 2 + 10;
}

@end
