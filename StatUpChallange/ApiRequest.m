//
//  ApiRequest.m
//  StatUpChallange
//
//  Created by Shah Yasin on 6/9/17.
//  Copyright © 2017 Shah Yasin. All rights reserved.
//

#import "ApiRequest.h"
#import "Api.h"
#import "Reachability.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSSNS.h>
#import "Constants.h"

@implementation ApiRequest

@synthesize delegate;

- (void)performApiRequest:(NSURL*)url forMethod:(NSString*)httpMethod completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    NSURLSessionConfiguration *defaultConfiguratoin = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfiguratoin];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:httpMethod];
    [urlRequest setHTTPShouldHandleCookies:NO];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSError *error = nil;
    if(dataDictionary) {
        NSData *dataFromDict = [NSJSONSerialization dataWithJSONObject:dataDictionary
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
        [urlRequest setHTTPBody: dataFromDict];
    }
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data,NSURLResponse *response, NSError *error){
        dataDictionary = nil;
        completionHandler(data,response,error);
    }];
    [dataTask resume];
}

- (void)createApiBodyKeys:(NSArray*)keys andValues:(NSArray*)values {
    dataDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

- (void)performWordOfTheDayFetch {
    if([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] != NotReachable){
        NSURL *wordOfTheDayURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",WordNikAPI,WordNikAPIKey]];
        [self performApiRequest:wordOfTheDayURL forMethod:HTTP_GET completionHandler:^(NSData *data,NSURLResponse *response, NSError *error){
            if(error==nil){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                HTTPResut result = [self httpResultFromStatusCode:httpResponse.statusCode];
                if(result == HTTP_OK) {
                    if([self.delegate respondsToSelector:@selector(wordOfTheDayFetchOperationCompleted:)] && data !=nil) {
                        NSDictionary *dataToJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
                        [[NSUserDefaults standardUserDefaults] setObject:dataToJSON forKey:WordnikApiResult];
                        [self.delegate wordOfTheDayFetchOperationCompleted:dataToJSON];
                    }
                }
                else{
                    if([self.delegate respondsToSelector:@selector(serverError)]) {
                        [self.delegate serverError];
                    }
                }
            }else {
                if([self.delegate respondsToSelector:@selector(serverError)]) {
                    [self.delegate serverError];
                }
            }
        }];
    }
    else{
        if([self.delegate respondsToSelector:@selector(internetConnectivityError)]) {
            [self.delegate internetConnectivityError];
        }
    }
}

- (void)awsSnsPublishMessage:(NSString*)msg subject:(NSString*)sub{
    if([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] != NotReachable){
        [self awsCognitoConfigure];
        AWSSNS *publishCall = [AWSSNS defaultSNS];
        AWSSNSPublishInput *message = [AWSSNSPublishInput new];
        message.subject = sub;
        message.topicArn = TopicArn;
        message.message = msg;
        [[publishCall publish:message]continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task){
            if (task.error != nil) {
                NSLog(@"Error %@",task.error);
                if([self.delegate respondsToSelector:@selector(snsMessagePublishSuccessfull)]){
                    [self.delegate snsMessagePublishSuccessfull];
                }
            }
            else{
                NSLog(@"Successful");
                if([self.delegate respondsToSelector:@selector(snsMessagePublishFailed)]){
                    [self.delegate snsMessagePublishFailed];
                }
            }
            return nil;
        }];
    }
    else{
        if([self.delegate respondsToSelector:@selector(internetConnectivityError)]) {
            [self.delegate internetConnectivityError];
        }
    }
}

- (void)awsCognitoConfigure{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSWest2 identityPoolId:IdentityPoolID];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
}

- (HTTPResut)httpResultFromStatusCode:(NSInteger)responseStatus{
    HTTPResut result;
    switch (responseStatus) {
        case 200:
        case 201:
            result = HTTP_OK;
            break;
        case 400:
            result = HTTP_BAD_REQUEST;
            break;
        case 401:
        case 403:
            result = HTTP_UNAUTHORIZE;
            break;
        case 404:
            result = HTTP_CONTENT_NOT_FOUND;
            break;
        case 500:
        case 502:
        case 503:
            result = HTTP_SERVER_ERROR;
            break;
        default:
            result = HTTP_NG;
            break;
    }
    return result;
}

@end
