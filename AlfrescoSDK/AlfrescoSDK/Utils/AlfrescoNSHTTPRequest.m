/*
 ******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import "AlfrescoNSHTTPRequest.h"
#import "AlfrescoErrors.h"
#import "AlfrescoSession.h"
#import "AlfrescoAuthenticationProvider.h"

@interface AlfrescoNSHTTPRequest ()
@property (nonatomic, strong) NSURLConnection * connection;
@property (nonatomic, strong) NSMutableData * responseData;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) AlfrescoDataCompletionBlock completionBlock;

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
                header:(NSDictionary *)header
           requestBody:(NSData *)requestBody
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;

+ (id<AlfrescoHTTPRequest>)requestWithURL:(NSURL *)requestURL
                method:(NSString *)method
               headers:(NSDictionary *)header
           requestBody:(NSData *)data
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;
@end

@implementation AlfrescoNSHTTPRequest
@synthesize responseData = _responseData;
@synthesize completionBlock = _completionBlock;
@synthesize connection = _connection;
@synthesize statusCode = _statusCode;

+ (id<AlfrescoHTTPRequest>)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    return [self executeRequestWithURL:url session:session requestBody:nil method:kAlfrescoHTTPGet completionBlock:completionBlock];
}

+ (id<AlfrescoHTTPRequest>)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                       method:(NSString *)method
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    return [self executeRequestWithURL:url session:session requestBody:nil method:method completionBlock:completionBlock];
}


+ (id<AlfrescoHTTPRequest>)executeRequestWithURL:(NSURL *)url
                      session:(id<AlfrescoSession>)session
                  requestBody:(NSData *)requestBody
                       method:(NSString *)method
              completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    id authenticationProvider = [session objectForParameter:kAlfrescoAuthenticationProviderObjectKey];
    NSDictionary *httpHeaders = [authenticationProvider willApplyHTTPHeadersForSession:nil];
    return [self requestWithURL:url method:method headers:httpHeaders requestBody:requestBody completionBlock:completionBlock];
}

+ (id<AlfrescoHTTPRequest>)requestWithURL:(NSURL *)requestURL
                method:(NSString *)method
               headers:(NSDictionary *)header
           requestBody:(NSData *)data
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock;
{
    AlfrescoNSHTTPRequest *alfrescoRequest = [[AlfrescoNSHTTPRequest alloc] init];
    if (nil != alfrescoRequest)
    {
        [alfrescoRequest connectWithURL:requestURL method:method header:header requestBody:data completionBlock:completionBlock];
    }
    else
    {
        completionBlock(nil, [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeUnknown]);
    }
    return alfrescoRequest;
}




#pragma private method

- (void)connectWithURL:(NSURL*)requestURL
                method:(NSString *)method
                header:(NSDictionary *)header
           requestBody:(NSData *)requestBody
       completionBlock:(AlfrescoDataCompletionBlock)completionBlock
{
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    self.completionBlock = completionBlock;

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60];
    
    [urlRequest setHTTPMethod:method];
    
    [header enumerateKeysAndObjectsUsingBlock:^(NSString *headerKey, NSString *headerValue, BOOL *stop){
        log(@"headerKey = %@, headerValue = %@", headerKey, headerValue);
        [urlRequest addValue:headerValue forHTTPHeaderField:headerKey];
    }];

    if (nil != requestBody)
    {
        [urlRequest setHTTPBody:requestBody];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    self.responseData = nil;    
    self.connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

#pragma URL delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [NSMutableData data];
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.statusCode = httpResponse.statusCode;
    }
    else
    {
        self.statusCode = -1;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil == data)
    {
        return;
    }
    if (0 == data.length)
    {
        return;
    }
    if (nil != self.responseData)
    {
        [self.responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    if (self.statusCode < 200 || self.statusCode > 299)
    {
        error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
    }
    
    self.completionBlock(self.responseData, error);

    self.completionBlock = nil;
    self.connection = nil;
    self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.completionBlock(nil, error);
    self.connection = nil;
}




@end