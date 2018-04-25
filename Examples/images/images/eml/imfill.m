function [I2,locations] = imfill(varargin) %#codegen

% Copyright 2012-2013 The MathWorks, Inc.

coder.internal.prefer_const(varargin);
%% Parse Inputs
if nargin < 1
    eml_invariant(false,...
        eml_message('images:validate:tooFewInputs','IMFILL'),...
        'IfNotConst','Fail');
end

if nargin > 3
    eml_invariant(false,...
        eml_message('images:validate:tooManyInputs','IMFILL'),...
        'IfNotConst','Fail');
end

I = varargin{1};
eml_invariant(numel(size(I)) <= 3,...
    eml_message('images:validate:tooManyDimensions','I','3'));
validateattributes(I, {'numeric' 'logical'}, {'nonsparse' 'real','nonnan'}, ...
    'imfill', 'I1 or BW1', 1); %#ok<EMCA>

do_fillholes = false;

switch nargin
    case 1
        conn = conndef(numel(size(I)),'minimal');
        locationsVar = [];
        locations = [];
        if islogical(I)
            % IMFILL(BW1)
            eml_invariant(false, ...
                eml_message('images:imfill:noInteractiveInCodegen'),...
                'IfNotConst','Fail')
        else
            % IMFILL(I1)
            do_fillholes = true;
        end
        
    case 2
        if islogical(I)
            conn = conndef(numel(size(I)),'minimal');
            if ischar(varargin{2})
                % IMFILL(BW1, 'holes')
                eml_invariant(eml_is_const(varargin{2}), ...
                    eml_message('images:imfill:holesStringNotConst'),...
                    'IfNotConst','Fail')
                validatestring(varargin{2}, {'holes'}, 'imfill', 'OPTION', 2);
                do_fillholes = true;
                locationsVar = [];
                locations = [];
            else
                % IMFILL(BW1, LOCATIONS)
                locationsVar = checkLocations(varargin{2}, size(I));
                locations = locationsVar;
            end
            
        else
            % IMFILL(I1, CONN)
            eml_invariant(eml_is_const(varargin{2}), ...
                eml_message('images:validate:connNotConst'),...
                'IfNotConst','Fail')
            iptcheckconn(varargin{2},'imfill','CONN',2);
            conn = varargin{2};
            do_fillholes = true;
            locationsVar = [];
            locations = [];
        end
        
    case 3
        if islogical(I)
            if ischar(varargin{3})
                % IMFILL(BW1,CONN,'holes')
                eml_invariant(eml_is_const(varargin{3}), ...
                    eml_message('images:imfill:holesStringNotConst'),...
                    'IfNotConst','Fail')
                validatestring(varargin{3}, {'holes'}, 'imfill', 'OPTION', 3);
                do_fillholes = true;
                eml_invariant(eml_is_const(varargin{2}), ...
                    eml_message('images:validate:connNotConst'),...
                    'IfNotConst','Fail')
                iptcheckconn(varargin{2},'imfill','CONN',2);
                conn = varargin{2};
                locationsVar = [];
                locations = [];
            else
                % IMFILL(BW1,0,CONN)
                eml_invariant(~isequal(varargin{2},0), ...
                    eml_message('images:imfill:noInteractiveInCodegen'));
                
                % IMFILL(BW1,LOCATIONS,CONN)
                locationsVar = checkLocations(varargin{2}, size(I));
                locations = locationsVar;
                eml_invariant(eml_is_const(varargin{3}), ...
                    eml_message('images:validate:connNotConst'),...
                    'IfNotConst','Fail')
                iptcheckconn(varargin{3},'imfill','CONN',3);
                conn = varargin{3};
            end
            
        else
            eml_invariant(false, eml_message('images:validate:invalidSyntax'),...
                'IfNotConst','Fail')
        end
        
    otherwise
        locationsVar = [];
        locations = [];
        conn = conndef(numel(size(I)),'minimal');
        eml_invariant(false, eml_message('images:validate:invalidSyntax'),...
            'IfNotConst','Fail')
end

coder.internal.prefer_const(do_fillholes);

