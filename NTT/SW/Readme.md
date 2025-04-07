Inputs a and b are sequence with length 128 (expand to 256 for non acyclic convolution), value of
elements are between [0,255]
gen.cpp is to generate a,b sequence (length 256 including padding 0) randomly.

BasicConv.cpp is brute force convolution, O(n^2)
DFTConv.cpp is brute force DFT, O(n^2)
NTTConv.cpp is O(nlogn).

preset_ntt.cpp is to generate "good" prime and corresponding primitive root for NTT kernel.
(in case you want to use larger sequence, you have to change mod and prt.)

In NTTConv, using Chinese Remainder Theorem to combine the results under different prime setting.
If the result value range is heigher than 257x12289 (input value range is larger than 255), you have to 
choose larger prime.

Use "make" to generate test cases, run NTT method and verify with brute force method, results are 
in the "test_cases" folder.
