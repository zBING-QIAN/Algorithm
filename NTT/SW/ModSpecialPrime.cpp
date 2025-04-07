#include <bits/stdc++.h>
using namespace std;
int mod(int v)
{
    int v0 = (v >> 24) & 255, v1 = (v >> 16) & 255, v2 = (v >> 8) & 255, v3 = v & 255;
    int tmp0 = v1 - v0;
    if (tmp0 < 0)
        tmp0 += 257;
    int tmp1 = v2 - tmp0;
    if (tmp1 < 0)
        tmp1 += 257;
    int tmp2 = v3 - tmp1;
    if (tmp2 < 0)
        tmp2 += 257;

    return tmp2;
    // return v3 - tmp1;
}
int randint()
{
    int tmp = rand() << 15;
    tmp |= rand();
    tmp <<= 1;
    tmp |= rand() & 1;
    return tmp;
}
int main()
{
    srand(std::chrono::high_resolution_clock::now().time_since_epoch().count());

    int prime = 257;
    for (int t = 0; t < 10000; t++)
    {
        int tmp = randint();
        int mod_res = mod(tmp);
        if (mod_res != tmp % prime)
        {
            printf("v = %d, res = %d, golden = %d\n", tmp, mod_res, tmp % prime);
        }
        // else
        //     cout << "pass\n";
    }

    return 0;
}