% Convert to linear indices if necessary.
if ~do_fillholes && (size(locationsVar,2) ~= 1) && ~isempty(locationsVar)
    locations = lsub2ind(size(I), locationsVar);
elseif ~do_fillholes && (size(locationsVar,1) == 1)
    locations = locationsVar;
end


%% Algorithm
if isempty(I)
    I2 = I;
elseif do_fillholes
    if islogical(I)
        mask = uint8(I);
    else
        mask = I;
    end
    marker = mask;
    
    if isfloat(marker)
        marker(:) = eml_guarded_inf(class(marker));%Inf;
        padVal = -1*eml_guarded_inf(class(marker));%-Inf;
    else % Set to max/min value of non-float data types
        marker(:) = intmax(class(marker));
        padVal = intmin(class(marker));
    end
    
    if numel(size(I)) == 3
        maskPad = coder.nullcopy(zeros(size(I)+2,'like',mask));
        markerPad = coder.nullcopy(zeros(size(I)+2,'like',marker));
        
        maskPad(1:size(I,1)+2,1:size(I,2)+2,1:size(I,3)+2) = padarray(mask, ones(1,numel(size(mask))), padVal, 'both');
        markerPad(1:size(I,1)+2,1:size(I,2)+2,1:size(I,3)+2) = padarray(marker, ones(1,numel(size(marker))), padVal, 'both');
        
    else
        maskPad = coder.nullcopy(zeros(size(I)+2,'like',mask));
        markerPad = coder.nullcopy(zeros(size(I)+2,'like',marker));
        
        maskPad(1:size(I,1)+2,1:size(I,2)+2) = padarray(mask, ones(1,ndims(mask)), padVal, 'both');
        markerPad(1:size(I,1)+2,1:size(I,2)+2) = padarray(marker, ones(1,ndims(marker)), padVal, 'both');
        
    end
    
    idx = zeros(max(size(markerPad))-2,numel(size(I)));
    for k = 1:numel(size(I))
        M = size(markerPad,k)-2;
        idx(1:M,k) = 2:(size(markerPad,k) - 1);
    end
    
    maskPad = imcomplement(maskPad);
    markerPad = imcomplement(markerPad);
    
    I1 = imreconstruct(markerPad, maskPad, conn);
    I1 = imcomplement(I1);
    
    idx1 = sum(idx(:,1)~=0);
    idx2 = sum(idx(:,2)~=0);
    if numel(size(I)) == 3
        I2 = coder.nullcopy(eml_expand(eml_scalar_eg(I),[size(I1,1)-2,size(I1,2)-2,size(I1,3)-2]));
        idx3 = sum(idx(:,3)~=0);
        for i = 1:idx1
            for j = 1:idx2
                for k = 1:idx3
                    I2(i,j,k) = I1(idx(i,1),idx(j,2), idx(k,3));
                end
            end
        end
    else
        I2 = coder.nullcopy(eml_expand(eml_scalar_eg(I),[size(I1,1)-2,size(I1,2)-2]));
        for i = 1:idx1
            for j = 1:idx2
                I2(i,j) = I1(idx(i,1),idx(j,2));
            end
        end
    end
    
    if islogical(I)
        I2 = I2 ~= 0;
    end
    
else
    mask = imcomplement(I);
    marker = mask;
    marker(:) = cast(0,class(I));
    marker(locations) = mask(locations);
    marker = imreconstruct(marker, mask, conn);
    I2 = cast(I | marker,class(I));
end

%%
%% Helper functions
%%
function locationsVar = checkLocations(locations, image_size)
%   Checks validity of LOCATIONS.  Converts LOCATIONS to linear index
%   form.  Warns if any locations are out of range.

validateattributes(locations, {'double'}, {'real' 'positive' 'integer' '2d'}, ...
    'imfill', 'LOCATIONS', 2);

numDims = length(image_size);
if (size(locations,2) ~= 1) && (size(locations,2) ~= numDims)
    eml_invariant(false,...
        eml_message('images:imfill:badLocationSize'));
end

if numDims == 3 && size(locations,2) ~=1
    coder.varsize('locationsVar',[],[1 0]);
    locationsVar = zeros(0,3);
elseif numDims == 2 && size(locations,2) ~=1
    coder.varsize('locationsVar',[],[1 0]);
    locationsVar = zeros(0,2);
