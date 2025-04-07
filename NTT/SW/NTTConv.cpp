#include <bits/stdc++.h>
using namespace std;
// 257 primitive root 3
// 256
// 12289 primitive root 11
// 1024 2048 4096
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
    int inv_n = fast_pow(n, (mod - 2), mod);
    reverse(res.begin() + 1, res.end());
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
// Zp x Zq ~= Zpq
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
void NTT_Conv(vector<int> &a, vector<int> &b, int n = 256)
{
    int mod0 = 257, mod1 = 12289, prt0 = 3, prt1 = 11;
    vector<int> res0(n, 0), res1(n, 0), res(n, 0);
    Conv(a, b, res0, n, mod0, prt0);
    Conv(a, b, res1, n, mod1, prt1);
    CRT(res0, res1, res, mod0, mod1, n);
    for (int i = 0; i < n; i++)
    {
        // cout << res[i]+1 << endl; // test for different
        cout << res[i] << endl;
    }
}
int main()
{
    int n = 256;
    vector<int> a(n, 0), b(n, 0);
    for (int i = 0; i < n; i++)
    {
        cin >> a[i];
    }
    for (int i = 0; i < n; i++)
    {
        cin >> b[i];
    }
    NTT_Conv(a, b, n);
    return 0;
}