//
//  EHECommunicationManager.m
//  EHomeEducation
//
//  Created by Yixiang Chen on 11/18/14.
//  Copyright (c) 2014 AppChen. All rights reserved.
//

#import "Defines.h"
#import "EHECommunicationManager.h"
#import "EHECoreDataManager.h"
#import "AFNetworking.h"

@implementation EHECommunicationManager

+ (EHECommunicationManager *) getInstance
{
    static EHECommunicationManager *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
        {
            sharedSingleton = [[EHECommunicationManager alloc] init];
        }
        
        return sharedSingleton;
    }
}

-(void)loadTeachersInfo {
    
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
    NSDictionary * latitudeAndLongitude= [userDefault objectForKey:@"latitudeAndLongitude"];
    NSString * latitude=[latitudeAndLongitude objectForKey:@"latitude"];
    NSString * longitude=[latitudeAndLongitude objectForKey:@"longitude"];
    float latitudeFloat=latitude.floatValue;
    float longitudeFloat=longitude.floatValue;
    NSLog(@"%f",latitudeFloat);
    NSLog(@"latitude=%@",latitude);
    NSString * postData = [NSString stringWithFormat:@"{\"customerid\":\"%d\",\"latitude\":\"%f\",\"longitude\":\"%f\",\"distancefilter\":\"%f\",\"keyword\":\"%s\"}",270,latitudeFloat,longitudeFloat,1000.0,""];
    
    NSLog(@"%@",postData);
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLFindTeacherList];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString * string=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"responseString=%@",string);
    if(responseData != nil && error == nil){
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        
        if([dict[@"code"] intValue] == 0){
            NSLog(@"dict=%@",dict);
            NSLog(@"成功获取教师初步信息");
            [[EHECoreDataManager getInstance] updateBasicInfosOfTeachers:dict];
        }else{
            
            NSLog(@"获取教师初步信息失败");
            NSLog(@"%@",dict[@"message"]);
        }
    }
    
}

-(void)loadDataWithTeacherID:(int) teacherId {
    
    NSString * postData = [NSString stringWithFormat:@"{\"teacherid\":\"%d\"}",teacherId];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLFindTeacherDetail];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString * resposeString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"responseString=%@",resposeString);
    
    if(responseData != nil && error == nil){
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary *dictTeacherInfo = dict[@"teacherinfo"];
        NSLog(@"dict=%@",dict);
        if([dict[@"code"] intValue] == 0){
            NSLog(@"获取教师具体信息成功");
            [[EHECoreDataManager getInstance] updateDetailInfos:dictTeacherInfo withTeacherId:teacherId];
        }else{
            NSLog(@"%@",dict[@"message"]);
        }
    }
    
}

-(void)loadOrderInfosWithCustomerID:(int)customerID andOrderStatus:(int)status {
    
    /*  status含义：
     -1: 所有状态订单
     0：客户发出订单
     1：教师确认订单
     2：教师拒绝订单
     3：客户取消订单
     4：客户确认完成
     5：教师确认完成
     6：双方确认完成
     */
    
    NSString * postData = [NSString stringWithFormat:@"{\"customerid\":\"%d\",\"orderstatus\":\"%d\",\"page\":\"1\",\"count\":\"10\"}",customerID,status];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLFindOrderList];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        NSArray *arrayOrders = dict[@"ordersinfo"];
        if([dict[@"code"] intValue] == 0){
            NSLog(@"获取订单信息成功");
            NSLog(@"orderinfo=%@",arrayOrders);
            [[EHECoreDataManager getInstance] saveOrderInfos:arrayOrders];
        }else{
            NSLog(@"%@",dict[@"message"]);
        }
    }
}

-(void)loadOrderDetailWithOrderID:(int)orderID {
    
    NSString * postData = [NSString stringWithFormat:@"{\"orderid\":\"%d\"}",orderID];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLFindOrderDetail];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary *dictOrderInfo = dict[@"orderinfo"];
        if([dict[@"code"] intValue] == 0){
            NSLog(@"-----------------获取订单详情成功----------------");
            [[EHECoreDataManager getInstance] upDateOrderDetail:dictOrderInfo withOrderId:orderID];
        }else{
            NSLog(@"%@",dict[@"message"]);
        }
    }
}



