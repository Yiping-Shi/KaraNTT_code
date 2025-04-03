# Parameter generation

# Determine n and bit-size of q, then find a q satisfying
# the condition: q = 1 (mod 2n) or q = 1 (mod n)
#
# Based on n and q, polynomial multiplication parameters
import random
import math

def miller_rabin(p,s=11):
    #computes p-1 decomposition in 2**u*r
    r = p-1
    u = 0
    while r&1 == 0:#true while the last bit of r is zero
        u += 1
        r = int(r/2)

    # apply miller_rabin primality test
    for i in range(s):
        a = random.randrange(2,p-1) # choose random a in {2,3,...,p-2}
        z = pow(a,r,p)

        if z != 1 and z != p-1:
            for j in range(u-1):
                if z != p-1:
                    z = pow(z,2,p)
                    if z == 1:
                        return False
                else:
                    break
            if z != p-1:
                return False
    return True

def is_prime(n,s=11):
     #lowPrimes is all primes (sans 2, which is covered by the bitwise and operator)
     #under 1000. taking n modulo each lowPrime allows us to remove a huge chunk
     #of composite numbers from our potential pool without resorting to Rabin-Miller
     lowPrimes =   [3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97
                   ,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179
                   ,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269
                   ,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367
                   ,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461
                   ,463,467,479,487,491,499,503,509,521,523,541,547,557,563,569,571
                   ,577,587,593,599,601,607,613,617,619,631,641,643,647,653,659,661
                   ,673,677,683,691,701,709,719,727,733,739,743,751,757,761,769,773
                   ,787,797,809,811,821,823,827,829,839,853,857,859,863,877,881,883
                   ,887,907,911,919,929,937,941,947,953,967,971,977,983,991,997]
     if (n >= 3):
         if (n&1 != 0):
             for p in lowPrimes:
                 if (n == p):
                    return True
                 if (n % p == 0):
                     return False
             return miller_rabin(n,s)
     return False

def generate_large_prime(k,s=11):
    #print "Generating prime of %d bits" % k
    #k is the desired bit length

    # using security parameter s=11, we have a error probability of less than
    # 2**-80

    r=int(100*(math.log(k,2)+1)) #number of max attempts
    while r>0:
        #randrange is mersenne twister and is completely deterministic
        #unusable for serious crypto purposes
        n = random.randrange(2**(k-1),2**(k))
        r-=1
        if is_prime(n,s) == True:
            return n
    raise Exception("Failure after %d tries." % r)

# Check if input is m-th (could be n or 2n) primitive root of unity of q
def isrootofunity(w,m,q):
    if pow(w,m,q) != 1:
        return False
    elif pow(w,m//2,q) != (q-1):
        return False
    else:
        v = w
        for i in range(1,m):
            if v == 1:
                return False
            else:
                v = (v*w) % q
        return True
    
def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('Modular inverse does not exist')
    else:
        return x % m



if __name__ == "__main__":
    # Parameters
    mod     = 2         # if 1 --> q = 1 (mod n), if 2 --> q = 1 (mod 2n)
    n       = 65536
    q_bit   = 30

    q       = 0
    w       = 0
    w_inv   = 0
    psi     = 0
    psi_inv = 0


    # Generate parameters
    wfound = False
    while(not(wfound)):
        # q = generate_large_prime(q_bit)
        q = 998244353 # 2^32 - 2^16 - 1

        # check q = 1 (mod n or 2n)
        while (not ((q % (mod*n)) == 1)):
            q = generate_large_prime(q_bit)

        # generate NTT parameters
        for i in range(2, q-1):
            wfound = isrootofunity(i,mod*n,q)
            if wfound:
                if mod == 1:
                    psi    = 0
                    psi_inv= 0
                    w      = i
                    w_inv  = modinv(w,q)
                else:
                    psi    = i
                    psi_inv= modinv(psi,q)
                    w      = pow(psi,2,q)
                    w_inv  = modinv(w,q)
                break
            

    # Print parameters
    print("Parameters (NWC)")
    print("n      : {}".format(n))
    print("q      : {}".format(q))
    print("w      : {}".format(w))
    print("w_inv  : {}".format(w_inv))
    print("psi    : {}".format(psi))
    print("psi_inv: {}".format(psi_inv))
    print("")
    
    # Parameters (NWC)
    # n       = 65536
    # q       = 998244353
    # w       = 80928016
    # w_inv   = 163063506
    # psi     = 8996
    # psi_inv = 498345419