//
//  Task.h
//  MegaGTD
//
//  Created by Karan Singh on 12/4/14.
//  Copyright (c) 2014 Karan Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * completionDate;
@property (nonatomic, retain) NSString * category;

@end
