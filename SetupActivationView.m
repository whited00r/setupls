#import "SetupActivationView.h"
#import "SetupLS.h"
#import <sys/sysctl.h>
#import <Foundation/NSTask.h>
/*
To-Do: 
6/5/2016
-Seperate key to keep on server for activating beta licenses. If the device has a key valid for that, then give them a shortened lifespan beta key to activate with from the activation page, not a cleaner one.
- Gosh this is so slow to register my typing bloody hell

??/??/????
-URL for activation+statistics, and also a URL with just statistics updates if they have a license on-device. 
-Send public-key encrypted request to verify it hopefully came from this device... To avoid brute-force activations.
-Down the line, tie this in with the installer activaiton keys it uses (generate 100k or so at a time, could do it on a local computer to avoid server side issues)
-Limit installer activation key to be used with 5 devices at a time. This avoids brute forcing down the line when activing.


*/





/*
For getting the system hardware name thing.


 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */


 static SetupActivationView *selfReference; //Uhmmm... Bad idea?
@interface UIDevice (Hardware)
- (NSString *) getSysInfoByName:(char *)typeSpecifier;
- (NSString *) platform;
- (NSString *) hwmodel;

@end


@implementation UIDevice (Hardware)
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *) hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}



@end

/*
- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }

    return output;
}
*/



static inline BOOL isSlothAlive(){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//Go from NSString to NSData
NSData *udidData = [[NSString stringWithFormat:@"%@-%@-%c%c%c%@-%@%c%c%@%@%c",[[UIDevice currentDevice] uniqueIdentifier],@"I",'l','i','k',@"e",@"s",'l','o',@"t",@"h",'s'] dataUsingEncoding:NSUTF8StringEncoding];
uint8_t digest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1(udidData.bytes, udidData.length, digest);
NSMutableString *hashedUDID = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
//To NSMutableString to calculate hash

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [hashedUDID appendFormat:@"%02x", digest[i]];
    }

//Then back to NSData for use in verification. -__-. I probably could skip a couple steps here...
NSData *hashedUDIDData = [hashedUDID dataUsingEncoding:NSUTF8StringEncoding];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.activationKey"];

//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIDJzCCAg+gAwIBAgIJAPyR9ASSBbF9MA0GCSqGSIb3DQEBCwUAMCoxETAPBgNV",
@"BAoMCEdyYXlkMDByMRUwEwYDVQQDDAxncmF5ZDAwci5jb20wHhcNMTUxMDI4MDEy",
@"MjQyWhcNMjUxMDI1MDEyMjQyWjAqMREwDwYDVQQKDAhHcmF5ZDAwcjEVMBMGA1UE",
@"AwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA",
@"94OZ2u2gJfdWgqWKV7yDY5pJXLZuRho6RO2OJtK04Xg3gUk46GBkYLo+/Z33rOvs",
@"XA041oAINRmdaiTDRa5VbGitQMYfObMz8m0lHQeb4/wwOasRMgAT2WCcKVulwpCG",
@"C7PiotF3F85VAuqJsbu1gxjJaQGIgR2L35LTR/fQq3N5+2+bsc0wUbPcLk7uhyYJ",
@"tna+CYRc+3qGRsv/t8MYF0T7LU2xwCcGV0phmr3er5ocAj9X57i92zYGMPlz8kMZ",
@"HfXqMova0prF9vuN7mo54kY+SF2rp/G/v+u5MicONpXwY6adJ0eIuXFjqsUjKTi6",
@"4Bjzhvf+Z6O5TARJzdVMqwIDAQABo1AwTjAdBgNVHQ4EFgQUDBxB98iHJnBsonVM",
@"LHF5WVXvhqgwHwYDVR0jBBgwFoAUDBxB98iHJnBsonVMLHF5WVXvhqgwDAYDVR0T",
@"BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEA4tyP/hMMJBYVFhRmdjAj9wnCr31N",
@"7tmyksLR76gqfLJL3obPDW+PIFPjdhBWNjcjNuw/qmWUXcEkqu5q9w9uMs5Nw0Z/",
@"prTbIIW861cZVck5dBlTkzQXySqgPwirXUKP/l/KrUYYV++tzLJb/ete2HHYwAyA",
@"2kl72gIxdqcXsChdO5sVB+Fsy5vZ2pw9Qan6TGkSIDuizTLIvbFuWw53MCBibdDn",
@"Y+CY2JrcX0/YYs4BSk5P6w/VInU5pn6afYew4XO7jRrGyIIPRJyR3faULqOLkenG",
@"Z+VNoXdO4+FShkEEfHb+Y8ie7E+bB0GBPb9toH/iH4cVS8ddaV3KiLkkJg=="]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(hashedUDIDData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([hashedUDIDData bytes], [hashedUDIDData length], sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1, sha1HashDigest, CC_SHA1_DIGEST_LENGTH, [signatureData bytes], [signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];

if (verficationResult == errSecSuccess){

	return TRUE;
}
else{
	return FALSE;
}



}
[pool drain];
return false;
}



