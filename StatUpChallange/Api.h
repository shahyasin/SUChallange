//
//  Api.h
//  StatUpChallange
//
//  Created by Shah Yasin on 6/9/17.
//  Copyright © 2017 Shah Yasin. All rights reserved.
//

#ifndef Api_h
#define Api_h


#define HTTP_POST          @"POST"
#define HTTP_GET           @"GET"
#define HTTP_PUT           @"PUT"
#define HTTP_DELETE        @"DELETE"


#define  RESPONSE_CODE_OK  200
#define  RESPONSE_CODE_CREATED  201
#define  RESPONSE_CODE_NO_CONTENT  204
#define  RESPONSE_CODE_NOT  304
#define  RESPONSE_CODE_BAD_REQUEST  400
#define  RESPONSE_CODE_UNAUTHORIZED  401
#define  RESPONSE_CODE_FORBIDDEN 403
#define  RESPONSE_CODE_NOT_FOUND  404
#define  RESPONSE_CODE_CONFLICT_PROPERTY  409
#define  RESPONSE_CODE_ENHANCE_YOUR_CALM  420
#define  RESPONSE_CODE_INTERNAL_SERVER_ERROR  500
#define  RESPONSE_CODE_BAD_GATEWAY  502
#define  RESPONSE_CODE_SERVICE_UNAVAILABLE 503

#define WordNikAPI  @"http://api.wordnik.com:80/v4/words.json/wordOfTheDay?api_key="
#define LogIn    @"/user/login/"
#define WordNikAPIKey  @"a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
#define IdentityPoolID @"us-west-2:0c57a6ca-b882-4ca7-ab96-d2cac360a80c"
#define TopicArn  @"arn:aws:sns:us-west-2:327210751071:statup-challenge-push"


#endif /* Api_h */
