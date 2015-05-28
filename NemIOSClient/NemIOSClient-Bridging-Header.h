//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#include <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "MyHandler.h"

#import "Crypto.h"
#import "NSData+Base64.h"
#import <GoogleMaps/GoogleMaps.h>

void ed25519_create_keypair(unsigned char *public_key, unsigned char *private_key, const unsigned char *seed);
void createPrivateKey(unsigned char *out_private_key);
void createPublicKey(unsigned char *public_key, const unsigned char *private_key);
void SHA256_hash(unsigned char *out,unsigned char *in , int32_t inLen);
int keccak(const uint8_t *in, int inlen, uint8_t *md, int mdlen);
void Sign(unsigned char *signature, unsigned char *data, int32_t dataSize, unsigned char *public_key ,unsigned char *privateKey);
void crypto_test();
void InstallUncaughtExceptionHandler();
