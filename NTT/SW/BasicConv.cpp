#include <bits/stdc++.h>
using namespace std;

// void basic_conv(int *a, int *b, int **res, int n)
// {
//     *res = new int[n * 2];
//     memset((*res), 0, n * 2 * sizeof(int));
//     for (int i = 0; i < n * 2; i++)
//     {
//         for (int j = 0; j < n; j++)
//         {

//             if (i >= j && i - j < n)
//                 (*res)[i] += a[i - j] * b[j];
//         }
//     }
// }

void basic_conv(vector<int> &a, vector<int> &b, vector<int> &res, int n)
{
    for (int i = 0; i < n * 2; i++)
    {
        for (int j = 0; j < n; j++)
        {

            if (i >= j && i - j < n)
                res[i] += a[i - j] * b[j];
        }
    }
}

int main()
{
    int n = 256;
    vector<int> a(n, 0), b(n, 0), res(n, 0);
    for (int i = 0; i < n; i++)
        cin >> a[i];
    for (int i = 0; i < n; i++)
        cin >> b[i];
    basic_conv(a, b, res, n / 2);

    for (int i = 0; i < n; i++)
    {
        cout << res[i] << endl;
    }
    return 0;
}