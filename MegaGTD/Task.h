//
//  Task.h
//  
//
//  Created by Karan Singh on 8/28/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * completionDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSNumber * updateCount;
@property (nonatomic, retain) NSDate * updateDate;

@end