static inline BOOL isSlothSleeping(){
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSData* fileData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist"];
NSData* signatureData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist.sig"];
//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIC6jCCAdICCQC2Zs0BWO+dxzANBgkqhkiG9w0BAQsFADA3MQswCQYDVQQGEwJV",
@"UzERMA8GA1UECgwIR3JheWQwMHIxFTATBgNVBAMMDGdyYXlkMDByLmNvbTAeFw0x",
@"NTEwMjQyMzEzNTNaFw0yMTA0MTUyMzEzNTNaMDcxCzAJBgNVBAYTAlVTMREwDwYD",
@"VQQKDAhHcmF5ZDAwcjEVMBMGA1UEAwwMZ3JheWQwMHIuY29tMIIBIjANBgkqhkiG",
@"9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsWSkvU26FQlb/IOE/QWKSyt3L5ekj+uvdVQq",
@"Eljo35THov9qKSqTMhdgMGkWDCVnqHsgf0+LjHZcFfz+cI1++1bsHCxvhJvytvYx",
@"uRQmjh0+yAA28729dDCKhawQ5YLHbVC+4tHoyHhvK+Ww0mx+g7Y8bVh+qc1EBf6h",
@"VOrspUvoGHLQYAa15Wbca8mmXVpxuZVfviLskqffKtsPVe7EIx8WwzrI+v9GOXNi",
@"dR/rBJDU91u1AQc5BT9zAOFlLZq4VJLdNNWCs4w58f6260xDiUjMEAKzILhSjmN/",
@"Dys9McYE9Iu3lGPvFn2HCfOOgTg1sv3Hz/mogL5sbjvCCtQnrwIDAQABMA0GCSqG",
@"SIb3DQEBCwUAA4IBAQBLQ+66GOyKY4Bxn9ODiVf+263iLTyThhppHMRguIukRieK",
@"sVvngMd6BQU4N4b0T+RdkZGScpAe3fdre/Ty9KIt/9E0Xqak+Cv+x7xCzEbee8W+",
@"sAV+DViZVes67XXV65zNdl5Nf7rqGqPSBLwuwB/M2mwmDREMJC90VRJBFj4QK14k",
@"FuwtTpNW44NUSQRUIxiZM/iSwy9rqekRRAKWo1s5BOLM3o7ph002BDyFPYmK5UAN",
@"EM/aKFGVMMwhAUHjgej5iEPxPuks+lGY1cKUAgoxbvXJakybosgmDFfSN+DMT7ZU",
@"HbUgWDsLySwU8/+C4vDP0pmMqJFgrna9Wto49JNz"]];//[NSData dataWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer"];  

//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);

if(fileData && signatureData && certificateData){


SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates( certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);


//ONLY iOS6+ supports SHA256! >:(
uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
CC_SHA1([fileData bytes], [fileData length], sha1HashDigest);

OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1, sha1HashDigest, CC_SHA1_DIGEST_LENGTH, [signatureData bytes], [signatureData length]);
CFRelease(publicKey);
CFRelease(trust);
CFRelease(secPolicy);
CFRelease(certificateFromFile);
[pool drain];
if (verficationResult == errSecSuccess){
	return TRUE;
}
else{
	return FALSE;
}



}
[pool drain];
return false;
}



static inline float installerVersion(){
  if(isSlothSleeping()){
      NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.installerInfo.plist"];
      if([dict objectForKey:@"installerVersion"]){
        float installerVer = [[dict objectForKey:@"installerVersion"] floatValue];
        [dict release];
          return installerVer;
      }
  }
  return 0.0f;
}

/*

+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
	NSData *data = [RSA encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
	NSString *ret = base64_encode_data(data);
	return ret;
}

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
	if(!data || !pubKey){
		return nil;
	}
	SecKeyRef keyRef = [RSA addPublicKey:pubKey];
	if(!keyRef){
		return nil;
	}
	
	const uint8_t *srcbuf = (const uint8_t *)[data bytes];
	size_t srclen = (size_t)data.length;
	
	size_t outlen = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
	if(srclen > outlen - 11){
		CFRelease(keyRef);
		return nil;
	}
	void *outbuf = malloc(outlen);
	
	OSStatus status = noErr;
	status = SecKeyEncrypt(keyRef,
						   kSecPaddingPKCS1,
						   srcbuf,
						   srclen,
						   outbuf,
						   &outlen
						   );
	NSData *ret = nil;
	if (status != 0) {
		//NSLog(@"SecKeyEncrypt fail. Error Code: %ld", status);
	}else{
		ret = [NSData dataWithBytes:outbuf length:outlen];
	}
	free(outbuf);
	CFRelease(keyRef);
	return ret;
}
*/

@interface NSString (Base64Encode)
+ (NSString*)base64forData:(NSData*)theData;
@end

@implementation NSString (Base64Encode)
/*
+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];

    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}
*/

+(NSString *)base64forData:(NSData *)data{

    //Point to start of the data and set buffer sizes
    int inLength = [data length];
    int outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    const char *inputBuffer = [data bytes];
    char *outputBuffer = malloc(outLength+1);
    outputBuffer[outLength] = 0;

    //64 digit code
    static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"; //Do my base64 differently perhaps?

    //Start the count
    int cycle = 0;
    int inpos = 0;
    int outpos = 0;
    char temp;

    //Pad the last to bytes, the outbuffer must always be a multiple of 4.
    outputBuffer[outLength-1] = '~';
    outputBuffer[outLength-2] = '~';

    /* http://en.wikipedia.org/wiki/Base64

        Text content     M         a         n
        ASCII            77        97        110
        8 Bit pattern    01001101  01100001  01101110

        6 Bit pattern    010011    010110    000101    101110
        Index            19        22        5         46
        Base64-encoded   T         W         F         u
    */

    while (inpos < inLength){
        switch (cycle) {

            case 0:
                outputBuffer[outpos++] = Encode[(inputBuffer[inpos] & 0xFC) >> 2];
                cycle = 1;
                break;

            case 1:
                temp = (inputBuffer[inpos++] & 0x03) << 4;
                outputBuffer[outpos] = Encode[temp];
                cycle = 2;
                break;

            case 2:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0) >> 4];
                temp = (inputBuffer[inpos++] & 0x0F) << 2;
                outputBuffer[outpos] = Encode[temp];
                cycle = 3;
                break;

            case 3:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0) >> 6];
                cycle = 4;
                break;

            case 4:
                outputBuffer[outpos++] = Encode[inputBuffer[inpos++] & 0x3f];
                cycle = 0;
                break;

            default:
                cycle = 0;
                break;
        }
    }
    NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer);
    return pictemp;
}


@end



