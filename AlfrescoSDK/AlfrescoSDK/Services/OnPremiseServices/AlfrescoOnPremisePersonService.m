/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoOnPremisePersonService.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoHTTPUtils.h"
#import "AlfrescoPagingUtils.h"

@interface AlfrescoOnPremisePersonService ()
@property (nonatomic, strong, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSString *baseApiUrl;
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readwrite) AlfrescoObjectConverter *objectConverter;
@property (nonatomic, weak, readwrite) id<AlfrescoAuthenticationProvider> authenticationProvider;
- (AlfrescoPerson *) parsePersonArrayWithData:(NSData *)data error:(NSError **)outError;
- (AlfrescoPerson *)personFromJSON:(NSDictionary *)personDict;
@end


@implementation AlfrescoOnPremisePersonService
@synthesize baseApiUrl = _baseApiUrl;
@synthesize session = _session;
@synthesize operationQueue = _operationQueue;
@synthesize objectConverter = _objectConverter;
@synthesize authenticationProvider = _authenticationProvider;

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if (self = [super init])
    {
        self.session = session;
        self.baseApiUrl = [[self.session.baseUrl absoluteString] stringByAppendingString:kAlfrescoOnPremiseAPIPath];
        self.objectConverter = [[AlfrescoObjectConverter alloc] initWithSession:self.session];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
        id authenticationObject = objc_getAssociatedObject(self.session, &kAlfrescoAuthenticationProviderObjectKey);
        self.authenticationProvider = nil;
        if ([authenticationObject isKindOfClass:[AlfrescoBasicAuthenticationProvider class]])
        {
            self.authenticationProvider = (AlfrescoBasicAuthenticationProvider *)authenticationObject;
        }
    }
    return self;
}
- (void)retrievePersonWithIdentifier:(NSString *)identifier completionBlock:(AlfrescoPersonCompletionBlock)completionBlock
{
    NSAssert(nil != identifier, @"identifier must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    __weak AlfrescoOnPremisePersonService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremisePersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:identifier];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                           weakSelf.baseApiUrl, requestString]];
        
        NSLog(@"url string from retrievePersonWithIdentifier is %@ RequestString is %@",[url absoluteString], requestString);
        
        NSData *data = [AlfrescoHTTPUtils executeRequestWithURL:url
                                         authenticationProvider:weakSelf.authenticationProvider
                                                           data:nil
                                                     httpMethod:@"GET"
                                                          error:&operationQueueError];
        AlfrescoPerson *person = nil;
        if (nil != data)
        {
            person = [weakSelf parsePersonArrayWithData:data error:&operationQueueError];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            log(@"returned json data");
            completionBlock(person, operationQueueError);
        }];
        
    }];
}

- (void)retrieveAvatarForPerson:(AlfrescoPerson *)person completionBlock:(AlfrescoContentFileCompletionBlock)completionBlock
{
    NSAssert(nil != person, @"person must not be nil");
    NSAssert(nil != completionBlock, @"completionBlock must not be nil");
    
    __weak AlfrescoOnPremisePersonService *weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        
        NSError *operationQueueError = nil;
        NSString *requestString = [kAlfrescoOnPremiseAvatarForPersonAPI stringByReplacingOccurrencesOfString:kAlfrescoPersonId withString:person.identifier];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                           [weakSelf.session.baseUrl absoluteString], requestString]];
        NSData *data = [AlfrescoHTTPUtils executeRequestWithURL:url
                                         authenticationProvider:weakSelf.authenticationProvider
                                                           data:nil
                                                     httpMethod:@"GET"
                                                          error:&operationQueueError];
        
        AlfrescoContentFile *avatarFile = nil;
        if (nil != data)
        {
            avatarFile = [[AlfrescoContentFile alloc] initWithData:data mimeType:@"application/octet-stream"];
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(avatarFile, operationQueueError);
        }];
    }];
}

#pragma mark - private methods
- (AlfrescoPerson *) parsePersonArrayWithData:(NSData *)data error:(NSError *__autoreleasing *)outError
{
    if (nil == data)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeUnknown
                                            withDetailedDescription:@"JSON comment data to be parsed should not be NIL"];
        }
        else
        {
            NSError *error = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeUnknown
                                            withDetailedDescription:@"JSON comment data to be parsed should not be NIL"];
            *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodeUnknown];
        }
        return nil;
    }
    
    NSError *error = nil;
    id jsonPersonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(nil == jsonPersonDict)
    {
        *outError = [AlfrescoErrors alfrescoError:error withAlfrescoErrorCode:kAlfrescoErrorCodePerson];
        return nil;
    }
    if ([[jsonPersonDict valueForKeyPath:kAlfrescoJSONStatusCode] isEqualToNumber:[NSNumber numberWithInt:404]])
    {
        // no person found
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodePerson
                                            withDetailedDescription:@"Failure to create Alfresco Person"];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodePerson
                                                           withDetailedDescription:@"Failure to create Alfresco Person"];
            *outError = [AlfrescoErrors alfrescoError:underlyingError withAlfrescoErrorCode:kAlfrescoErrorCodePerson];
        }
        return nil;
    }
    if (NO == [jsonPersonDict isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing
                                            withDetailedDescription:@"JSON entry should map to NSDictionary"];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors createAlfrescoErrorWithCode:kAlfrescoErrorCodeJSONParsing
                                                           withDetailedDescription:@"JSON entry should map to NSDictionary"];
            *outError = [AlfrescoErrors alfrescoError:underlyingError withAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return nil;
    }
    return (AlfrescoPerson *)[self personFromJSON:(NSDictionary *)jsonPersonDict];
    
}

- (AlfrescoPerson *)personFromJSON:(NSDictionary *)personDict
{
    AlfrescoPerson *alfPerson = [[AlfrescoPerson alloc] init];
    alfPerson.identifier = [personDict valueForKey:kAlfrescoJSONUserName];
    alfPerson.firstName = [personDict valueForKey:kAlfrescoJSONFirstName];
    alfPerson.lastName = [personDict valueForKey:kAlfrescoJSONLastName];
    if (alfPerson.lastName != nil && alfPerson.lastName.length > 0)
    {
        if (alfPerson.firstName != nil && alfPerson.firstName.length > 0)
        {
            alfPerson.fullName = [NSString stringWithFormat:@"%@ %@", alfPerson.firstName, alfPerson.lastName];
        }
        else
        {
            alfPerson.fullName = alfPerson.lastName;
        }
    }
    else if (alfPerson.firstName != nil && alfPerson.firstName.length > 0)
    {
        alfPerson.fullName = alfPerson.firstName;
    }
    else
    {
        alfPerson.fullName = alfPerson.identifier;
    }
    alfPerson.avatarIdentifier = [personDict valueForKey:kAlfrescoJSONAvatar];
    return alfPerson;
}


@end