-(void)sendOrder:(NSDictionary *)dictOrder {
    
    NSUserDefaults * userDefault=[NSUserDefaults standardUserDefaults];
    NSDictionary * latitudeAndLongitude= [userDefault objectForKey:@"latitudeAndLongitude"];
    NSString * latitude=[latitudeAndLongitude objectForKey:@"latitude"];
    NSString * longitude=[latitudeAndLongitude objectForKey:@"longitude"];
    
    
    NSLog(@"以下是发送的订单详情 %@",dictOrder);
    NSString * postData = [NSString stringWithFormat:@"{\"customerid\":%@,\"latitude\":\"%f\",\"longitude\":\"%f\",\"serviceaddress\":\"%@\",\"teacherid\":%@,\"orderdate\":\"%@\",\"timeperiod\":\"%@\",\"objectinfo\":\"%@\",\"subjectinfo\":\"%@\",\"memo\":\"%@\",\"orderstatus\":%@,\"apptype\":%d}",[dictOrder objectForKey:@"customerid"],latitude.floatValue,longitude.floatValue,[dictOrder objectForKey:@"serviceaddress"],[dictOrder objectForKey:@"teacherid"],[dictOrder objectForKey:@"orderdate"],[dictOrder objectForKey:@"timeperiod"],[dictOrder objectForKey:@"objectinfo"],[dictOrder objectForKey:@"subjectinfo"],[dictOrder objectForKey:@"memo"], [dictOrder objectForKey:@"orderstatus"],3];
    
    NSLog(@"postData=%@",postData);
    
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLReserveTeacher];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        if([dict[@"code"] intValue] == 0){
            NSLog(@"发送订单成功");
        }else{
            NSLog(@"%@",dict[@"message"]);
        }
    }
}
-(void)sendOtherInfo:(NSDictionary *)dictOtherInfo {
    
    NSString * postData = [NSString stringWithFormat:@"{\"customerid\":\"%@\",\"name\":\"%@\",\"gender\":\"%@\",\"telephone\":\"%@\",\"latitude\":\"%@\",\"longitude\":\"%@\",\"majoraddress\":\"%@\",\"memo\":\"%@\"}",[dictOtherInfo objectForKey:@"customerid"],[dictOtherInfo objectForKey:@"name"],[dictOtherInfo objectForKey:@"gender"],[dictOtherInfo objectForKey:@"telephone"],[dictOtherInfo objectForKey:@"latitude"],[dictOtherInfo objectForKey:@"longitude"],[dictOtherInfo objectForKey:@"majoraddress"],[dictOtherInfo objectForKey:@"memo"]];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLUserOtherInfo];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        if([dict[@"code"] intValue] == 0){
            NSLog(@"dict=%@",dict);
            NSLog(@"发送补充个人信息成功");
            //[[EHECoreDataManager getInstance] savePersonalData:dictOtherInfo];
        }else{
            NSLog(@"%@",dict[@"message"]);
        }
    }
}

-(void)cancelOrderWithOrderId:(int)orderId withReason:(NSString *)memo {
    NSString * postData = [NSString stringWithFormat:@"{\"orderid\":\"%d\",\"orderstatus\":\"3\",\"memo\":\"%@\",\"apptype\":3}",orderId,memo];
    NSLog(@"postData:%@",postData);
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLCancelOrder];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSMutableString * stringResponse=[[NSMutableString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"responseData=%@",stringResponse);
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"返回的dict:%@",dict);
        if([dict[@"code"] intValue] == 0){
            NSLog(@"订单状态改为%@",dict[@"orderstatus"]);
            NSLog(@"orderstatus:如果返回3，证明取消成功，如果返回的是4，5，6则表明订单处于不可取消状态，-1为重复取消订单，不允许取消已经取消的订单");
        }else{
            NSLog(@"%@",dict[@"message"]);
        }
    }
}

-(void)confirmOrderWithOrderId:(int)orderId {
    NSString * postData = [NSString stringWithFormat:@"{\"orderid\":\"%d\",\"orderstatus\":\"4\"}",orderId];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLCompleteOrder];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        if([dict[@"code"] intValue] == 0){
            NSLog(@"订单状态改为%@",dict[@"orderstatus"]);
            NSLog(@"orderstatus:证明确认成功，可能返回的是4，6中的一个。-1是失败，具体原因看提示信息");
        }else{
            NSLog(@"%@",dict[@"message"]);
        }
    }
}

