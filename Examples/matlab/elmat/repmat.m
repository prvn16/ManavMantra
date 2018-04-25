%REPMAT Replicate and tile an array.
%   B = REPMAT(A,M,N) or B = REPMAT(A,[M,N]) creates a large matrix B 
%   consisting of an M-by-N tiling of copies of A. If A is a matrix, 
%   the size of B is [size(A,1)*M, size(A,2)*N].
%
%   B = REPMAT(A,N) creates an N-by-N tiling.  
%   
%   B = REPMAT(A,P1,P2,...,Pn) or B = REPMAT(A,[P1,P2,...,Pn]) tiles the array 
%   A to produce an n-dimensional array B composed of copies of A. The size 
%   of B is [size(A,1)*P1, size(A,2)*P2, ..., size(A,n)*Pn].
%   If A is m-dimensional with m > n, an m-dimensional array B is returned.
%   In this case, the size of B is [size(A,1)*P1, size(A,2)*P2, ..., 
%   size(A,n)*Pn, size(A, n+1), ..., size(A, m)].
%
%   REPMAT(A,M,N) when A is a scalar is commonly used to produce an M-by-N
%   matrix filled with A's value and having A's CLASS. For certain values,
%   you may achieve the same results using other functions. Namely,
%      REPMAT(NAN,M,N)           is the same as   NAN(M,N)
%      REPMAT(SINGLE(INF),M,N)   is the same as   INF(M,N,'single')
%      REPMAT(INT8(0),M,N)       is the same as   ZEROS(M,N,'int8')
%      REPMAT(UINT32(1),M,N)     is the same as   ONES(M,N,'uint32')
%      REPMAT(EPS,M,N)           is the same as   EPS(ONES(M,N))
%
%   Example:
%       repmat(magic(2), 2, 3)
%       repmat(uint8(5), 2, 3)
%
%   Class support for input A:
%      float: double, single
%      integer: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      char, logical
%
%   See also BSXFUN, MESHGRID, ONES, ZEROS, NAN, INF.

%   Copyright 1984-2013 The MathWorks, Inc.
