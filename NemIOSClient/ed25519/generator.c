#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "src/ed25519.h"

#include "src/ge.h"
#include "src/sc.h"
#include "sha512.h"

#include "keccak.h"

void SHA256_hash(char *out, char *in)
{
    uint8_t md[32];
    keccak((uint8_t *) in, strlen(in), md, 32);
    
    for(int i=0;i<32;i++)
    {
        sprintf(&out[i*2], "%02x", md[i]);
    }
}
void createPrivateKey(unsigned char *out_private_key)
{
    unsigned char  private_key[64], seed[32];
    
    ed25519_create_seed(seed);
    
    sha512(seed, 32, private_key);
    private_key[0] &= 248;
    private_key[31] &= 127;
    private_key[31] |= 64;
    
    char converted_private_key[64*2 + 1];
    int i;
    
    for(i=0;i<64;i++)
    {
        sprintf(&converted_private_key[i*2], "%02x", private_key[i]);
    }
    
    for (i = 0; i < 128; i++)
    {
        out_private_key[i] = converted_private_key[i];
    }
}
void createPublicKey(unsigned char *public_key, unsigned char *private_key)
{
    ge_p3 A;
    unsigned char in_public_key[32];
    
    ge_scalarmult_base(&A, private_key);
    ge_p3_tobytes(in_public_key, &A);
    
    for(int i=0;i<32;i++)
    {
        sprintf(&public_key[i*2], "%02x", in_public_key[i]);
    }
}

