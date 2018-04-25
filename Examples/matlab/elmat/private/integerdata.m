function varargout = integerdata(varargin)
%INTEGERDATA Array of arbitrary data from uniform distribution on specified range of integers
%     A = GALLERY('integerdata',IMAX,[M,N,...],J) returns an M-by-N-by-...
%     array A whose values are a sample from the uniform distribution on
%     the integers 1:IMAX.  J must be an integer value in the interval [0,
%     2^32-1].  Calling GALLERY('integerdata', ...) with different values
%     of J will return different arrays.  Repeated calls to
%     GALLERY('integerdata',...) with the same IMAX, size vector and J
%     inputs will always return the same array.
%
%     In any call to GALLERY('integerdata', ...) you can substitute
%     individual inputs M,N,... for the size vector input [M,N,...].  For
%     example, GALLERY('integerdata',7,[1,2,3,4],5) is equivalent to
%     GALLERY('integerdata',7,1,2,3,4,5).
% 
%     A = GALLERY('integerdata',[IMIN IMAX],[M,N,...],J) returns an
%     M-by-N-by-... array A whose values are a sample from the uniform
%     distribution on the integers IMIN:IMAX.
% 
%     [A,B,...] = GALLERY('integerdata',[IMIN IMAX],[M,N,...],J) returns
%     multiple M-by-N-by-... arrays A, B, ..., containing different
%     values.
%  
%     A = GALLERY('integerdata',[IMIN IMAX],[M,N,...],J,CLASSNAME) produces
%     an array of class CLASSNAME. CLASSNAME must be 'uint8', 'uint16',
%     'uint32', 'int8', 'int16', int32', 'single' or 'double'.
%      
%     Examples:
%        Generate the arbitrary 6-by-4 matrix of integers between 1 and 6
%        inclusive corresponding to J = 2.
%           x = gallery('integerdata', 6, [6, 4], 2);
%
%        Generate the arbitrary 1-by-2-by-3 uint8 array of integers
%        between 10 and 20 inclusive corresponding to J = 17.
%           y = gallery('integerdata', [10 20], 1, 2, 3, 17, 'uint8');
%
%     See also PRIVATE/NORMALDATA, PRIVATE/UNIFORMDATA, RANDI. 

%     Copyright 2009 The MathWorks, Inc.

if nargin < 3
    error(message('MATLAB:integerdata:NotEnoughInputs'));
end
outputClass = 'double';
offset = 0;
if ischar(varargin{end})
    if nargin < 4
        error(message('MATLAB:integerdata:NoJValue'));
    end
    outputClass = varargin{end};
    offset = 1;
end

stream = RandStream('swb2712','Seed',varargin{end-offset});
% By the way GALLERY calls integerdata, nargout is always >= 1
for i=1:nargout
    varargout{i}=randi(stream,varargin{1:end-1-offset},outputClass);
end
