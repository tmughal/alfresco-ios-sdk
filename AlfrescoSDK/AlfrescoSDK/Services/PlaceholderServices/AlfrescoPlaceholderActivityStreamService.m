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

#import "AlfrescoPlaceholderActivityStreamService.h"
#import "AlfrescoCloudActivityStreamService.h"
#import "AlfrescoOnPremiseActivityStreamService.h"
#import "AlfrescoRepositorySession.h"
#import "AlfrescoCloudSession.h"

@implementation AlfrescoPlaceholderActivityStreamService

- (id)initWithSession:(id<AlfrescoSession>)session
{
    if ([session isKindOfClass:[AlfrescoRepositorySession class]])
    {
        return (id)[[AlfrescoOnPremiseActivityStreamService alloc] initWithSession:session];
    }
    if ([session isKindOfClass:[AlfrescoCloudSession class]])
    {
        return (id)[[AlfrescoCloudActivityStreamService alloc] initWithSession:session];
    }
    return nil;
}

@end