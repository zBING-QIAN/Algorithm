
# SA-IS 後綴數組 O(n)

透過兩次 induced sorting 構造後綴數組。  
第一次 induced sorting 時 LMS 是 unsorted，所以結果只能用來判斷 LMS 之間的大小。  
第二次 induced sorting 使用正確的 LMS 順序才能排出正確的 suffix array (SA)。  

## Short Example:
```
     g a c g a b (0)
     L S S L S L  S
RANK 5 1 3 4 0 2
SA   4 1 5 2 3 0  correct ! 
     4 1 5 2 0 3  fail ! -> without second induced sorting
```

## Induced Sorting :
*請先熟悉 bucket sort

核心概念是透過觀察：
1. 遞增子序列 (S-type) 的前項會小於後項。
2. 遞減子序列 (L-type) 的後項會小於前項。

從遞增子序列的開頭 (Left Most S-type a.k.a. LMS) 往前，依序先碰到 L-type (因為是從後往前數所以反過來看是遞增)，再碰到 S-type (因為是從後往前數所以反過來看是遞減)。  
再觀察相同的字首 L-type 會小於 S-type  (例如：`fe < fg`)。

想要用 bucket sort 排序必須把 LMS 先放進各自字首的桶尾。  
(LMS 也是 S-type -> 必定大於 L-type，所以放桶尾不會被覆蓋到，如果 LMS 已排序，放進桶尾的順序要一致)

- 假設 LMS 是排序的 (一般來說第一次 induced sorting 時不是) -> **正確的 SA**。
- 否則 -> **只能用來比較 LMS 子串的大小**，即使 LMS 子串都不同也要再做一次 (仔細觀察前面的例子)。


剛好從 LMS 往前找 L-type 會是遞增的 (原字串裡 LMS 前一個位置一定是 L-type)，  
-> 從順序最小的桶前端依序檢查該位置的前面一個是不是 L-type，如果是就將其放入對應字首的桶中。  
(L-type 的特性 -> 放入的桶會是當前處理的桶或排序較後的桶，如果是當前的桶，放入的位置也會是當前處理的位置的後面)  

相反的 S-type 則會從以排序的 L-type 由後往前檢查 (遞減的順序放入 bucket 中，放入的位置也會是當前處理的位置的前面)。


## Sort LMS:
使用 SA-IS **遞迴處理**。

---

## SA-IS 的流程:

1. 決定 L/S type，並標示出 LMS。
2. **First induced sorting** (決定 LMS 子串的大小關係)。
3. 檢查有沒有相同的 LMS 子串：
```
    pos      0 1 2 3 4 5
    arr      g a c a c (0)    
    type     L S L S L S
    LMS POS  1 3 5     (LMS at 1 and 3 are the same "g(ac)ac <=> gac(ac)")
    LMS      1 1 0
```
4. 如果有相同 LMS 子串 -> **遞迴處理 LMS 得到 LMS 的 SA**。
5. **Second induced sorting** (跟第一次不一樣的點是使用 LMS 的 SA 的順序放入初始桶中)。

---