static inline void activateDevice(NSString *b64){
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
    NSError* error = nil;
NSURLResponse *urlResponse = nil;
NSString *myRequestString = [NSString stringWithFormat:@"blob=%@", b64];

// Create Data from request
NSData *myRequestData = [NSData dataWithBytes: [myRequestString UTF8String] length: [myRequestString length]];
NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: @"http://ota.grayd00r.com/activation.php"]];
// set Request Type
[request setHTTPMethod: @"POST"];
// Set content-type
[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
// Set Request Body
[request setHTTPBody: myRequestData];
//request.timeoutInterval = 120;
//[request setTimeOutSeconds:120]; // two minutes for a response?
// Now send a request and get Response
NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&urlResponse error:&error];
// Log Response
if(!returnData || returnData == nil || returnData == NULL || error){
	//NSLog(@"ERROR: Likely unable to contact activation server!");
    //NSLog(@"Unable to get response from activation server %@", [error localizedDescription]);
	dispatch_async(dispatch_get_main_queue(), ^{
   		[selfReference unableToReachServer];
	});
	return;
}
NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];

//NSLog(@"Server response is %@", response);



NSDictionary *responsePlist = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
if(!responsePlist){
	//NSLog(@"ERROR: Invalid response data from the activation server! : %@", response);
	dispatch_async(dispatch_get_main_queue(), ^{
   			[selfReference badResponseFromServer];
	});
	return;
}
	/*
 	NSError *plistError;
 	NSPropertyListFormat format;
    id plist = [NSPropertyListSerialization propertyListWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSPropertyListImmutable format:&format error:&plistError];
	if (plist == nil)
	{
    	NSLog(@"ERROR: Invalid reponse data from activation server! : %@", plistError);
       
    	
    	return;
	}
	*/
//NSLog(@"Response plist is %@", responsePlist);


if([[responsePlist objectForKey:@"statusType"] isEqual:@"error"]){ //Oh crap something went wrong call Sting. 
	dispatch_async(dispatch_get_main_queue(), ^{
   		[selfReference handleError:responsePlist];
	});

	return;
}



if([[responsePlist objectForKey:@"statusType"] isEqual:@"success"]){ //Oh crap something went wrong call Sting. 
	if([[responsePlist objectForKey:@"statusCode"] isEqual:@"licenseKey"]){
	if([responsePlist objectForKey:@"license"]){
		NSData *license = [NSData dataFromBase64String:[[[responsePlist objectForKey:@"license"] stringByReplacingOccurrencesOfString:@"-" withString:@"+"] stringByReplacingOccurrencesOfString:@"_" withString:@"/"]];
		if(![license writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Greyd00r/ActivationKeys/com.greyd00r.activationKey"] atomically:YES]){
            dispatch_async(dispatch_get_main_queue(), ^{
                //NSLog(@"Activation passed");
                [selfReference badPermissions];
            });
            return;
        }
        //NSLog(@"License is now %@", license);
		if(isSlothAlive()){
			dispatch_async(dispatch_get_main_queue(), ^{
				//NSLog(@"Activation passed");
	   			[selfReference activationPassed];
			});
			return;
		}
		else{
			dispatch_async(dispatch_get_main_queue(), ^{
				//NSLog(@"Acitvation failed");
	   			[selfReference activationFailed];
			});
			return;
		}
	}
}

	dispatch_async(dispatch_get_main_queue(), ^{
		//NSLog(@"Got success message?");
   		[selfReference handleSuccess:responsePlist];
	});

	return;
}
else{
	NSLog(@"Response type unhandled? O.o");
}

    /*
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.17/~grayd00r/greyd00rActivation/activate.php?blob=%@", b64]] options:NSDataReadingUncached error:&error];
 	
    if (error) {
        NSLog(@"%@", [error localizedDescription]); //device not connected to wifi, usually...
    } else {
        NSLog(@"Data has loaded successfully."); //data returned with your response from server, this is where you will be checking the return value
    }
    */
});

}


static inline BOOL tellServerHello(){


if(!isSlothSleeping()){
	//NSLog(@"Activation: Unable to activate because this isn't a valid installer!");
	
   	[selfReference installerCheckFailed];
	
	return false;
}

NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//Okay, this is technically not good to do, but it's even worse if I just include the bloody certificate on the device by default because then it just gets replaced easier. Same for keeping it in the keychain perhaps because it isn't sandboxed? Hide it in the binary they said, it will be safer, they said.
NSData* certificateData = [NSData dataFromBase64String:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"MIIDQTCCAimgAwIBAgIJAKcRGcsiORYsMA0GCSqGSIb3DQEBCwUAMDcxCzAJBgNV",
@"BAYTAkFVMREwDwYDVQQKDAhHcmF5ZDAwcjEVMBMGA1UEAwwMZ3JheWQwMHIuY29t",
@"MB4XDTE1MTAyODAxMTcxOFoXDTI1MTAyNTAxMTcxOFowNzELMAkGA1UEBhMCQVUx",
@"ETAPBgNVBAoMCEdyYXlkMDByMRUwEwYDVQQDDAxncmF5ZDAwci5jb20wggEiMA0G",
@"CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCouifjxs4KgEAhNqNxcaJ2vji5PuCS",
@"ijWuliWUravi9UpuGSPfdXYXJgrHj0ViV5sbGTI/pTGmd08CZNZ5SGKjnkOJhL1B",
@"95vSQVLwcNLeoZUd+HIQZ/xwoNi8DodtraT7M83YLL8FyRGF+P/m433N2y6nTHI4",
@"7tbzlnX4oZPjL1h/5L/TEbIRknoS1jjrLaeQmbIf+aLILEXAEEvbvRbn9aabrjuM",
@"JxhlA0trj3kMju1fou+At7Cjm2J+4yjDIaKhv6mXm/0fwIxwfzmpmFBOfShlrLCZ",
@"e2Wfig4HE+oSEJIbzciogVFCzBdGzJE34m08UCiKOQpxxXZMRNfkknb3AgMBAAGj",
@"UDBOMB0GA1UdDgQWBBSXzVleoW6dUhlapk8hg5v0GWvCCTAfBgNVHSMEGDAWgBSX",
@"zVleoW6dUhlapk8hg5v0GWvCCTAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUA",
@"A4IBAQB8/D7qLpRJK6jAHw01TIyBKCW6FrQFPErTC/+2dEz6SxYkdbvfc3DNr6EC",
@"DUjw35pKUsb4JEs0ICP25gy83Ah2tsd4jE0irYqUQtktHE9JEBcGfh/xolOlEgci",
@"zKP/BFMFs0qHeV++Ff0dfz2XP3xSuhg4VesAQFQ0ekOgUdIO3jIQ+OdsNlERvwdR",
@"djKyI8SbBlI+lmpA46gMmjrw4QRSVcUPfTRzJm33p8B/oaOj8r3e0BJunB+sHrS8",
@"n5DfRdo7YqWEEWB/XeO5LxhItkiDpNWwiuMumA9aVESMkr7WdBC5DQuq9Bw6ETB0",
@"QTs9akJOotRY7LfZfqKYxLQX2iPh"]];
//SecCertificateRef certRef = SecCertificateFromPath(@"/var/mobile/Library/Greyd00r/ActivationKeys/certificate.cer");
//SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certRef);



