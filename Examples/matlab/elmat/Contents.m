% Elementary matrices and matrix manipulation.
%
% Elementary matrices.
%   zeros       - Zeros array.
%   ones        - Ones array.
%   eye         - Identity matrix.
%   repmat      - Replicate and tile array.
%   repelem     - Replicate elements of an array.
%   linspace    - Linearly spaced vector.
%   logspace    - Logarithmically spaced vector.
%   freqspace   - Frequency spacing for frequency response.
%   meshgrid    - X and Y arrays for 3-D plots.
%   accumarray  - Construct an array with accumulation.
%   :           - Regularly spaced vector and index into matrix.
%
% Basic array information.
%   size        - Size of array.
%   length      - Length of vector.
%   ndims       - Number of dimensions.
%   numel       - Number of elements.
%   disp        - Display matrix or text.
%   isempty     - True for empty array.
%   isequal     - True if arrays are numerically equal.
%   isequaln    - True if arrays are numerically equal, treating NaNs as equal.
%
% Matrix manipulation.
%   cat         - Concatenate arrays.
%   reshape     - Reshape array.
%   diag        - Diagonal matrices and diagonals of matrix.
%   blkdiag     - Block diagonal concatenation.
%   tril        - Extract lower triangular part.
%   triu        - Extract upper triangular part.
%   fliplr      - Flip matrix in left/right direction.
%   flipud      - Flip matrix in up/down direction.
%   flip        - Flip the order of elements.
%   rot90       - Rotate matrix 90 degrees.
%   :           - Regularly spaced vector and index into matrix.
%   find        - Find indices of nonzero elements.
%   end         - Last index.
%   sub2ind     - Linear index from multiple subscripts.
%   ind2sub     - Multiple subscripts from linear index.
%   bsxfun      - Binary singleton expansion function.
%
% Multi-dimensional array functions.
%   ndgrid      - Generate arrays for N-D functions and interpolation.
%   permute     - Permute array dimensions.
%   ipermute    - Inverse permute array dimensions.
%   shiftdim    - Shift dimensions.
%   circshift   - Shift array circularly.
%   squeeze     - Remove singleton dimensions.
%
% Array utility functions.
%   isscalar    - True for scalar.
%   isvector    - True for vector.
%   isrow       - True for row vector.
%   iscolumn    - True for column vector.
%   ismatrix    - True for matrix.
%
% Special variables and constants.
%   eps         - Floating point relative accuracy.
%   realmax     - Largest positive floating point number.
%   realmin     - Smallest positive floating point number.
%   intmax      - Largest positive integer value.
%   intmin      - Smallest integer value.
%   flintmax    - Largest consecutive integer in floating point format.
%   pi          - 3.1415926535897....
%   i           - Imaginary unit.
%   inf         - Infinity.
%   nan         - Not-a-Number.
%   isnan       - True for Not-a-Number.
%   isinf       - True for infinite elements.
%   isfinite    - True for finite elements.
%   j           - Imaginary unit.
%   true        - True array.
%   false       - False array.
%
% Specialized matrices.
%   compan      - Companion matrix.
%   gallery     - Test matrices.
%   hadamard    - Hadamard matrix.
%   hankel      - Hankel matrix.
%   hilb        - Hilbert matrix.
%   invhilb     - Inverse Hilbert matrix.
%   magic       - Magic square.
%   pascal      - Pascal matrix.
%   rosser      - Classic symmetric eigenvalue test problem.
%   toeplitz    - Toeplitz matrix.
%   vander      - Vandermonde matrix.
%   wilkinson   - Wilkinson's eigenvalue test matrix.

%   isequalwithequalnans - True if arrays are numerically equal.

% Functions that will be removed.
%   flipdim     - Flip matrix along specified dimension.

%   Copyright 1984-2013 The MathWorks, Inc.