else
    coder.varsize('locationsVar',[],[1 0]);
    locationsVar = zeros(0,1);
end

% Make sure that locationVar definition is retained. If locations was any
% empty matrix whose orientation doesn't coincide with the definition of 
% locationsVar, concatenating to locationsVar will result in an error 
if ~isempty(locations)
    locationsVar = [locations; locationsVar];
end

sizeLoc = size(locations,1);
if size(locations,2) == 1
    badPixels = (locations < 1) | (locations > prod(image_size));
else
    badPixels = zeros(size(locations,1),1);
    if ~isempty(locations)
        for k = 1:numDims
            badPixels = cast(badPixels | ((locations(1:sizeLoc,k) < 1) | ...
                (locations(1:sizeLoc,k) > image_size(k))),class(badPixels));
        end
    end
end

if any(badPixels)
    numelBadPix = size(badPixels,1);
    coder.internal.warning('images:imfill:outOfRange');
    for s = numelBadPix:-1:1
        if (badPixels(s,1))
            locationsVar(s,:) = [];
        end
    end
end

function ndx = lsub2ind(siz,varargin)
%SUB2IND Linear index from multiple subscripts.
%   SUB2IND is used to determine the equivalent single index
%   corresponding to a given set of subscript values.
%
%   IND = SUB2IND(SIZ,[I J]) returns the linear index equivalent to the
%   row and column subscripts in the arrays I and J for a matrix of
%   size SIZ.

%   Limitations:
%   1. PROD(SIZ) > INTMAX is not supported.

eml_invariant(nargin >= 2, ...
    eml_message('Coder:MATLAB:minrhs'));
eml_invariant(isa(siz,'numeric'), ...
    eml_message('Coder:toolbox:sub2ind_2'), ...
    'IfNotConst','Fail');
eml_invariant(eml_is_const(size(siz)), ...
    eml_message('Coder:toolbox:sub2ind_3'), ...
    'IfNotConst','Fail');
eml_prefer_const(siz);
ndx = do_sub2ind(cast(siz,eml_index_class),varargin{:});

%--------------------------------------------------------------------------

function ndx = do_sub2ind(siz,varargin)
% SUB2IND algorithm assuming isa(siz,eml_index_class).
nsiz = eml_numel(siz);
% Input checking
eml_invariant(nsiz >= 2, ...
    eml_message('MATLAB:sub2ind:InvalidSize'));
nsubs = size(varargin{:},2);
m = min(nsubs,nsiz);
for k = coder.unroll(1:nsubs)
    if k > 1
        eml_invariant(isequal(size(varargin{1}(:,1)),size(varargin{1}(:,k))), ...
            eml_message('MATLAB:sub2ind:SubscriptVectorSize'));
    end
    if k < m
        hi = siz(k);
    elseif k > m
        hi = ones(eml_index_class);
    else
        hi = prodsub(siz,m,nsiz);
    end
    eml_invariant(allinrange(varargin{1}(:,k),1,hi), ...
        eml_message('MATLAB:sub2ind:IndexOutOfRange'));
end
% Compute linear indices
psiz = siz(1);
idx = cast(varargin{1}(:,1),eml_index_class);
for k = coder.unroll(2:m)
    idx = eml_index_plus(idx, ...
        eml_index_times(psiz, ...
        eml_index_minus(varargin{1}(:,k),1)));
    if k < m
        psiz = eml_index_times(psiz,siz(k));
    end
end
ndx = cast(idx,class(eml_scalar_eg(varargin{1}(:))));

%--------------------------------------------------------------------------

function p = allinrange(x,lo,hi)
% p = ~any(x(:)<lo | x(:)>hi) without temporaries.
for k = 1:eml_numel(x)
    if ~(x(k) >= lo && x(k) <= hi)
        p = false;
        return
    end
end
p = true;

%--------------------------------------------------------------------------

function y = prodsub(x,lo,hi)
% y = prod(x(lo:hi)) for isa(x,eml_index_class).
y = ones(eml_index_class);
for k = lo:hi
    y = eml_index_times(y,x(k));
end

%--------------------------------------------------------------------------
