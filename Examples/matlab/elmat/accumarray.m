%  ACCUMARRAY Construct an array by accumulation.
%   A = ACCUMARRAY(SUBS,VAL) creates an array A by accumulating elements of the
%   vector VAL using the subscripts in SUBS.  Each row of the M-by-N matrix
%   SUBS defines an N-dimensional subscript into the output A.  Each element of
%   VAL has a corresponding row in SUBS.  ACCUMARRAY collects all elements of
%   VAL that correspond to identical subscripts in SUBS, sums those values, and
%   stores the result in the element of A corresponding to the subscript.
%   Elements of A that are not referred to by any row of SUBS contain zero.
%
%   SUBS must contain positive integers.  If SUBS is a nonempty matrix with N>1
%   columns, then A is a N-dimensional array of size MAX(SUBS,[],1).  If SUBS is
%   empty with N>1 columns, then A is an N-dimensional empty array with size
%   0-by-0-by-...-by-0.  SUBS may also be a column vector, and A is then also a
%   column vector.  In this case, A has length MAX(SUBS,[],1) when SUBS is
%   nonempty, or length zero when SUBS is empty.
%
%   SUBS may also be a cell vector with one or more elements, each a vector of
%   positive integers.  All of the vectors must have the same length.  In this
%   case, SUBS is treated as if the vectors formed columns of a subscript matrix.
%
%   VAL must be a numeric, logical, or character vector with the same length
%   as the number of rows in SUBS.  VAL may also be a scalar whose value is
%   repeated for all the rows of SUBS.
%
%   ACCUMARRAY sums values from VAL using the default behavior of SUM.
%
%   A = ACCUMARRAY(SUBS,VAL,SZ) creates an array A with size SZ, where SZ is a
%   vector of positive integers.  If SUBS is nonempty with N>1 columns, then SZ
%   must have N elements, where ALL(SZ >= MAX(SUBS,[],1)).  If SUBS is a nonempty
%   column vector, then SZ must be [M 1] where M >= MAX(SUBS).  Specify SZ as
%   [] for the default behavior.
%
%   A = ACCUMARRAY(SUBS,VAL,SZ,FUN) applies the function FUN to each subset of
%   elements of VAL.  FUN is a function that accepts a column vector and returns
%   a numeric, logical, or char scalar, or a scalar cell.  A has the same class
%   as the values returned by FUN.  FUN is @SUM by default.  Specify FUN as []
%   for the default behavior.
%
%   Note: If the subscripts in SUBS are not sorted, FUN should not depend on the
%   order of the values in its input data.
%
%   A = ACCUMARRAY(SUBS,VAL,SZ,FUN,FILLVAL) puts the scalar value FILLVAL in
%   elements of A that are not referred to by any row of SUBS.  For example, if
%   SUBS is empty, then A is REPMAT(FILLVAL,SZ).  FILLVAL and the values returned
%   by FUN must have the same class.
%
%   A = ACCUMARRAY(SUBS,VAL,SZ,FUN,FILLVAL,ISSPARSE) creates an array A that is
%   sparse if the logical scalar ISSPARSE is true, or full if ISSPARSE is false.
%   A is full by default.  FILLVAL must be zero or [] if ISSPARSE is true.  VAL
%   and the output of FUN must be double if ISSPARSE is true.
%
%   Examples:
%
%   Create a 4-by-1 vector, summing values for repeated 1-D subscripts:
%      subs = [1; 2; 4; 2; 4];
%      A = accumarray(subs, 101:105)
%
%   Create a 2-by-3-by-2 array, summing values for repeated 3-D subscripts:
%      subs = [1 1 1; 2 1 2; 2 3 2; 2 1 2; 2 3 2];
%      A = accumarray(subs, 101:105)
%
%   Create a 2-by-3-by-2 array, summing values natively:
%      subs = [1 1 1; 2 1 2; 2 3 2; 2 1 2; 2 3 2];
%      A = accumarray(subs, int8(101:105), [], @(x) sum(x,'native'))
%      class(A)
%
%   Create an array using MAX, and fill empty elements with NaN:
%      subs = [1 1; 2 1; 2 3; 2 1; 2 3];
%      A = accumarray(subs, 101:105, [2 4], @max, NaN)
%
%   Create a sparse matrix using PROD:
%      subs = [1 1; 2 1; 2 3; 2 1; 2 3];
%      A = accumarray(subs, 101:105, [2 4], @prod, 0, true)
%
%   Count the number of subscripts for each bin:
%      subs = [1 1; 2 1; 2 3; 2 1; 2 3];
%      A = accumarray(subs, 1, [2 4])
%
%   Create a logical array indicating bins with two or more values:
%      subs = [1 1; 2 1; 2 3; 2 1; 2 3];
%      A = accumarray(subs, 101:105, [2 4], @(x) length(x)>1)
%
%   Group values in a cell array:
%      subs = [1 1; 2 1; 2 3; 2 1; 2 3];
%      A = accumarray(subs, 101:105, [2 4], @(x) {x})
%      A{2}
%
%   See also FULL, SPARSE, SUM, FUNCTION_HANDLE.

%   Copyright 1984-2014 The MathWorks, Inc.
%   Built-in function.

