%SORT Sort strings in ascending or descending order
%   NEWSTR = SORT(STR) sorts the string elements of STR in ascending order. 
%   If STR is an M-by-N string array, SORT(STR) sorts each column of STR. If STR 
%   is a multidimensional array, SORT(STR) sorts along the first dimension whose 
%   size does not equal 1.
%
%   MATLAB stores characters as Unicode using the UTF-16 character encoding scheme. 
%   SORT sorts strings according to the UTF-16 code point order. For the characters 
%   that are also the ASCII characters, this order means that uppercase letters come before 
%   lowercase letters. Digits and many punctuation marks also come before letters.
%
%   NEWSTR = SORT(STR,DIM) sorts STR along dimension DIM. For N dimensions, DIM is an 
%   integer between 1 and N.
%
%   NEWSTR = SORT(STR,DIM,DIRECTION) sorts in the order specified by DIRECTION. 
%   DIRECTION is 'ascend' for ascending order, or 'descend' for descending order.
%
%   NEWSTR = SORT(STR,...,'MissingPlacement',M) specifies where to place the
%   missing elements (<missing>) of STR. M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements first.
%       'last'  - Places missing elements last.
%
%   [NEWSTR,I] = SORT(STR,...) also returns an index matrix I. If STR is a
%   vector, then NEWSTR = STR(I). If STR is an M-by-N array and DIM = 1, then
%   NEWSTR(:,j) = STR(I(:,j),j) for j = 1:N.
%
%   Example:
%       STR = ["Jones","de Paul","Evans"];
%       sort(STR)                         
%
%           "Evans"    "Jones"    "de Paul"
%
%   Example:
%       STR = ["Jones","Evans";"de Paul","Smith"];
%       sort(STR,2)                       
%
%       returns  
%
%           "Evans"    "Jones"  
%           "Smith"    "de Paul"
%
%      sort(STR,'descend')
%
%      returns
%
%          "de Paul"    "Smith"
%          "Jones"      "Evans"
%
%      sort(STR,2,'descend')
%
%      returns
%
%          "Jones"      "Evans"
%          "de Paul"    "Smith"
%
%   See also ISSORTED.

%   Copyright 2015-2016 The MathWorks, Inc.
%   Built-in function.

