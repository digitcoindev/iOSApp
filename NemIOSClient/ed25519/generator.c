#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "src/ed25519.h"
#include "src/ge.h"
#include "src/sc.h"

#include "sha512.h"
#include "keccak.h"

const size_t privateKeyPartSize = 32;
const size_t signaturePartRAM = 32;
const size_t privateKeySize = 64;
const size_t publicKeySize = 32;
const size_t signatureSize = 64;
const size_t seedSize = 32;
const size_t hash_512_Size = 64;
const size_t hash_256_Size = 32;

void toHex(unsigned char *outHex, unsigned  char *inBytes, int32_t inBytesLen )
{
    const char szNibbleToHex[] = {"0123456789abcdef" };
    
    for (int i = 0; i < inBytesLen; i++)
    {
        int nNibble = inBytes[i] >> 4;
        outHex[2 * i]  = szNibbleToHex[nNibble];
        
        nNibble = inBytes[i] & 0x0F;
        outHex[2 * i + 1]  = szNibbleToHex[nNibble];
        
    }
}

void SHA256_hash(unsigned char *out,unsigned  char *in , int32_t inLen )
{
    uint8_t md[hash_256_Size];

    keccak((uint8_t *) in, inLen, md, hash_256_Size);

    toHex(out, &md, hash_256_Size);

}

void createPrivateKey(unsigned char *out_private_key)
{
    unsigned char  private_key[privateKeySize], seed[seedSize];
    
    ed25519_create_seed(seed);
    
    keccak((uint8_t *) seed, seedSize, private_key, privateKeySize);
    
    for (int i = 0; i < privateKeyPartSize; i++)
    {
        out_private_key[i] = private_key[i];
    }
}

void createPublicKey(unsigned char *public_key,  unsigned char *private_key)
{   

    unsigned char private_key_hash[privateKeySize];
    
    keccak((uint8_t *) private_key, privateKeyPartSize, private_key_hash, privateKeySize);
    
    private_key_hash[0] &= 248;
    private_key_hash[31] &= 127;
    private_key_hash[31] |= 64;
    
    ge_p3 A;
    unsigned char public_key_buffer [publicKeySize];
    
    ge_scalarmult_base(&A, private_key_hash);
    
    ge_p3_tobytes(public_key_buffer, &A);
    
    for(int i=0;i < publicKeySize ;i++)
    {
        public_key[i] = public_key_buffer[i];
    }
    
}
void Sign(unsigned char *signature, unsigned char *data, int32_t dataSize, unsigned char *public_key ,unsigned char *privateKey)
{
    unsigned char hram[64];
    unsigned char r[64];
    unsigned char *inData;
    unsigned char privateKeyHash[hash_512_Size];
    unsigned char private_key_bytes[privateKeyPartSize];
    unsigned char public_key_bytes[publicKeySize];
    
    ge_p3 R;
    
    for (int i=0 ;i < privateKeyPartSize;++i)
    {
        int value;
        sscanf(privateKey + 2 * i,"%02x",&value);
        private_key_bytes[privateKeyPartSize - 1 - i ] = value;
    }
    
    sha512_context hash;
    
    keccak((uint8_t *) private_key_bytes, privateKeyPartSize, privateKeyHash, privateKeySize);


    inData = (unsigned char*) malloc(dataSize + privateKeyPartSize);
    
    memcpy(inData, privateKeyHash + privateKeyPartSize, privateKeyPartSize);
    memcpy(inData + privateKeyPartSize, data, dataSize);
    
    keccak((uint8_t *) inData, dataSize + privateKeyPartSize , r, hash_512_Size);
    
    free(inData);
    
    sc_reduce(r);
    ge_scalarmult_base(&R, r);
    ge_p3_tobytes(signature, &R);
    
    for (int i = 0 ;i < publicKeySize;++i)
    {
        int value;
        sscanf(public_key + 2 * i,"%02x",&value);
        private_key_bytes[i] = value;
    }
    
    inData = (unsigned char*) malloc(dataSize + publicKeySize + signaturePartRAM);
    
    memcpy(inData, signature, signaturePartRAM);
    memcpy(inData + signaturePartRAM, private_key_bytes, publicKeySize);
    memcpy(inData + signaturePartRAM + publicKeySize, data, dataSize);
    
    keccak((uint8_t *) inData, dataSize + signaturePartRAM + publicKeySize , hram, hash_512_Size);
    
    free(inData);
    
    unsigned char *privateKeyRightPart = (unsigned char*) malloc(privateKeyPartSize);
    
    memcpy(privateKeyRightPart, privateKeyHash, privateKeyPartSize);

    privateKeyRightPart[0] &= 248;
    privateKeyRightPart[31] &= 127;
    privateKeyRightPart[31] |= 64;
    
    sc_reduce(hram);
    sc_muladd(signature + signaturePartRAM, hram, privateKeyRightPart, r);
    
    free(privateKeyRightPart);
}
