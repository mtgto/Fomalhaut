//
//  RoutingConnection+Secure.m
//  FomalhautOSX
//
//  Created by User on 1/10/14.
//  Copyright (c) 2014 mtgto. All rights reserved.
//

#import "RoutingConnection+Secure.h"
#import <CocoaHTTPServer/HTTPLogging.h>

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN;

extern NSString *const SERVER_BOOL_HTTPS_CONFIG_KEY;

@implementation RoutingConnection (Secure)

/**
 * Returns whether or not the server is configured to be a secure server.
 * In other words, all connections to this server are immediately secured, thus only secure connections are allowed.
 * This is the equivalent of having an https server, where it is assumed that all connections must be secure.
 * If this is the case, then unsecure connections will not be allowed on this server, and a separate unsecure server
 * would need to be run on a separate port in order to support unsecure connections.
 *
 * Note: In order to support secure connections, the sslIdentityAndCertificates method must be implemented.
 **/
- (BOOL)isSecureServer
{
	HTTPLogTrace();

	// Override me to create an https server...
    return [[NSUserDefaults standardUserDefaults] boolForKey:SERVER_BOOL_HTTPS_CONFIG_KEY];
}

/**
 * This method is expected to returns an array appropriate for use in kCFStreamSSLCertificates SSL Settings.
 * It should be an array of SecCertificateRefs except for the first element in the array, which is a SecIdentityRef.
 **/
- (NSArray *)sslIdentityAndCertificates
{
	HTTPLogTrace();

	// Override me to provide the proper required SSL identity.

	SecIdentityRef identityRef = NULL;
    SecCertificateRef certificateRef = NULL;
    SecTrustRef trustRef = NULL;

    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"https" ofType:@"p12"];
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
    CFStringRef password = CFSTR("test123");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);

    OSStatus securityError = errSecSuccess;
    securityError =  SecPKCS12Import(inPKCS12Data, optionsDictionary, &items);
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        identityRef = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        trustRef = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failed with error code %d",(int)securityError);
        return nil;
    }

    SecIdentityCopyCertificate(identityRef, &certificateRef);
    NSArray *result = [[NSArray alloc] initWithObjects:(__bridge id)identityRef, (__bridge id)certificateRef, nil];
    
    return result;
}

@end
