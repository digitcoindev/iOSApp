//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#include <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "Crypto.h"
#import "NSData+Base64.h"



void ed25519_create_keypair(unsigned char *public_key, unsigned char *private_key, const unsigned char *seed);
int ed25519_create_seed(unsigned char *seed);


void createPrivateKey(unsigned char *out_private_key);
void createPublicKey(unsigned char *public_key, unsigned char *private_key);
