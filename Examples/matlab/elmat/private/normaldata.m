function varargout = normaldata(varargin)
% NORMALDATA Array of arbitrary data from standard normal distribution
%     A = GALLERY('normaldata',[M,N,...],J) returns an M-by-N-by-... array
%     A. The values of A are a random sample from the standard normal
%     distribution.  J must be an integer value in the interval [0,
%     2^32-1].  Calling GALLERY('normaldata', ...) with different values
%     of J will return different arrays.  Repeated calls to
%     GALLERY('normaldata',...) with the same size vector and J inputs will
%     always return the same array.
%
%     In any call to GALLERY('normaldata', ...) you can substitute
%     individual inputs M,N,... for the size vector input [M,N,...].  For
%     example, GALLERY('normaldata',[1,2,3,4],5) is equivalent to
%     GALLERY('normaldata',1,2,3,4,5).
% 
%     [A,B,...] = GALLERY('normaldata',[M,N,...],J) returns multiple
%     M-by-N-by-... arrays A, B, ..., containing different values.
%  
%     A = GALLERY('normaldata',[M,N,...],J, CLASSNAME)  produces a matrix
%     of class CLASSNAME. CLASSNAME must be either 'single' or 'double'.
% 
%     Examples:
%        Generate the arbitrary 6-by-4 matrix of data from the standard
%        normal distribution N(0, 1) corresponding to J = 2.
%           x = gallery('normaldata', [6, 4], 2);
%
%        Generate the arbitrary 1-by-2-by-3 single array of data from the
%        standard normal distribution N(0, 1) corresponding to J = 17.
%           y = gallery('normaldata', 1, 2, 3, 17, 'single');
%      
%     See also PRIVATE/INTEGERDATA, PRIVATE/UNIFORMDATA, RANDN. 

%    Copyright 2009 The MathWorks, Inc.

if nargin <= 1
    error(message('MATLAB:normaldata:NotEnoughInputs'));
end
outputClass = 'double';
offset = 0;
if ischar(varargin{end})
    if nargin == 2
        error(message('MATLAB:normaldata:NoJValue'));
    end
    outputClass = varargin{end};
    offset = 1;
end
stream = RandStream('shr3cong','Seed',varargin{end-offset});
% By the way GALLERY calls normaldata, nargout is always >= 1
for i=1:nargout
    varargout{i}=randn(stream,varargin{1:end-1-offset},outputClass);
end
