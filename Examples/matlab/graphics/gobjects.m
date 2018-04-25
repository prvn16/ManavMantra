function array = gobjects(varargin)
%GOBJECTS    Return a default graphics object array.
%   GOBJECTS(N) returns a N-by-N matrix of default graphics objects. 
%
%   GOBJECTS(M,N) or GOBJECTS([M,N]) returns a M-by-N matrix of 
%   default graphics objects.
%
%   GOBJECTS(M,N,P,...) or GOBJECTS([M,N,P ...]) returns a 
%   M-by-N-by-P-by-... array of default graphics objects.
%
%   GOBJECTS(SIZE(A)) creates an array of default graphics objects 
%   and is the same size as A.
%
%   GOBJECTS with no arguments creates a 1-by-1 scalar default graphics 
%   object.
%
%   GOBJECTS(0) with input of zero creates a 0-by-0 empty default graphics 
%   object array.
%
%   Note: The size inputs M, N, and P... should be nonnegative integers. 
%   Negative integers are treated as 0, and non-integers are truncated. 
%
%   Example:
%      x = gobjects(2,3)      returns a 2-by-3 default graphics object array
%      x = gobjects([1,2,3])  returns a 1-by-2-by-3 default graphics object array
%
%   See also ZEROS , ONES

%   Copyright 1984-2014 The MathWorks, Inc.

   %------- function call with no-input -------
   if nargin == 0
       array = matlab.graphics.GraphicsPlaceholder();
       return;
   end
   
   % -----Ensure that all inputs are numeric -----------  
   % catch gobjects('b')   gobjects([2,'b']) gobjects(2,'b')   gobjects([])      gobjects([5;5])
   %       gobjects({1,2}) gobjects({'a'})   gobjects(2,['a']) gobjects(1,[2,3])
   %       gobjects(2,{2})
   % reject if the contents in the varargin is non-numeric (eg: char,cell)
   errFlag = false;
   if nargin == 1
       if ( ~isnumeric(varargin{1}) || isempty(varargin{1})||~isrow(varargin{1}))
            errFlag = true ; 
       end
   else
       for iter = 1 : nargin
            if ~isnumeric(varargin{iter})
                errFlag = true ;
                break ;
            end
            % gobjects is consistent with zeros and ones in its treatments of non-scalar inputs
            if ~isscalar(varargin{iter})
                 errFlag = true;
            end 
       end
   end
   
   
   % For all above error, using the same error message  
   if errFlag
       error('MATLAB:graphics:gobjects:invalidinput','Inputs must be scalar numeric or a vector of array dimensions.');
   end
   
   
   
   dims = [varargin{:}];
   %---- Ensure there are no nan and inf inputs
   if any(isinf(dims)) || any(isnan(dims))
       error('MATLAB:graphics:gobjects:naninf','Inputs must be scalar numeric or a vector of array dimensions. NaN and Inf are not allowed.');
   end
   
  
   %----- Replace negative inputs to zero and truncate non-integer inputs---
   dims(dims < 0) = 0; % catch negative numbers
   tmp = floor(dims);  % catch positive non-integers
   if any(tmp~=dims)
      error('MATLAB:graphics:gobjects:noninteger','Size vector should be a row vector with integer elements.');
   end

   
     
   if isscalar(dims)% ----- Single input such as gobjects(0) gobjects(6) ----- 
       if dims == 0
           array = matlab.graphics.GraphicsPlaceholder().empty;
           return ;
       else 
           array(dims, dims) = matlab.graphics.GraphicsPlaceholder();

           return ; 
       end
   else            % if not scalar Multiple inputs like gobjects(6,6,6)
           array = repmat(matlab.graphics.GraphicsPlaceholder(),dims);
           return;
   end 
