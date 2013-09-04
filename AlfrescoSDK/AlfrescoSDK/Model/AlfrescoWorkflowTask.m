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

/** The AlfrescoWorkflowTask model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import "AlfrescoWorkflowTask.h"
#import "AlfrescoSession.h"
#import "AlfrescoInternalConstants.h"

@interface AlfrescoWorkflowTask ()

@property (nonatomic, weak, readwrite) id<AlfrescoSession> session;
@property (nonatomic, strong, readwrite) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) NSString *identifier;
@property (nonatomic, strong, readwrite) NSString *processIdentifier;
@property (nonatomic, strong, readwrite) NSString *processDefinitionIdentifier;
@property (nonatomic, strong, readwrite) NSDate *startedAt;
@property (nonatomic, strong, readwrite) NSDate *endedAt;
@property (nonatomic, strong, readwrite) NSDate *dueAt;
@property (nonatomic, strong, readwrite) NSString *taskDescription;
@property (nonatomic, strong, readwrite) NSNumber *priority;
@property (nonatomic, strong, readwrite) NSString *assigneeIdentifier;

@end

@implementation AlfrescoWorkflowTask

- (id)initWithProperties:(NSDictionary *)properties session:(id<AlfrescoSession>)session
{
    self = [super init];
    if (self)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:kAlfrescoISO8601DateStringFormat];
        self.session = session;
        [self setupProperties:properties];
    }
    return self;
}

- (void)setupProperties:(NSDictionary *)properties
{
    if (self.session.workflowInfo.publicAPI)
    {
        NSDictionary *entry = [properties objectForKey:kAlfrescoCloudJSONEntry];
        self.identifier = [entry objectForKey:kAlfrescoJSONIdentifier];
        self.processIdentifier = [entry objectForKey:kAlfrescoPublicJSONProcessID];
        self.processDefinitionIdentifier = [entry objectForKey:kAlfrescoPublicJSONProcessDefinitionID];
        self.startedAt = [entry objectForKey:kAlfrescoPublicJSONStartedAt];
        self.endedAt = [entry objectForKey:kAlfrescoPublicJSONEndedAt];
        self.dueAt = [entry objectForKey:kAlfrescoPublicJSONDueAt];
        self.taskDescription = [entry objectForKey:kAlfrescoPublicJSONDescription];
        self.priority = [entry objectForKey:kAlfrescoPublicJSONPriority];
        self.assigneeIdentifier = [entry objectForKey:kAlfrescoPublicJSONAssignee];
    }
    else
    {
        NSDictionary *taskProperties = [properties objectForKey:kAlfrescoOldJSONProperties];
        NSDictionary *workflowInstance = [properties objectForKey:kAlfrescoOldJSONWorkflowInstance];
        
        NSString *workflowEnginePrefix = [AlfrescoWorkflowUtils prefixForActivitiEngineType:self.session.workflowInfo.workflowEngine];
        self.identifier = [taskProperties objectForKey:kAlfrescoOldBPMJSONID];
        self.processIdentifier = [[workflowInstance objectForKey:kAlfrescoOldJSONIdentifier] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.processDefinitionIdentifier = [[workflowInstance objectForKey:kAlfrescoOldJSONName] stringByReplacingOccurrencesOfString:workflowEnginePrefix withString:@""];
        self.startedAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoOldBPMJSONStartedAt]];
        if ([taskProperties objectForKey:kAlfrescoOldBPMJSONEndedAt] != [NSNull null])
        {
            self.endedAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoOldBPMJSONEndedAt]];
        }
        if ([taskProperties objectForKey:kAlfrescoOldBPMJSONDueAt] != [NSNull null])
        {
            self.dueAt = [self.dateFormatter dateFromString:[taskProperties objectForKey:kAlfrescoOldBPMJSONDueAt]];
        }
        self.taskDescription = [taskProperties objectForKey:kAlfrescoOldBPMJSONDescription];
        self.priority = [taskProperties objectForKey:kAlfrescoOldBPMJSONPriority];
        if ([taskProperties objectForKey:kAlfrescoOldJSONOwner] != [NSNull null])
        {
            self.assigneeIdentifier = [taskProperties objectForKey:kAlfrescoOldJSONOwner];
        }
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // TODO
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // TODO
    return self;
}

@end