//SecKeyRef publicKey = SecKeyFromCertificate(certRef);

//recoverFromTrustFailure(publicKey);


NSFileManager *fileManager= [NSFileManager defaultManager];
		NSDictionary *otaDict = nil;
		if([fileManager fileExistsAtPath:@"/var/mobile/Library/Mercury/com.greyd00r.plist"]){
			otaDict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Mercury/com.greyd00r.plist"];
		}

		NSString *otaGroup = @"N/A";
		NSString *installedGDVersion = @"N/A";
		if(otaDict){
			if([otaDict objectForKey:@"sourceURL"]){
				NSString *updateURL = [otaDict objectForKey:@"sourceURL"];
				otaGroup = [updateURL stringByReplacingOccurrencesOfString:@"http://ota.grayd00r.com/" withString:@""];
			}
			if([otaDict objectForKey:@"version"]){
				installedGDVersion = [[otaDict objectForKey:@"version"] copy];
			}
		}
		[otaDict release];


		if(otaGroup == @"N/A"){ //No OTA group set, how did they even do that? Oh well. Error check it anyway.
			//NSLog(@"Activation: Unable to find OTA group set");
			[selfReference noOTAGroupSet];
			[pool drain];
			return false;
		}

	//What have I created. Memory leak? Maybe.
    NSData *udidData = [[NSString stringWithFormat:@"%@-%@-%c%c%c%@-%@%c%c%@%@%c",[[UIDevice currentDevice] uniqueIdentifier],@"I",'l','i','k',@"e",@"s",'l','o',@"t",@"h",'s'] dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(udidData.bytes, udidData.length, digest);

    NSMutableString *hashedUDID = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [hashedUDID appendFormat:@"%02x", digest[i]];
    }


    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef randomUUID = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);

//Maybe split into two parts for activation? so upload two base64 encoded encrypted json objects in one URL. 
//http://activation.grayd00r.com/activate.php?firstbase64json&secondbase64json 
//then have a token in each of them that ties them together?

NSMutableDictionary *helloDict = [[NSMutableDictionary alloc] init];
//[helloDict setObject:@"Hi." forKey:@"Test"];
[helloDict setObject:[[UIDevice currentDevice] hwmodel] forKey:@"hwID"];
[helloDict setObject:[[UIDevice currentDevice] platform] forKey:@"hwm"];
[helloDict setObject:[NSString stringWithFormat:@"%f",installerVersion()] forKey:@"iVersion"];
[helloDict setObject:otaGroup forKey:@"ota"];
[helloDict setObject:installedGDVersion forKey:@"gv"];
[helloDict setObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"locale"];
[helloDict setObject:[[UIDevice currentDevice] systemVersion] forKey:@"iOS"];
[helloDict setObject:hashedUDID forKey:@"udid"]; //Not actually the udid silly.
//TODO: set secret key that is hash of udid + secret key that server knows. Cheap, dirty, and probably eaasily cracked.
//[helloDict setObject:randomUUID forKey:@"nonce"];

if(!isSlothAlive()){ //See if we already have a license. If we do, we don't need to request it from the server.
	[helloDict setObject:@"activation" forKey:@"type"];
}
else{
	[helloDict setObject:@"statUpdate" forKey:@"type"];
}

//[helloDict setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];




NSError *error;
NSData *helloJSON = [NSJSONSerialization dataWithJSONObject:helloDict options:NSJSONWritingPrettyPrinted error:&error];

NSString *helloString = [[NSString alloc] initWithData:helloJSON encoding:NSUTF8StringEncoding];



NSData *dataToEncrypt = [helloString dataUsingEncoding:NSUTF8StringEncoding]; //Is this too many steps? Probably.... :()
//activateDevice([dataToEncrypt base64EncodedString]); //Uncomment to pass through straight to server
//NSLog(@"HelloString is: %@", helloString);

SecCertificateRef certificateFromFile = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData); // load the certificate

SecPolicyRef secPolicy = SecPolicyCreateBasicX509();

SecTrustRef trust;
OSStatus statusTrust = SecTrustCreateWithCertificates(certificateFromFile, secPolicy, &trust);
SecTrustResultType resultType;
OSStatus statusTrustEval =  SecTrustEvaluate(trust, &resultType);
SecKeyRef publicKey = SecTrustCopyPublicKey(trust);
size_t maxPlainLen = SecKeyGetBlockSize(publicKey) - 12;

