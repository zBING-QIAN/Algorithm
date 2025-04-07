#include <bits/stdc++.h>
using namespace std;
int MAXP = 1000000;
int fast_pow(long long a, int p, int mod)
{
    // p = p%mod;
    long long out = 1;
    while (p)
    {
        if (p & 1)
            out = (out * a) % mod;
        p >>= 1;
        a = (a * a) % mod;
        // if(mod == 513)cout<<a<<" "<<out<<" "<<p<<endl;
    }
    return out;
}
int randint()
{
    int tmp = rand() << 15;
    tmp |= rand();
    tmp <<= 1;
    tmp |= rand() & 1;
    return tmp;
}
bool Proth_Primality_Test(int p)
{
    int test_time = 100;
    for (int t = 2; t < test_time; t++)
    {
        int r = randint();
        if (fast_pow(r, (p - 1) / 2, p) == p - 1)
        {
            return 1;
        }
    }
    return 0;
}
int main()
{
    vector<bool> prime(MAXP + 1, 1);
    // prepare prime numbers
    for (long long i = 2; i < MAXP; i++)
    {
        if (prime[i])
            for (long long j = i * i; j <= MAXP; j += i)
                prime[j] = 0;
    }
    // pick good prime for NTT with 2^k length, here we choose smallest satisfied prime
    map<int, vector<int>> good_primes;
    for (int pow2 = 1 << 8; pow2 < MAXP; pow2 <<= 1)
    {
        for (int p = pow2 + 1; p < MAXP; p += pow2)
            // if (prime[p])

            if (Proth_Primality_Test(p))
            {
                good_primes[p].push_back(pow2);
                break;
            }
    }
    // find primitive root for Zp field
    for (auto &p : good_primes)
    {
        // prepare some numbers to be check
        vector<int> test_list;
        int c = p.first - 1;
        for (long long i = 2; i * i <= c; i++)
        {

            if (prime[i])
            {
                if ((c % i) == 0)
                {
                    test_list.push_back(c / i);
                }
            }
        }
        // brute force find primitive root
        int prt = 0;
        for (int i = 2; i <= c; i++)
        {
            prt = i;
            for (auto t : test_list)
            {
                int tmp = fast_pow(i, t, p.first);
                // cout<<p.first<<" "<<i<<" "<<t<<" "<<tmp<<endl;
                if (tmp == 1)
                {
                    prt = 0;
                    break;
                }
            }
            if (prt)
                break;
        }
        /* verify primitive root (brute force)
        long long ptmp = 1;
        for(int i=0;i<c-1;i++){
            ptmp=(ptmp*prt)%p.first;
            if(ptmp==1){cout<<ptmp<<" order is "<<i<<"fail test\n";break;}
        }
        */
        printf("%d primitive root %d\n", p.first, prt);
        for (auto n : p.second)
            cout << n << " ";
        cout << endl;
        // break;
    }
    return 0;
}
/*
(prime) primitive root (primitive root to prime)
(seqence length)
result :
    257 primitive root 3
    256
    7681 primitive root 17
    512
    12289 primitive root 11
    1024 2048 4096
    40961 primitive root 3
    8192
    65537 primitive root 3
    16384 32768 65536
    786433 primitive root 10
    131072 262144
*/