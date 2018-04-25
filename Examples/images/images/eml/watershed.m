function L = watershed(varargin) %#codegen
%Copyright 2014 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(1,2);
A = varargin{1};
validateattributes(A,{'numeric' 'logical'}, {'real' 'nonsparse'}, ...
              mfilename, 'A', 1); 
coder.internal.errorIf(~ismatrix(A),'images:validate:twoDimensionalImageSupport','watershed');

if(isempty(A))
    L = uint16([]);
    return;
end

if nargin==2
    coder.internal.errorIf(~eml_is_const(varargin{2}),...
        'images:validate:connNotConst');
    conn = varargin{2};
    coder.internal.errorIf(~isscalar(conn),'images:watershed:limitedConn');
    coder.internal.errorIf((conn~=4)&&(conn~=8),'images:watershed:limitedConn');
    if(conn==4)
        connb = logical([0 1 0; 1 0 1; 0 1 0]);
    else %conn==8
        connb = logical([1 1 1; 1 0 1; 1 1 1]);
    end
else
    conn = 8;
    connb = logical([1 1 1; 1 0 1; 1 1 1]);
end

[Lin, numConns] = bwlabel(imregionalmin(A, conn), conn);
coder.internal.errorIf(numConns>=65536,'images:watershed:tooManyRegions');

% Image Properties
sizeA = size(A);
numelA = numel(A);

% Use only uint16 output datatype
L = uint16(Lin);


np = images.internal.coder.NeighborhoodProcessor(sizeA, connb); %Default neighboorhood processor uses bottom right
np.updateInternalProperties();

queue = images.internal.coder.FifoPriorityQueue(numelA);

S = false(numelA,1);
WSHED = 0;

for i = 1:numelA
    if(L(i)~=WSHED)
        S(i) = true;
        neighbors = np.getNeighborIndices(i);
        for j = 1:numel(neighbors)
            if(~S(neighbors(j)) && L(neighbors(j))==WSHED)
                S(neighbors(j)) = true;
                queue.push(neighbors(j),A(neighbors(j)));
            end
        end
    end
end

while(~queue.isempty())
    [d,p] = queue.pop();
    watershedState = false;
    label = WSHED;
    neighbors = np.getNeighborIndices(d);
    for j = 1:numel(neighbors)
        if(~watershedState && L(neighbors(j))~=WSHED)
            if(label~=WSHED && L(neighbors(j))~=label)
                watershedState = true;
            else
                label = double(L(neighbors(j)));
            end
        end
    end
    if(~watershedState)
        L(d) = label;
        for j = 1:numel(neighbors)
            if (~S(neighbors(j)))
                S(neighbors(j)) = true;
                queue.push(neighbors(j), max(A(neighbors(j)),p));
            end
        end
    end
end