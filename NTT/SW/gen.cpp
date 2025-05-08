#include <bits/stdc++.h>
using namespace std;

int main(int argc, char *argv[])
{
    std::ofstream file(argv[1]); // Open file for writing
    if (!file)
    {
        std::cerr << "Error opening file!" << std::endl;
        return 1;
    }
    srand(std::chrono::high_resolution_clock::now().time_since_epoch().count());
    int n = 256;
    int limit = 111;
    for (int i = 0; i < n; i++)
    {
        if (i < n)
            file << rand() % limit << " ";
        else
            file << "0 ";
    }
    file << endl;

    for (int i = 0; i < n; i++)
    {
        if (i < n)
            file << rand() % limit << " ";
        else
            file << "0 ";
    }
    file << endl;
    return 0;
}