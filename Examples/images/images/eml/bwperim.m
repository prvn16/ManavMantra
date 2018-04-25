function pout = bwperim(varargin) %#codegen
%Copyright 2014 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(1,2);
b = varargin{1};

validateattributes(b, {'logical' 'numeric'}, {'nonsparse','2d'}, ...
              mfilename, 'BW', 1);
if ~islogical(b)
    inp = b ~= 0;
else
    inp = b;
end

coder.internal.errorIf(nargout == 0,'images:bwperim:unsupportedSyntax');

if nargin < 2
    conn = [0 1 0; 1 1 1; 0 1 0];
else
    conn = varargin{2};
    iptcheckconn(conn,mfilename,'CONN',2);
end
connb = coder.const(ScalarToArray(conn));

% If it's a 2-D problem with 4- or 8-connectivity, use
% bwmorph --- it works without padding the input.
if isequal(connb, [0 1 0; 1 1 1; 0 1 0])
    pout = bwmorph(inp,'perim4');
    
elseif isequal(connb, ones(3,3))
    pout = bwmorph(inp,'perim8');
    
else
    % Use a general technique that works for any dimensionality
    % and any connectivity.
    inpPadded = padarray(inp,ones(1,2),0,'both');
    b_eroded = imerode(inpPadded,connb);
    p = inpPadded & ~b_eroded;
    pout = p(2:(size(p,1)-1),2:(size(p,2)-1));
end


% ================ ScalarToArray ========================
function conn_out = ScalarToArray(conn)

if numel(conn) == 1
    switch conn
      case 1
        conn_out = 1;
        
      case 4
        conn_out = [0 1 0; 1 1 1; 0 1 0];
        
      case 8
        conn_out = ones(3,3);
        
      otherwise
       %% error(message('images:bwperim:unexpectedConnValue'));
    end
else
    conn_out = conn;
end
