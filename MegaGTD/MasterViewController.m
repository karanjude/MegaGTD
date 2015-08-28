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

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define kAppHasRunBeforeKey @"appFirstTimeRun"

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

- (void)showIntro {
    UIView* rootView = self.navigationController.view;

    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"MegaGTD";
    page1.titlePositionY = 320;
    page1.desc = @"Based on \"Getting Things Done Principle\", streaminline your TODO Tasks \n\n Create New Task using the \"+\" Button \n\n Organize tasks into various GTD ( In, NextActions, Project, WaitingFor, Done ) categories .";
    page1.descPositionY = 180;
    
    // image is an instance of UIImage class that we will convert to grayscale
    UIImage* image = [UIImage imageNamed:@"main_screen"];
    page1.bgImage = [self blur:image andAlpha:.6f];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"Add New Task";
    page2.desc = @"Provide Description for new tasks.";
    page2.bgImage = [self blur:[UIImage imageNamed:@"add_task_screen"] andAlpha:.6f];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"Organize Tasks";
    page3.titlePositionY = rootView.bounds.size.height - 60;
    page3.desc = @"Move tasks into GTD categories. \n Schedule Tasks.";
    page3.descPositionY = rootView.bounds.size.height - 80;
    
    page3.bgImage = [self blur:[UIImage imageNamed:@"task_options_screen"] andAlpha:.8f];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"Schedule Tasks";
    page4.titlePositionY = 220;
    page4.desc = @"Schedule Tasks Daily / Weekly / Monthly \n\n OR \n\n For a specific Date / Time.";
    page4.bgImage = [self blur:[UIImage imageNamed:@"task_schedule_screen"] andAlpha:.6f];
    page4.descPositionY = 180;

    EAIntroPage *page5 = [EAIntroPage page];
    page5.bgImage = [UIImage imageNamed:@"gtd"];
    page5.title = @"GTD Principle";

    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3,page4, page5]];
    [intro setDelegate:self];

    [intro showInView:rootView animateDuration:0.3];
    
}

- (UIImage*) blur:(UIImage*)theImage andAlpha:(float)alpha
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    //First, we'll use CIAffineClamp to prevent black edges on our blurred image
    //CIAffineClamp extends the edges off to infinity (check the docs, yo)
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKeyPath:kCIInputImageKey];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKeyPath:@"inputTransform"];
    CIImage *clampedImage = [clampFilter outputImage];
    
    //Next, create some darkness
    CIFilter* blackGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    CIColor* black = [CIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:alpha];
    [blackGenerator setValue:black forKey:@"inputColor"];
    CIImage* blackImage = [blackGenerator valueForKey:@"outputImage"];
    
    //Apply that black
    CIFilter *compositeFilter = [CIFilter filterWithName:@"CIMultiplyBlendMode"];
    [compositeFilter setValue:blackImage forKey:@"inputImage"];
    [compositeFilter setValue:clampedImage forKey:@"inputBackgroundImage"];
    CIImage *darkenedImage = [compositeFilter outputImage];
    
    //Third, blur the image
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:@(5.0f) forKey:@"inputRadius"];
    [blurFilter setValue:darkenedImage forKey:kCIInputImageKey];
    CIImage *blurredImage = [blurFilter outputImage];
    
    CGImageRef cgimg = [context createCGImage:blurredImage fromRect:inputImage.extent];
    UIImage *blurredAndDarkenedImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return blurredAndDarkenedImage;
    
}


- (UIImage*) blur:(UIImage*)theImage
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
    // *************** if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc]initWithTitle:@"?" style:UIBarButtonItemStylePlain target:self action:@selector(showHelp:)];
    
    
    
    self.navigationItem.rightBarButtonItems = @[addButton, helpButton];
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
        NSArray *array = [categoryValue componentsSeparatedByString:@":"];
        
        if ([self.categoryCount objectForKey:array[0]]) {
            NSNumber* v = self.categoryCount[array[0]];
            self.categoryCount[array[0]] = [[NSNumber alloc] initWithInteger: [v intValue] + countValue];
        }else{
            self.categoryCount[array[0]] = [[NSNumber alloc] initWithInteger:countValue];
        }
        
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


    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:kAppHasRunBeforeKey] boolValue]) {
        [self showIntro];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAppHasRunBeforeKey];
    }
    
    
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

- (void)showHelp:(id)sender {
    [self showIntro];
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
