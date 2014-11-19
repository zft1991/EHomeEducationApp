//
//  EHECoreDataManager.h
//  EHomeEducation
//
//  Created by Yixiang Chen on 11/18/14.
//  Copyright (c) 2014 AppChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface EHECoreDataManager : NSObject
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *context;
+ (EHECoreDataManager *) getInstance;
-(void) updateTeachersInfos:(NSDictionary *) dict;
-(void)updateTeachersDetailedInfos:(NSDictionary *) dict withTeacherId:(int) teacherId;
-(NSArray *) fetchAllTeachersInfos;
-(NSArray *) fetchDetailInfosWithTeacherId:(int) teacherId;

@end