size_t plainLen = [dataToEncrypt length];
    if (plainLen > maxPlainLen) {
       //NSLog(@"content(%ld) is too long, must < %ld", plainLen, maxPlainLen);
        [selfReference errorMakingMessageForServer];
        return FALSE;
    }
   //NSLog(@"Content is %ld and it has to be %ld", plainLen, maxPlainLen);

    void *plain = malloc(plainLen);
    [dataToEncrypt getBytes:plain
               length:plainLen];

    size_t cipherLen = SecKeyGetBlockSize(publicKey); // currently RSA key length is set to 128 bytes. Hope this bloody fixes it.
    void *cipher = malloc(cipherLen+1);

    OSStatus returnCode = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plain,
                                        plainLen, cipher, &cipherLen);

    NSData *result = nil;
    if (returnCode != 0 && returnCode !=-50) {
        //NSLog(@"SecKeyEncrypt fail. Error Code: %ld", returnCode);
        [selfReference errorMakingMessageForServer];
        return FALSE;
    }
    else {
        result = [NSData dataWithBytes:cipher
                                length:cipherLen];
    }

    free(plain);
    free(cipher);

    //NSLog(@"New dataString: %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
	//CFRelease(keyRef);
    //NSLog(@"Result is %ld, %@ --- %@ ---- %@", returnCode, result, [NSString base64forData:result], [result base64EncodedString]);
    //activateDevice([NSString base64forData:result]);
    
    activateDevice([NSString base64forData:result]);
//ONLY iOS6+ supports SHA256! >:(
//uint8_t sha1HashDigest[CC_SHA1_DIGEST_LENGTH];
//CC_SHA1([fileData bytes], [fileData length], sha1HashDigest);

//OSStatus verficationResult = SecKeyRawVerify(publicKey,  kSecPaddingPKCS1SHA1, sha1HashDigest, CC_SHA1_DIGEST_LENGTH, [signatureData bytes], [signatureData length]);

//CFRelease(publicKey);
//CFRelease(trust);
//CFRelease(secPolicy);
//CFRelease(certificateFromFile);
//if (verficationResult == errSecSuccess) return TRUE;
[pool drain];
return TRUE;
}





@implementation SetupActivationView
-(id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if(self){
		shouldRespring = FALSE;
        activated = FALSE;

NSBundle *b = 
  [NSBundle bundleWithPath:
      @"/System/Library/PrivateFrameworks/SoftwareUpdateServices.framework"];

if ( [b load] )
{
  // load Class from STRING
  Class NetworkMonitor = NSClassFromString(@"SUNetworkMonitor");
  id *_NetPointer;
  // alloc class
  if ( !_NetPointer ) _NetPointer = [[NetworkMonitor alloc] init];

  // check if the class have the method currentNetworkType
  if ( [_NetPointer respondsToSelector:@selector(currentNetworkType)] )
  {
    int t = (int)[_NetPointer performSelector:@selector(currentNetworkType)];

    NSString *type = @"";
    switch ( t ) {
      case 0:  type = @"NO-DATA"; isOffline = TRUE; break;
      case 1:  type = @"WIFI"; isOffline = FALSE; break;
      case 2:  type = @"GPRS/EDGE"; isOffline = TRUE; break;
      case 3:  type = @"3G"; isOffline = TRUE; break;
      default: type = @"OTHERS"; isOffline = TRUE; break;
    }

    NSLog(@"-Network type: %@", type);
  }
}

		NSFileManager *fileManager= [NSFileManager defaultManager];
		NSDictionary *otaDict = nil;
		if([fileManager fileExistsAtPath:@"/var/mobile/Library/Mercury/com.greyd00r.plist"]){
			otaDict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Mercury/com.greyd00r.plist"];
		}

		NSString *otaGroup = @"N/A";
		if(otaDict){
			if([otaDict objectForKey:@"sourceURL"]){
				NSString *updateURL = [otaDict objectForKey:@"sourceURL"];
				otaGroup = [updateURL stringByReplacingOccurrencesOfString:@"http://ota.grayd00r.com/" withString:@""];
			}
		}
		[otaDict release];


		activationStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 160,frame.size.height / 2 - 80, 320, 40)];
		activationStatusLabel.textAlignment = UITextAlignmentCenter;
		[activationStatusLabel setFont:[UIFont fontWithName:@"Courier" size:24]];
		activationStatusLabel.textColor = [UIColor blackColor];
		activationStatusLabel.backgroundColor = [UIColor clearColor];
		activationStatusLabel.alpha = 0.0;
		activationStatusLabel.text = NSLocalizedBundleString(@"ACTIVATE_VERIFYING_INSTALLER", nil);
		[self addSubview:activationStatusLabel];


		rebootBody = [[UITextView alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 160, activationStatusLabel.frame.origin.y + activationStatusLabel.frame.size.height, 320, 0)];
	    rebootBody.backgroundColor = [UIColor clearColor];
	    rebootBody.textColor = [UIColor blackColor];
	    rebootBody.font = [UIFont fontWithName:@"Helvetica" size:16];
	    rebootBody.userInteractionEnabled = FALSE;
	    rebootBody.alpha = 0.0;
	    rebootBody.textAlignment = UITextAlignmentCenter;
	    rebootBody.text = NSLocalizedBundleString(@"ACTIVATE_REBOOT_BODY", nil);
	    rebootBody.editable = FALSE;
	    [self addSubview:rebootBody];
	    //NOTE: Can only access the contentSize *after* it has been added to a view it seems.
	    rebootBody.frame = CGRectMake((frame.size.width / 2) - 160, activationStatusLabel.frame.origin.y + activationStatusLabel.frame.size.height, 320, rebootBody.contentSize.height);


		activateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 160,20, 320, 40)];
		activateTitleLabel.textAlignment = UITextAlignmentCenter;
		[activateTitleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:24]];
		activateTitleLabel.textColor = [UIColor blackColor];
		activateTitleLabel.backgroundColor = [UIColor clearColor];
		activateTitleLabel.text = NSLocalizedBundleString(@"ACTIVATE_HEADER", nil);
		[self addSubview:activateTitleLabel];
		//[aboutHeader release];

		activateScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((frame.size.width / 2) - 160, activateTitleLabel.frame.origin.y + 40, 320, 300)];
		activateScrollView.backgroundColor = [UIColor whiteColor];
		[self addSubview:activateScrollView];

	    activateBody = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, activateScrollView.frame.size.width, 0)];
	    activateBody.backgroundColor = [UIColor clearColor];
	    activateBody.textColor = [UIColor blackColor];
	    activateBody.font = [UIFont fontWithName:@"Helvetica" size:16];
	    activateBody.userInteractionEnabled = TRUE;
	    activateBody.textAlignment = UITextAlignmentCenter;
	   // NSLog(@"%@, %@, %@", [[UIDevice currentDevice] hwmodel], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]);
	   // NSLog(@"ActivateBodyString %@", activateBodyString);
	    activateBody.text = NSLocalizedBundleString(@"ACTIVATE_BODY", nil);
	    activateBody.editable = FALSE;
	    [activateScrollView addSubview:activateBody];
	    //NOTE: Can only access the contentSize *after* it has been added to a view it seems.
	    activateBody.frame = CGRectMake(0, 0, activateScrollView.frame.size.width, activateBody.contentSize.height);

	    activateData = [[UITextView alloc] initWithFrame:CGRectMake(0, activateBody.frame.origin.y + activateBody.frame.size.height + 10, activateScrollView.frame.size.width, 0)];
	    activateData.backgroundColor = [UIColor clearColor];
	    activateData.textColor = [UIColor blackColor];
	    activateData.font = [UIFont fontWithName:@"Courier" size:14];
	    activateData.userInteractionEnabled = TRUE;
	    activateData.textAlignment = UITextAlignmentLeft;
	   // NSLog(@"%@, %@, %@", [[UIDevice currentDevice] hwmodel], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion]);
	    NSString *activateDataString = NSLocalizedBundleString(@"ACTIVATE_DATA", nil);
	   // NSLog(@"ActivateBodyString %@", activateBodyString);
	    activateData.text = [NSString stringWithFormat:activateDataString, [[UIDevice currentDevice] hwmodel], [[UIDevice currentDevice] model],installerVersion(),otaGroup,[[NSLocale preferredLanguages] objectAtIndex:0],[[UIDevice currentDevice] systemVersion]];
	    
	    activateData.editable = FALSE;
	    [activateScrollView addSubview:activateData];
	    //NOTE: Can only access the contentSize *after* it has been added to a view it seems.
	    activateData.frame = CGRectMake(0, activateBody.frame.origin.y + activateBody.frame.size.height + 10, activateScrollView.frame.size.width, activateData.contentSize.height);


	    activateNotes = [[UITextView alloc] initWithFrame:CGRectMake(0, activateData.frame.origin.y + activateData.frame.size.height + 10, activateScrollView.frame.size.width, 0)];
	    activateNotes.backgroundColor = [UIColor clearColor];
	    activateNotes.textColor = [UIColor blackColor];
	    activateNotes.font = [UIFont fontWithName:@"Arial-ItalicMT" size:12];
	    activateNotes.userInteractionEnabled = TRUE;
	    activateNotes.textAlignment = UITextAlignmentLeft;
	    activateNotes.text = NSLocalizedBundleString(@"ACTIVATE_NOTES", nil);

	    
	    activateNotes.editable = FALSE;
	    [activateScrollView addSubview:activateNotes];
	    activateNotes.frame = CGRectMake(0, activateData.frame.origin.y + activateData.frame.size.height + 10, activateScrollView.frame.size.width, activateNotes.contentSize.height);
	    //NSLog(@"Height is :%f", activateNotes.contentSize.height);

	    activateScrollView.contentSize = CGSizeMake((frame.size.width / 2) - 160, activateBody.frame.size.height + 60 + activateData.frame.size.height + activateNotes.frame.size.height);

