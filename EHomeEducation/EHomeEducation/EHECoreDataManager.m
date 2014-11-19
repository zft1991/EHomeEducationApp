//
//  EHECoreDataManager.m
//  EHomeEducation
//
//  Created by Yixiang Chen on 11/18/14.
//  Copyright (c) 2014 AppChen. All rights reserved.
//

#import "EHECoreDataManager.h"
#import "EHETeacher.h"
#import "AppDelegate.h"

@implementation EHECoreDataManager

+ (EHECoreDataManager *) getInstance
{
    static EHECoreDataManager *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
        {
            sharedSingleton = [[EHECoreDataManager alloc] init];
        }
        
        return sharedSingleton;
    }
}

-(id)init
{
    if(self = [super init]){
        id delegate = [UIApplication sharedApplication].delegate;
        self->_context = [delegate valueForKey:@"managedObjectContext"];
    }
    return self;
}

-(void)updateTeachersInfos:(NSDictionary *) dict{
    
    NSArray *dictsForTeacherInfo = dict[@"teachersinfo"];
    
    for (NSDictionary *dictionary in dictsForTeacherInfo) {
        EHETeacher * teacher = [NSEntityDescription insertNewObjectForEntityForName:@"EHETeacher" inManagedObjectContext:self.context];
        teacher.teacherId = dictionary[@"teacherid"];
        teacher.teacherIcon = [[NSData alloc] initWithBase64EncodedString:dictionary[@"teachericon"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        teacher.subjectInfo = dictionary[@"subjectinfo"];
        teacher.rank = dictionary[@"rank"];
        teacher.name = dictionary[@"name"];
        teacher.majorAdress = dictionary[@"majorAdress"];
        teacher.longitude = dictionary[@"longitude"];
        teacher.latitude = dictionary[@"latitude"];
        [self.context save:nil];
        
    }
}

-(void)updateTeachersDetailedInfos:(NSDictionary *) dict withTeacherId:(int) teacherId {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EHETeacher"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacherId = %d", teacherId];
    fetchRequest.predicate = predicate;
    NSArray *teachers = [self.context executeFetchRequest:fetchRequest error:nil];
    EHETeacher *teacher = [teachers objectAtIndex:0];
    //EHETeacher * teacher = [NSEntityDescription insertNewObjectForEntityForName:@"EHETeacher" inManagedObjectContext:self.context];
    
    teacher.teacherId = [NSNumber numberWithInt:teacherId];
    teacher.birthday = dict[@"birthday"];
    teacher.degree = dict[@"degree"];
    teacher.gender = dict[@"gender"];
    teacher.identity = dict[@"identity"];
    teacher.memo = dict[@"memo"];
    teacher.objectInfo = dict[@"objectinfo"];
    teacher.qq = dict[@"qq"];
    teacher.sinaweibo = dict[@"sinaweibo"];
    teacher.telephone = dict[@"telephone"];
    teacher.timePeriod = dict[@"timeperiod"];
    [self.context save:nil];
    
}

-(NSArray *)fetchAllTeachersInfos {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EHETeacher"];
    NSPredicate * predicate = nil;
    fetchRequest.predicate = predicate;
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    NSArray *sorts = [[NSArray alloc] initWithObjects:sortByName, nil];
    fetchRequest.sortDescriptors = sorts;
    
    NSError *error;
    NSArray *teachers = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        return nil;
    }
    else if (teachers.count > 0)
    {
        return teachers;
    }
    return nil;
}

-(EHETeacher *)fetchDetailInfosWithTeacherId:(int)teacherId {
    NSLog(@"Now I am fetching teacher detail info with teacher id oye");

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"EHETeacher"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacherId = %d", teacherId];
    fetchRequest.predicate = predicate;

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    NSArray *sorts = [[NSArray alloc] initWithObjects:sortByName, nil];
    fetchRequest.sortDescriptors = sorts;
    
    NSError *error;
    NSArray *teachers = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        return nil;
    }
    else if (teachers.count > 0)
    {
        return teachers[0];
    }
    return nil;
}

@end
