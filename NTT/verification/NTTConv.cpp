#include <vector>
#include <algorithm>
#include <iostream>
using namespace std;
// 257 primitive root 3
// 256
// 12289 primitive root 11
// 1024 2048 4096
int fast_pow(long long a, int p, int mod)
{
    // p = p%mod;  //  Fermat's little theorem
    long long out = 1;
    while (p)
    {
        if (p & 1)
            out = (out * a) % mod;
        p >>= 1;
        a = (a * a) % mod;
    }
    return out;
}

void NTT(vector<int> &a, vector<int> &res, int n, int mod, int prt)
{
    vector<int> r(n, 0);
    res.resize(n, 0);
    for (int i = 0; i < n; i++)
        r[i] = (i & 1) * (n >> 1) + (r[i >> 1] >> 1); // Decimation in Time
    for (int i = 0; i < n; i++)
        res[i] = a[i];
    for (int i = 0; i < n; i++)
        if (r[i] < i)
            swap(res[i], res[r[i]]);
    int ker = 1;
    // Butterfly
    for (int t = 2; t <= n; t <<= 1)
    {
        int k = t >> 1;
        ker = fast_pow(prt, (mod - 1) / t, mod);
        // for (int i = 0, ker_i = 1; i < k; i++, ker_i = (1ll * ker * ker_i) % mod)
        for (int i = 0, ker_i = 1; i < k; i++, ker_i = (ker * ker_i) % mod)
        {
            for (int j = 0; j < n; j += t)
            {
                // int tmp = (1ll * ker_i * res[i + j + k]) % mod;
                int tmp = (ker_i * res[i + j + k]) % mod;
                res[i + j + k] = (res[i + j] - tmp + mod) % mod;
                res[i + j] = (tmp + res[i + j]) % mod;
            }
        }
    }
}
void INTT(vector<int> &a, vector<int> &res, int n, int mod, int prt)
{
    NTT(a, res, n, mod, prt);
    // cout << "inv n   " << inv_n << endl;
    reverse(res.begin() + 1, res.end());
    int inv_n = fast_pow(n, (mod - 2), mod);
    for (int i = 0; i < n; i++)
        // res[i] = (1ll * inv_n * res[i]) % mod;
        res[i] = (inv_n * res[i]) % mod;
}
void Dot_Product(vector<int> &a, vector<int> &b, vector<int> &res, int n, int mod)
{
    for (int i = 0; i < n; i++)
        // res[i] = (1ll * a[i] * b[i]) % mod;
        res[i] = (a[i] * b[i]) % mod;
}
void Conv(vector<int> &a, vector<int> &b, vector<int> &res, int n, int mod, int prt)
{
    vector<int> A(n, 0), B(n, 0), RES(n, 0);
    NTT(a, A, n, mod, prt);
    NTT(b, B, n, mod, prt);
    Dot_Product(A, B, RES, n, mod);
    INTT(RES, res, n, mod, prt);
}
// Zp x Zq ~ Zpq
void CRT(vector<int> &a, vector<int> &b, vector<int> &res, int mod0, int mod1, int n)
{
    res.resize(n, 0);
    int mod = mod0 * mod1;
    int unity0 = (mod0 * fast_pow(mod0, mod1 - 2, mod1)) % mod;
    int unity1 = (mod1 * fast_pow(mod1, mod0 - 2, mod0)) % mod;
    for (int i = 0; i < n; i++)
    {
        res[i] = (((1ll * a[i] * unity1) % mod) + ((1ll * b[i] * unity0) % mod)) % mod;
    }
}
void NTT_Conv(vector<int> &a, vector<int> &b, vector<int> &res, int n = 256)
{
    int mod0 = 257, mod1 = 12289, prt0 = 3, prt1 = 11;
    vector<int> res0(n, 0), res1(n, 0);
    Conv(a, b, res0, n, mod0, prt0);
    Conv(a, b, res1, n, mod1, prt1);
    CRT(res0, res1, res, mod0, mod1, n);
    for (int i = 0; i < n; i++)
    {
        // cout << res[i]+1 << endl; // error check
        cout << res[i] << endl;
    }
}

// DPIC
#include "svdpi.h"
extern "C" bool SW_CONV_check(svOpenArrayHandle *a, svOpenArrayHandle *b, svOpenArrayHandle *a_res, svOpenArrayHandle *b_res, svOpenArrayHandle *res)
{
    int N = 256, P = 257, PRT = 3;
    // int N = 256, P = 12289, PRT = 11;
    int *aptr = (int *)svGetArrayPtr(a);
    int *bptr = (int *)svGetArrayPtr(b);
    int *aresptr = (int *)svGetArrayPtr(a_res);
    int *bresptr = (int *)svGetArrayPtr(b_res);
    int *resptr = (int *)svGetArrayPtr(res);
    vector<int> atmp(N, 0), btmp(N, 0), restmp(N, 0);
    for (int i = 0; i < N; i++)
    {
        atmp[i] = aptr[i];
        btmp[i] = bptr[i];
    }
    Conv(atmp, btmp, restmp, N, P, PRT);
    for (int i = 0; i < N; i++)
    {
        // if diff -> print error
        if (restmp[i] != resptr[i])
        {
            for (int j = 0; j < N; j++)
            {
                printf("SW : %d %d %d\n", j, restmp[j], resptr[j]);
            }
            return 0;
        }
    }

    return 1;
}
extern "C" bool SW_NTT_check(svOpenArrayHandle *a, svOpenArrayHandle *res)
{

    int N = 256, P = 257, PRT = 3;

    // int N = 256, P = 12289, PRT = 11;
    int *aptr = (int *)svGetArrayPtr(a);
    int *resptr = (int *)svGetArrayPtr(res);
    vector<int> atmp(N, 0), restmp(N, 0);
    for (int i = 0; i < N; i++)
    {
        atmp[i] = aptr[i];
    }
    NTT(atmp, restmp, N, P, PRT);
    for (int i = 0; i < N; i++)
    {
        // if diff -> print error
        if (restmp[i] != resptr[i])
        {
            for (int j = 0; j < N; j++)
            {
                printf("%d %d %d\n", j, restmp[j], resptr[j]);
            }
            return 0;
        }
    }
    return 1;
}

extern "C" void gencase(svOpenArrayHandle *a, svOpenArrayHandle *b)
{
    // srand(std::chrono::high_resolution_clock::now().time_since_epoch().count());
    int N = 256, P = 257;

    // int N = 256, P = 12289, PRT = 11;
    int *aptr = (int *)svGetArrayPtr(a);
    int *bptr = (int *)svGetArrayPtr(b);
    vector<int> atmp(N, 0), restmp(N, 0);
    // i< N/2 is for non cyclic convolution, otherwise i<N is for cyclic convolution
    for (int i = 0; i < N / 2; i++)
    {
        aptr[i] = rand() % P;
        bptr[i] = rand() % P;
    }
    cout << "a :\n";
    for (int i = 0; i < N; i++)
        cout << aptr[i] << " ";
    cout << endl;

    cout << "b :\n";
    for (int i = 0; i < N; i++)
        cout << bptr[i] << " ";
    cout << endl;
}