activateBodyOverlay = [[UIView alloc] initWithFrame:activateScrollView.frame];
[activateBodyOverlay setBackgroundColor:[UIColor whiteColor]];
[activateBodyOverlay setUserInteractionEnabled:NO];
[self addSubview:activateBodyOverlay];

NSArray *colors = [NSArray arrayWithObjects:
                   (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                   (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                   nil];

CAGradientLayer *layer = [CAGradientLayer layer];
[layer setFrame:activateBodyOverlay.bounds];
[layer setColors:colors];
[layer setStartPoint:CGPointMake(0.0f, 1.0f)];
[layer setEndPoint:CGPointMake(0.0f, 0.8f)];
[activateBodyOverlay.layer setMask:layer];
activateBodyOverlay.alpha = 1.0;

 	activateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[activateButton addTarget:self 
           action:@selector(activatePressed)
 forControlEvents:UIControlEventTouchDown];
[activateButton setTitle:NSLocalizedBundleString(@"ACTIVATE_BUTTON", nil) forState:UIControlStateNormal];
[activateButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
[activateButton setTitleColor:[UIColor colorWithRed:0.0 green:50.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
activateButton.frame = CGRectMake((frame.size.width / 2) - 160,frame.size.height - 70, 320, 40);
activateButton.font = [UIFont fontWithName:@"Arial" size:24];
activateButton.alpha = 1.0; //Only show this when an OTA option has been chosen!
[activateButton setBackgroundImage:nil forState:UIControlStateNormal];
[self addSubview:activateButton];


 	continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[continueButton addTarget:self 
           action:@selector(continuePressed)
 forControlEvents:UIControlEventTouchDown];
[continueButton setTitle:NSLocalizedBundleString(@"ACTIVATE_RESPRING_BUTTON", nil) forState:UIControlStateNormal];
[continueButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
[continueButton setTitleColor:[UIColor colorWithRed:0.0 green:50.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
continueButton.frame = CGRectMake((frame.size.width / 2) - 160,frame.size.height - 50, 320, 40);
continueButton.font = [UIFont fontWithName:@"Arial" size:18];
continueButton.alpha = 0.0;
continueButton.userInteractionEnabled = FALSE;
[continueButton setBackgroundImage:nil forState:UIControlStateNormal];
[self addSubview:continueButton];

	selfReference = self;
	}
	return self;
}


-(void)layoutSubviews:(int)orientation{

    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    float screenWidth = screenFrame.size.width;
    float screenHeight = screenFrame.size.height;

if (UIDeviceOrientationIsLandscape(orientation))
{
     screenHeight = screenFrame.size.width;
    screenWidth = screenFrame.size.height;    
}
else{
      screenWidth = screenFrame.size.width;
    screenHeight = screenFrame.size.height;
}

activationStatusLabel.frame = CGRectMake((screenWidth / 2) - 160,screenHeight / 2 - 80, 320, 40);
        
rebootBody.frame = CGRectMake((screenWidth / 2) - 160, activationStatusLabel.frame.origin.y + activationStatusLabel.frame.size.height, 320, rebootBody.contentSize.height);

activateTitleLabel.frame = CGRectMake((screenWidth / 2) - 160,20, 320, 40);
        
activateScrollView.frame = CGRectMake((screenWidth / 2) - 160, activateTitleLabel.frame.origin.y + 40, 320, 300);
        
activateBody.frame = CGRectMake(0, 0, activateScrollView.frame.size.width, activateBody.contentSize.height);

   
 activateData.frame = CGRectMake(0, activateBody.frame.origin.y + activateBody.frame.size.height + 10, activateScrollView.frame.size.width, activateData.contentSize.height);

activateNotes.frame = CGRectMake(0, activateData.frame.origin.y + activateData.frame.size.height + 10, activateScrollView.frame.size.width, activateNotes.contentSize.height);
        
activateScrollView.contentSize = CGSizeMake((screenWidth / 2) - 160, activateBody.frame.size.height + 60 + activateData.frame.size.height + activateNotes.frame.size.height);

activateBodyOverlay.frame = activateScrollView.frame;

activateButton.frame = CGRectMake((screenWidth / 2) - 160,screenHeight - 70, 320, 40);

continueButton.frame = CGRectMake((screenWidth / 2) - 160,screenHeight - 50, 320, 40);

    self.frame = CGRectMake(0,0,screenWidth, screenHeight); //Gotta update this otherwise it leaves off part of the screen as non-responsive because technically the frame still hasn't updated to the new dimensions even if you can see things out-of-frame.
  
}

-(void)reshowActivationScreen{
	 			//[moduleView.activateView stopAnimation];
				//[moduleView.activateView clearScreen]; //Wipe all the data there...
[continueButton setTitle:NSLocalizedBundleString(@"UNLOCK_DEVICE", nil) forState:UIControlStateNormal];
				shouldRespring = FALSE;

	         	[UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
						activateButton.alpha = 1.0;
						activateScrollView.alpha = 1.0;
						activationStatusLabel.alpha = 0.0;
						activateScrollView.userInteractionEnabled = TRUE;
						activateTitleLabel.userInteractionEnabled = TRUE;
                        continueButton.userInteractionEnabled = TRUE;
						//activateBody.userInteractionEnabled = TRUE;
						activateButton.userInteractionEnabled = TRUE;
                        activateButton.frame = CGRectMake((self.frame.size.width / 2) - 160,self.frame.size.height - 100, 320, 40);
                        continueButton.alpha = 0.4;

                 }
                 completion:^(BOOL finished){
                 	
                 }];

	         	
}


-(void)continuePressed{
	//[self.controller.vManager changeToViewWithID:@"setupls.OTAInstallView"];
if(shouldRespring){

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableArray * args = [[NSMutableArray alloc] init]; //Eh?

    [args addObject:@"-r"];


    
    NSLog(@"Args is %@", args);
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/Mercury"];
    [task setArguments:args];
    [task launch];
    [task release];
    [args release];
    [pool drain];
    //[self.controller.controller unlock];
}
else{
    [self.controller.controller unlock]; //Like magic, we are in! :)
}
}


-(void)showContinueButton{
    if(activated){
        return;
    }

    [continueButton setTitle:NSLocalizedBundleString(@"UNLOCK_DEVICE", nil) forState:UIControlStateNormal];
                shouldRespring = FALSE;

                [UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
      
                        continueButton.userInteractionEnabled = TRUE;
                        //activateBody.userInteractionEnabled = TRUE;
                 
                        activateButton.frame = CGRectMake((self.frame.size.width / 2) - 160,self.frame.size.height - 100, 320, 40);
                        continueButton.alpha = 0.4;

                 }
                 completion:^(BOOL finished){
                    
                 }];
}


-(void)activatePressed{
[self performSelector:@selector(showContinueButton) withObject:nil afterDelay:10.0];
tellServerHello();
	         	[UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                      	//activateTitleLabel.alpha = 0.0;
						//activateBody.alpha = 0.0;
						activateButton.alpha = 0.0; //FIXME
						activateScrollView.alpha = 0.0;
						activationStatusLabel.alpha = 1.0;
						activateScrollView.userInteractionEnabled = FALSE;
						activateTitleLabel.userInteractionEnabled = FALSE;
						activateBody.userInteractionEnabled = FALSE;
						activateButton.userInteractionEnabled = FALSE; //FIXME
                        continueButton.userInteractionEnabled = FALSE;
                        continueButton.alpha = 0.0;


                 }
                 completion:nil];

}

-(void)showCompleteInstallScreen{
    activated = TRUE;
    shouldRespring = TRUE;
continueButton.font = [UIFont fontWithName:@"Arial" size:24];
continueButton.alpha = 1.0;
[continueButton setTitle:NSLocalizedBundleString(@"ACTIVATE_RESPRING_BUTTON", nil) forState:UIControlStateNormal];
	activationStatusLabel.text = NSLocalizedBundleString(@"ACTIVATE_REBOOT_TITLE", nil);
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/Info.plist"]){
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/Info.plist"];
            [prefs setObject:[NSNumber numberWithBool:FALSE] forKey:@"showForUpgrade"]; //So it doesn't keep checking for upgrades...
            [prefs writeToFile:@"/Library/liblockscreen/Lockscreens/SetupLS.bundle/Info.plist" atomically:YES];

        [prefs release];
    }
    else{
        [self showAlertViewWithTitle:@"Error" body:@"You shouldn't see this message, but this means you encountered a bug meaning you will see this activaiton lockscreen each time.\nCheck\nhttp://grayd00r.com\nfor support in fixing this issue."];
    }
		      [UIView animateWithDuration:0.25
                      delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                      	//activateTitleLabel.alpha = 0.0;
						//activateBody.alpha = 0.0;
						continueButton.alpha = 1.0; //FIXME
						continueButton.userInteractionEnabled = TRUE;
						rebootBody.alpha = 1.0;
						rebootBody.userInteractionEnabled = TRUE;
						//activateScrollView.alpha = 0.0;
						//activationStatusLabel.alpha = 1.0;
						//activateScrollView.userInteractionEnabled = FALSE;
						//activateTitleLabel.userInteractionEnabled = FALSE;
						//activateBody.userInteractionEnabled = FALSE;
						//activateButton.userInteractionEnabled = FALSE; //FIXME


                 }
                 completion:nil];
}


-(void)showAlertViewWithTitle:(NSString*)title body:(NSString*)body{
	        UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle: title
                                       message: body
                                      delegate: nil
                             cancelButtonTitle: NSLocalizedBundleString(@"POPUP_ALERT_CLOSE", nil)
                             otherButtonTitles: nil];
            [alert show];
            [alert release];
}


