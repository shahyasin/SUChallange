//
//  ApiRequest.h
//  StatUpChallange
//
//  Created by Shah Yasin on 6/9/17.
//  Copyright © 2017 Shah Yasin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApiRequestingDelegate <NSObject>
@optional
- (void)wordOfTheDayFetchOperationCompleted:(NSDictionary*)data;
- (void)serverError;
- (void)internetConnectivityError;
- (void)snsMessagePublishSuccessfull;
- (void)snsMessagePublishFailed;
@end

typedef enum{
    HTTP_OK,
    HTTP_CONTENT_NOT_FOUND,
    HTTP_BAD_REQUEST,
    HTTP_UNAUTHORIZE,
    HTTP_SERVER_ERROR,
    HTTP_NG
}HTTPResut;

@interface ApiRequest : NSObject{
    NSDictionary *dataDictionary;
}
@property (nonatomic,strong) id<ApiRequestingDelegate>delegate;
- (void)createApiBodyKeys:(NSArray*)keys andValues:(NSArray*)values;
- (void)performWordOfTheDayFetch;
- (void)awsSnsPublishMessage:(NSString*)msg subject:(NSString*)sub;
@end

