#include <bits/stdc++.h>
using namespace std;
bool same(vector<int> &s, int a, int b, int len)
{
    for (int i = 0; i < len; i++, a++, b++)
    {
        if (s[a] != s[b])
            return 0;
    }
    return 1;
}
void induce_sort(vector<int> &s, vector<int> &sa, vector<int> &lms, vector<int> &bucket, vector<bool> &types)
{
    int n = s.size();
    sa.assign(n, 0);
    vector<int> _bucket = bucket;
    for (int i = lms.size() - 1; i >= 0; i--)
        sa[--_bucket[s[lms[i]]]] = lms[i];
    for (int i = 1; i < bucket.size(); i++)
        _bucket[i] = bucket[i - 1];
    for (int i = 0; i < n; i++)
    {
        if (sa[i] > 0 && !types[sa[i] - 1])
            sa[_bucket[s[sa[i] - 1]]++] = sa[i] - 1;
    } // L-type
    _bucket = bucket;
    for (int i = n - 1; i >= 0; i--)
    {
        if (sa[i] > 0 && types[sa[i] - 1])
            sa[--_bucket[s[sa[i] - 1]]] = sa[i] - 1;
    } // S-type
}
void sais(vector<int> &s, vector<int> &sa, int symbols = 27)
{
    int n = s.size();
    sa.assign(n, 0);
    vector<int> bucket(symbols, 0);
    vector<bool> types(n, 0);
    for (auto &i : s)
        bucket[i]++;
    for (int i = 1; i < symbols; i++)
    {
        bucket[i] += bucket[i - 1];
    }
    types[n - 1] = 1;
    for (int i = n - 2; i >= 0; i--)
        types[i] = (s[i] < s[i + 1] || (s[i] == s[i + 1] && types[i + 1]));
    int lms_size = 0;
    vector<int> lms2s, s2lms(n, -1);
    for (int i = 1; i < n; i++)
    {
        if (types[i] && !types[i - 1])
        {
            lms2s.push_back(i);
            s2lms[i] = lms_size++;
        }
    }
    induce_sort(s, sa, lms2s, bucket, types); // sort lms substring
    int cnt = -1;
    vector<int> lms(lms_size, 0);
    for (int prev = -1, prev_len = 0, i = 0; i < n; i++)
    {
        int cur = s2lms[sa[i]];
        if (cur >= 0)
        {
            int len = (cur + 1 < lms_size) ? lms2s[cur + 1] - lms2s[cur] : 1;
            if (prev_len != len || !same(s, lms2s[cur], lms2s[prev], len)) // check two lms substring are different
                cnt++;
            lms[cur] = cnt;
            prev = cur;
            prev_len = len;
        }
    }
    if (cnt + 1 == lms_size)
    {
        for (int i = 0; i < lms_size; i++)
            sa[lms[i]] = i;
    }
    else
        sais(lms, sa, cnt + 1); //  sort lms recursively if any two lms substring are the same
    for (int i = 0; i < lms_size; i++)
        lms[i] = lms2s[sa[i]];
    induce_sort(s, sa, lms, bucket, types); // sort sa
}
int main()
{
    string s;
    cin >> s;
    int n = s.size();
    vector<int> stmp(n + 1), sa;
    for (int i = 0; i < n; i++)
    {
        stmp[i] = 1 + s[i];
    }
    stmp[n] = 0;
    sais(stmp, sa, 257);
    for (int i = 1; i <= n; i++)
        printf("%d\n", sa[i]);
    return 0;
}
