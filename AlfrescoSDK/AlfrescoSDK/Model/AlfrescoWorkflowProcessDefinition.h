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

/** The AlfrescoWorkflowProcessDefinition model object
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>

@interface AlfrescoWorkflowProcessDefinition : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSString *category;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *startFormKey;
@property (nonatomic, strong, readonly) NSString *depolymentIdentifier;
@property (nonatomic, assign, readonly) BOOL graphicNotationDefined;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) NSNumber *version;

- (id)initWithProperties:(NSDictionary *)properties;

@end