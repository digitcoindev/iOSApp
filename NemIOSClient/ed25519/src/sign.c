#include <stdlib.h>
#include "ed25519.h"
#include "sha512.h"
#include "keccak.h"
#include "ge.h"
#include "sc.h"


//void ed25519_sign(unsigned char *signature, const unsigned char *message, size_t message_len, const unsigned char *public_key, const unsigned char *private_key)
//{
//    sha512_context hash;
//    unsigned char hram[64];
//    unsigned char r[64];
//    ge_p3 R;
//
//
//    sha512_init(&hash);
//    sha512_update(&hash, private_key + 32, 32);
//    sha512_update(&hash, message, message_len);
//    sha512_final(&hash, r);
//
//    sc_reduce(r);
//    ge_scalarmult_base(&R, r);
//    ge_p3_tobytes(signature, &R);
//
//    sha512_init(&hash);
//    sha512_update(&hash, signature, 32);
//    sha512_update(&hash, public_key, 32);
//    sha512_update(&hash, message, message_len);
//    sha512_final(&hash, hram);
//
//    sc_reduce(hram);
//    sc_muladd(signature + 32, hram, private_key, r);
//}

void ed25519_sign(unsigned char *signature, unsigned char *data, int32_t dataSize, unsigned char *public_key ,unsigned char *privateKey)
{
    const size_t privateKeyPartSize = 32;
    const size_t publicKeySize = 32;
    const size_t signatureSize = 32;
    const size_t hash_512_Size = 64;
    
    unsigned char hram[64];
    unsigned char r[64];
    unsigned char *inData;
    ge_p3 R;
    
    inData = (unsigned char*) malloc(dataSize + privateKeyPartSize);
    
    memcpy(inData, privateKey + privateKeyPartSize, privateKeyPartSize);
    memcpy(inData + privateKeyPartSize, data, dataSize);
    
    keccak((uint8_t *) inData, dataSize + privateKeyPartSize , r, hash_512_Size);

    free(inData);
    
    sc_reduce(r);
    ge_scalarmult_base(&R, r);
    ge_p3_tobytes(signature, &R);
    
    inData = (unsigned char*) malloc(dataSize + publicKeySize + signatureSize);
    
    memcpy(inData, signature, signatureSize);
    memcpy(inData + signatureSize, public_key, publicKeySize);
    memcpy(inData + signatureSize + publicKeySize, data, dataSize);
    
    keccak((uint8_t *) inData, dataSize + signatureSize + publicKeySize , hram, hash_512_Size);
    
    sc_reduce(hram);
    sc_muladd(signature + 32, hram, privateKey, r);
}