/*
 ******************************************************************************
 * Copyright (C) 2005-2013 Alfresco Software Limited.
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

/** The AlfrescoWorkflowInfo model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowInfo.h"
#import "AlfrescoCloudSession.h"
#import "AlfrescoRepositorySession.h"

NSString * const kCloudEdition = @"Alfresco in the Cloud";
NSString * const kEnterpriseEdition = @"Enterprise";
NSString * const kCommunityEdition = @"Community";

@interface AlfrescoWorkflowInfo ()

@property (nonatomic, assign, readwrite) AlfrescoWorkflowEngineType workflowEngine;
@property (nonatomic, assign, readwrite) BOOL publicAPI;
@property (nonatomic, weak, readwrite) id<AlfrescoSession> session;

@end

@implementation AlfrescoWorkflowInfo

- (id)initWithSession:(id<AlfrescoSession>)session workflowEngine:(AlfrescoWorkflowEngineType)workflowEngine
{
    self = [super init];
    if (self)
    {
        self.workflowEngine = workflowEngine;
        self.session = session;
        [self setupAPIVersion];
    }
    return self;
}

#pragma mark - Private Functions

- (void)setupAPIVersion
{
    AlfrescoRepositoryInfo *repositoryInfo = self.session.repositoryInfo;
    
    if ([repositoryInfo.edition isEqualToString:kCloudEdition] || [repositoryInfo.edition isEqualToString:kEnterpriseEdition])
    {
        if (self.workflowEngine == AlfrescoWorkflowEngineTypeJBPM)
        {
            self.publicAPI = NO;
        }
        else
        {
            NSNumber *majorVersion = repositoryInfo.majorVersion;
            NSNumber *minorVersion = repositoryInfo.minorVersion;
            float version = [[NSString stringWithFormat:@"%i.%i", majorVersion.intValue, minorVersion.intValue] floatValue];
            
            if ([self.session isKindOfClass:[AlfrescoCloudSession class]])
            {
                self.publicAPI = YES;
            }
            else if ([self.session isKindOfClass:[AlfrescoRepositorySession class]] && version >= 4.2f)
            {
                self.publicAPI = YES;
            }
            else
            {
                self.publicAPI = NO;
            }
        }
    }
    else
    {
        self.publicAPI = NO;
    }
}

@end