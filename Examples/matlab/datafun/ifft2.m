function x = ifft2(varargin)
%IFFT2 Two-dimensional inverse discrete Fourier transform.
%   IFFT2(F) returns the two-dimensional inverse Fourier transform of matrix
%   F.  If F is a vector, the result will have the same orientation.
%
%   IFFT2(F,MROWS,NCOLS) pads matrix F with zeros to size MROWS-by-NCOLS
%   before transforming.
%
%   IFFT2(..., 'symmetric') causes IFFT2 to treat F as conjugate symmetric
%   in two dimensions so that the output is purely real.  This option is
%   useful when F is not exactly conjugate symmetric merely because of
%   round-off error.  See the reference page for the specific mathematical
%   definition of this symmetry.
%
%   IFFT2(..., 'nonsymmetric') causes IFFT2 to make no assumptions about the
%   symmetry of F.
%
%   Class support for input F:
%      float: double, single
%
%   See also FFT, FFT2, FFTN, FFTSHIFT, FFTW, IFFT, IFFTN.

%   Copyright 1984-2010 The MathWorks, Inc. 

narginchk(1,4)

f = varargin{1};
m_in = size(f, 1);
n_in = size(f, 2);
num_inputs = numel(varargin);
symmetry = 'nonsymmetric';

if isstring(varargin{end}) || ischar(varargin{end})
    symmetry = varargin{end};
    num_inputs = num_inputs - 1;
end

if num_inputs == 1
    m_out = m_in;
    n_out = n_in;

elseif num_inputs == 2
    error(message('MATLAB:ifft2:invalidSyntax'))
    
elseif num_inputs == 3
    m_out = double(varargin{2});
    n_out = double(varargin{3});
else
    error(message('MATLAB:ifft2:InvalidTrailingStringArgument'));
end

if ~isa(f, 'float')
    f = double(f);
end

if (m_out ~= m_in) || (n_out ~= n_in)
    out_size = size(f);
    out_size(1) = m_out;
    out_size(2) = n_out;
    f2 = zeros(out_size, class(f));
    mm = min(m_out, m_in);
    nn = min(n_out, n_in);
    f2(1:mm, 1:nn, :) = f(1:mm, 1:nn, :);
    f = f2;
end

if ismatrix(f)
    x = ifftn(f, symmetry);
else
    x = ifft(ifft(f, [], 2), [], 1, symmetry);
end   


