function y = vertcat(varargin)
%VERTCAT Vertical concatenation of fi objects
%   Y = VERTCAT(X1,X2,X3,...) is called for the syntax '[X1; X2; X3; ...]'
%   when any of X1, X2, X3, etc. is an object.
%
%   [A;B] is the vertical concatenation of matrices A and B.  A and B must
%   have the same number of columns. Any number of matrices can be
%   concatenated within one pair of brackets.  
%
%   The fimath and numerictype properties of a concatenated matrix of fi 
%   objects are taken from the leftmost fi object in the list (X1 X2 X3 ..)
%
%   See also EMBEDDED.FI/HORZCAT

%   Thomas A. Bryan, 6 February 2003
%   Copyright 2003-2017 The MathWorks, Inc.
%     

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin==1
    y = varargin{1};
    return
elseif any(cellfun(@iscell,varargin))
    % cell array wins if input has mixed cell array and fi objects
    for k=1:nargin
        if isfi(varargin{k})
            varargin{k} = {varargin{k}};    
        end
    end
    y = vertcat(varargin{:}); %call MATLAB's vertcat function
    return;
else
    y = emptyfirstobj(varargin{:});
end

T = numerictype(y);
F = fimath(y);

for k=1:length(varargin)
  % In Y = [A  B]
  % Positive elements J(k) correspond to A(J(k))
  % Negative elements J(k) correspond to B(J(k))
  % Zero     elements J(k) correspond to fill
  if ~isfi(varargin{k})
    varargin{k} = embedded.fi(double(varargin{k}),T,F);
  end
  J =  reshape(1:numberofelements(y),size(y));
  K = -reshape(1:numberofelements(varargin{k}),size(varargin{k}));
  J = [J; K];
  y = subscriptedgrowassignment(y,J,varargin{k});
end
