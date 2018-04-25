function varargout = uniformdata(varargin)
%UNIFORMDATA Array of arbitrary data from standard uniform distribution
%     A = GALLERY('uniformdata',[M,N,...],J) returns an M-by-N-by-... array
%     A. The values of A are a random sample from the standard uniform
%     distribution.  J must be an integer value in the interval [0,
%     2^32-1].  Calling GALLERY('uniformdata', ...) with different values
%     of J will return different arrays.  Repeated calls to
%     GALLERY('uniformdata',...) with the same size vector and J inputs
%     will always return the same array.
%
%     In any call to GALLERY('uniformdata', ...) you can substitute
%     individual inputs M,N,... for the size vector input [M,N,...].  For
%     example, GALLERY('uniformdata',[1,2,3,4],5) is equivalent to
%     GALLERY('uniformdata',1,2,3,4,5).
% 
%     [A,B,...] = GALLERY('uniformdata',[M,N,...],J) returns multiple
%     M-by-N-by-... arrays A, B, ..., containing different values.
%  
%     A = GALLERY('uniformdata',[M,N,...],J, CLASSNAME) produces a matrix
%     of class CLASSNAME. CLASSNAME must be either 'single' or 'double'.
%      
%     Examples:
%        Generate the arbitrary 6-by-4 matrix of data from the uniform
%        distribution on [0, 1] corresponding to J = 2.
%           x = gallery('uniformdata', [6, 4], 2);
%
%        Generate the arbitrary 1-by-2-by-3 single array of data from the
%        uniform distribution on [0, 1] corresponding to J = 17.
%           y = gallery('uniformdata', 1, 2, 3, 17, 'single');
%      
%     See also PRIVATE/INTEGERDATA, PRIVATE/NORMALDATA, RAND.

%    Copyright 2009 The MathWorks, Inc.


if nargin <= 1
    error(message('MATLAB:uniformdata:NotEnoughInputs'));
end
outputClass = 'double';
offset = 0;
if ischar(varargin{end})
    if nargin == 2
        error(message('MATLAB:uniformdata:NoJValue'));
    end
    outputClass = varargin{end};
    offset = 1;
end
stream = RandStream('swb2712','Seed',varargin{end-offset});
% By the way GALLERY calls uniformdata, nargout is always >= 1
for i=1:nargout
    varargout{i}=rand(stream,varargin{1:end-1-offset},outputClass);
end