-(void)unableToReachServer{
	[self reshowActivationScreen];
	[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_CANT_REACH_SERVER_BODY", nil)];
}

-(void)badResponseFromServer{
[self reshowActivationScreen];
[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_BAD_RESPONSE_BODY", nil)];

}

-(void)badPermissions{
[self reshowActivationScreen];
[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_BAD_PERMISSIONS_BODY", nil)];

}

-(void)activationPassed{
//[self showAlertViewWithTitle:@"Success" body:@"Activaiton passed?"];
[self showCompleteInstallScreen];
}

-(void)activationFailed{
//License key from online isn't any good!
[self reshowActivationScreen];
[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_FAILED_BODY", nil)];

}

-(void)handleSuccess:(NSDictionary*)serverMsg{
//Something happened, so we can move on. We didn't get a license if we got this, but the activation online passed.
[self showCompleteInstallScreen];
//[self showAlertViewWithTitle:@"Success" body:[NSString stringWithFormat:NSLocalizedBundleString(@"ACTIVATION_UNHANDLED_ERROR_BODY", nil), serverMsg]];
}

-(void)handleError:(NSDictionary*)serverMsg{
	
	bool handledError = FALSE;


	if([serverMsg objectForKey:@"statusCode"]){
		if([[serverMsg objectForKey:@"statusCode"] isEqual:@"noBlob"]){
			[self reshowActivationScreen];
			[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_SERVER_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_ERROR_NO_BLOB", nil)];
			handledError = TRUE;
		}
		if([[serverMsg objectForKey:@"statusCode"] isEqual:@"badEncryption"]){
			[self reshowActivationScreen];
			[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_SERVER_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_ERROR_BAD_ENCRYPTION", nil)];
			handledError = TRUE;
		}
		if([[serverMsg objectForKey:@"statusCode"] isEqual:@"badUserInfo"]){
			[self reshowActivationScreen];
			[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_SERVER_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_ERROR_BAD_USER_INFO", nil)];
			handledError = TRUE;
		}
		if([[serverMsg objectForKey:@"statusCode"] isEqual:@"cantGenLicenseKey"]){
			[self reshowActivationScreen];
			[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_SERVER_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_ERROR_CANT_GEN_LICENSE", nil)];
			handledError = TRUE;
		}
		if([[serverMsg objectForKey:@"statusCode"] isEqual:@"cantAccessDatabase"]){ //not so much of a big issue, we can probably allow this to an acceptable error and proceed anyway.
			[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_SERVER_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_ERROR_CANT_ACCESS_DATABSE", nil)];
			handledError = TRUE;
			[self showCompleteInstallScreen];
		}
		if([[serverMsg objectForKey:@"statusCode"] isEqual:@"missingUserInfo"]){ //This is probably okay to pass through as well and let them still use the device.
			[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_SERVER_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_ERROR_MISSING_USER_INFO", nil)];
			handledError = TRUE;
			[self showCompleteInstallScreen];
		}
		if([[serverMsg objectForKey:@"statusCode"] isEqual:@"cantFindDatabase"]){ //This is probably okay to pass through as well and let them still use the device.
			[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_SERVER_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_ERROR_CANT_FIND_DATABASE", nil)];
			handledError = TRUE;
			[self showCompleteInstallScreen];
		}
	}

	if(!handledError){
		[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_UNHANDLED_ERROR_TITLE", nil) body:[NSString stringWithFormat:NSLocalizedBundleString(@"ACTIVATION_UNHANDLED_ERROR_BODY", nil), serverMsg]];
	}
}

-(void)installerCheckFailed{
[self reshowActivationScreen];
[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_BAD_INSTALLER", nil)];

}

-(void)noOTAGroupSet{
[self reshowActivationScreen];
[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_NO_OTA_GROUP", nil)];

}

-(void)errorMakingMessageForServer{
[self reshowActivationScreen];
[self showAlertViewWithTitle:NSLocalizedBundleString(@"ACTIVATION_ERROR_TITLE", nil) body:NSLocalizedBundleString(@"ACTIVATION_CANT_MAKE_MESSAGE_TO_SERVER", nil)];

}



@end