-(void)uploadUserIconWithCustomerId:(int)customerId andImage:(NSData *)myImage {
    
    
    NSString * path = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLUploadIcon];
    AFHTTPRequestSerializer * serializer = [[AFHTTPRequestSerializer alloc]init];
    
    
    NSMutableURLRequest * request = [serializer multipartFormRequestWithMethod:@"POST" URLString:path parameters:@{@"customerid":@(customerId)} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //UIImage * image = [UIImage imageNamed:@"female_tablecell.png"];//这里可以使用照相机照一张，或者从图片库中选一张。具体代码自己参考之前讲的内容。
        
        //第一个参数：将要上传的图片变为NSData
        //第二个参数：name必须为@"usericond",
        //第三个参数fileName：@"任意的名字，例如下面的例子"。
        //第四个参数：mimeType：如果是png:@"image/png",如果是jpg：@"image/jpeg".服务器接收好像两种png和jpg格式的图片
        UIImage * image=[UIImage imageWithData:myImage];
        NSLog(@"要传送的image=%@",image);
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"usericon" fileName:[NSString stringWithFormat:@"image_customerid_%d",customerId] mimeType:@"image/png"];
        
    } error:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //上传成功
        NSLog(@"头像上传成功！");
        NSLog(@"%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"头像上传失败");
    }];
    [operation start];//开始上传
    
}

-(NSData*)downloadUserIcon:(NSString *)iconPath
{
    NSString * stringPath=[NSString stringWithFormat:@"%@%@",kURLLoadUserIcon,iconPath];
    NSLog(@"%@",stringPath);
    NSURL * requestUrl=[NSURL URLWithString:stringPath];
    NSData * data=[NSData dataWithContentsOfURL:requestUrl];
    return data;
}

-(void)commentTeacherWithTeacherId:(int)teacherId fromCustomerWithCustomerId:(int) customerId withRank:(int)rank andContent:(NSString *)content {
    NSString * postData = [NSString stringWithFormat:@"{\"teacherid\":\"%d\",\"customerid\":\"%d\",\"rank\":\"%d\",\"commenttype\":\"1\",\"content\":\"%@\"}",teacherId,customerId,rank,content];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLCommentTeacher];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        if([dict[@"code"] intValue] == 0){
            NSLog(@"评价成功");
        }else{
            NSLog(@"评价失败");
            NSLog(@"%@",dict[@"message"]);
        }
    }
}

-(void)loadRankWithTeacherId:(int)teacherId {
    
    NSString * postData = [NSString stringWithFormat:@"{\"teacherid\":\"%d\",\"commenttype\":\"1\",\"page\":\"1\",\"count\":\"10\"}",teacherId];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@%@",kURLDomain,kURLFindTeacherComments];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        if([dict[@"code"] intValue] == 0){
            NSLog(@"得到的评价是%@",dict[@"comments"]);
        }else{
            NSLog(@"获取评价失败");
            NSLog(@"%@",dict[@"message"]);
        }
    }
    
}

-(void)removeOrderFromServerWithOrderId:(int)orderId {
    NSString * postData = [NSString stringWithFormat:@"{\"orderid\":\"%d\"}",orderId];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@",kURLDeleteOrder];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

    NSMutableString * stringData=[[NSMutableString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"ResponseString=%@",stringData);
    if(responseData != nil && error == nil){
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"获取到的dict=%@",dict);
        if([dict[@"code"] intValue] == 0){
            NSLog(@"订单删除成功");
        }else{
            NSLog(@"订单删除失败");
            NSLog(@"%@",dict[@"message"]);
        }
    }
    
}
-(NSArray *)loadCommentsWithCustomerId:(int)customerId {
    NSString * postData = [NSString stringWithFormat:@"{\"customerid\":%d,\"commenttype\":0,\"page\":1,\"count\":20}",customerId];
    
    NSString *stringForURL = [NSString stringWithFormat:@"%@",kURLFindCustomerComments];
    NSLog(@"path=%@",stringForURL);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringForURL]];
    
    NSString * data = [NSString stringWithFormat:@"info=%@",postData];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData * responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString * responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"responseString=%@",responseString);
    if(responseData != nil && error == nil){
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        
        if([dict[@"code"] intValue] == 0 && dict[@"code"] != nil){
            
//            NSLog(@"成功获取评价，评价详情如下");
//            NSLog(@"%@",[[dict[@"comments"] objectAtIndex:0] objectForKey:@"content"]);
            return [dict objectForKey:@"comments"];
            
        }else{
            
            NSLog(@"获取用户评价失败");
            NSLog(@"%@",dict[@"message"]);
            return NO;
        }
    } else {
        return NO;
    }
}
@end
