%SUBSASGN Subscripted assignment.
%   A(I) = B assigns the values of B into the elements of A specified by 
%   the subscript vector I. B must have the same number of elements as I or
%   be a scalar. 
%   A(I,J) = B assigns the values of B into the elements of the rectangular 
%   submatrix of A specified by the subscript vectors I and J. B must
%   have LENGTH(I) rows and LENGTH(J) columns. 
%   A colon used as a subscript, as in A(I,:) = B or A(:,I) = B indicates 
%   the entire column or row.
%   For multidimensional arrays, A(I,J,K,...) = B assigns B to the 
%   specified elements of A. 
%   B must be length(I)-by-length(J)-by-length(K)-... or be shiftable to 
%   that size by adding or removing singleton dimensions.
%   A = subsasgn(A,S,B) is called for the syntax A(I)=B, A{I}=B, or A.I=B 
%   when A is an object. S is a structure array with the fields:
%   a) type - String containing '()', '{}', or '.' specifying the 
%              subscript type
%   b) subs - Cell array or string containing the actual subscripts
%   For instance, the syntax A(1:2,:) = B calls A=SUBSASGN(A,S,B) where S 
%   is a 1-by-1 structure with S.type='()' and S.subs = {1:2,':'}. A colon 
%   used as a subscript is passed as the string ':'.
%   For fi objects A and B, there is a difference between A = B and 
%   A(:) = B. In the first case, A = B replaces A with B, and A assumes the
%   value, numerictype property, and fimath property associated with B. In the 
%   second case, A(:) = B assigns the value of B into A while keeping the numerictype 
%   property of A. You can use this to cast a value with one numerictype property 
%   into another numerictype property.
%
%   Example: Cast a 16-bit number into an 8-bit number
%   a = fi(0, 1, 8, 7)
%   b = fi(pi/4, 1, 16, 15)
%   % b has value pi/4 or 0.7854 in 16 bit representation
%   a(:) = b
%   % a has value .7891 because of truncation from 16 to 8 bits during the 
%   % cast 
%
%   In this kind of assignment operation, the fimath properties associated with A 
%   and B can be different. A common use for this is when casting the result of an 
%   accumulation to an output data type, where the two have different 
%   rounding and overflow modes. Another common use is in a series of 
%   multiply/accumulate operations. For example:
%     for k = 1:n
%	    acc(1) = acc + b * x(k)
%     end
%
%   See also SUBSASGN, EMBEDDED.FI/SUBSINDEX

%   Copyright 1999-2012 The MathWorks, Inc.
