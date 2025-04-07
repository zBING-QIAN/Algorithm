#include <bits/stdc++.h>
using namespace std;
complex<double> root(double n)
{
    complex<double> pi = acos(-1.0), i(0.0, 1.0);
    return exp((double)(-2) * i * pi / n);
}
void DFT(vector<complex<double>> &a, vector<complex<double>> &res, int n)
{
    double N = n;
    complex<double> kp = 1, p = root(N);
    n = abs(n);
    res.resize(n, 0);
    for (int k = 0; k < n; k++)
    {
        complex<double> jp = 1;
        for (int j = 0; j < n; j++, jp *= kp)
        {
            res[k] += jp * a[j]; // a[j]*exp^(-i*2*pi*j/N)
        }
        kp *= p;
    }
}
void IDFT(vector<complex<double>> &a, vector<complex<double>> &res, int n)
{
    DFT(a, res, -n);
    for (int i = 0; i < n; i++)
        res[i] /= double(n);
}
void Dot_Product(vector<complex<double>> &a, vector<complex<double>> &b, vector<complex<double>> &res, int n)
{
    for (int i = 0; i < n; i++)
    {
        res[i] = a[i] * b[i];
    }
}

int main()
{

    int n = 256;
    vector<complex<double>> a(n, 0), b(n, 0),
        A(n, 0), B(n, 0), RES(n, 0), res(n, 0), ia(n, 0), ib(n, 0);

    for (int i = 0; i < n; i++)
        cin >> a[i];
    for (int i = 0; i < n; i++)
        cin >> b[i];
    DFT(a, A, n);
    DFT(b, B, n);
    Dot_Product(A, B, RES, n);
    IDFT(RES, res, n);
    IDFT(A, ia, n);

    // cout << "A : ";
    // for (int i = 0; i < n; i++)
    //     cout << A[i] << " ";
    // cout << endl;
    // cout << "ia : ";
    // for (int i = 0; i < n; i++)
    //     cout << ia[i] << " ";
    // cout << endl;
    // cout << "B : ";
    // for (int i = 0; i < n; i++)
    //     cout << B[i] << " ";
    // cout << endl;
    // cout << "RES : ";
    // for (int i = 0; i < n; i++)
    //     cout << RES[i] << " ";
    // cout << endl;

    // for (int i = 0; i < n; i++)
    //     cout << a[i] << " ";
    // cout << endl;
    // for (int i = 0; i < n; i++)
    //     cout << b[i] << " ";
    // cout << endl;
    // cout << "res : ";
    for (int i = 0; i < n; i++)
    {
        int tmp = (int)res[i].real();
        if (res[i].real() - tmp > 0.5)
            tmp++;
        cout << res[i] << endl;
    }
    return 0;
}