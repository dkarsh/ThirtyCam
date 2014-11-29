/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#include "Constants.h"

@class AWSCognitoCredentialsProvider;
@class AWSCognito;
@class BFTask;

typedef void (^LoginHandler)(NSError *error);

#if GOOGLE_LOGIN
#if AMZN_LOGIN
// Amazon and Google
@interface AmazonClientManager:NSObject<UIActionSheetDelegate,GPPSignInDelegate,AIAuthenticationDelegate> {}
#else
// Just Google
@interface AmazonClientManager:NSObject<UIActionSheetDelegate,GPPSignInDelegate> {}
#endif
#elif AMZN_LOGIN
// Just Amazon
@interface AmazonClientManager:NSObject<UIActionSheetDelegate,AIAuthenticationDelegate> {}
#else
// Neither Amazon nor Google
@interface AmazonClientManager:NSObject<UIActionSheetDelegate> {}
#endif

- (BOOL)isLoggedIn;
- (void)logoutWithCompletionHandler:(LoginHandler)completionHandler;
- (void)loginFromView:(UIView *)theView withCompletionHandler:(LoginHandler)completionHandler;

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)resumeSessionWithCompletionHandler:(LoginHandler)completionHandler;

+ (AmazonClientManager *)sharedInstance;

@property (nonatomic, strong) AWSCognitoCredentialsProvider *provider;

@end

