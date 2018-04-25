function attributes( varargin )
; %#ok<NOSEM> % Undocumented

%   Copyright 2012-2016 The MathWorks, Inc.

narginchk(3,6);

try
    [ A, classes, attrs, fname, msgId, argname, argpos ] = checkInputs( varargin );
catch e
    % only VALIDATEATTRIBUTES should be on the stack
    throw(e)
end

try    
    % check the class of A
    checkClass( A, classes, fname, msgId, argname, argpos );
    
    % check the attributes of A
    checkAttrs( A, attrs, fname, msgId, argname, argpos );
catch e
    myId = 'MATLAB:validateattributes:';
    if strncmp( myId, e.identifier, length(myId) )
        % leave VALIDATEATTRIBUTES on the stack, because there was a misuse
        % of VALIDATEATTRIBUTES itself
        throw(e)
    else
        % strip VALIDATEATTRIBUTES off the stack so that the error looks like
        % it comes from the caller just as if it had hand-coded its input checking
        throwAsCaller( e )
    end
end

end


function checkAttrs( A, attrs, fname, msgId, argname, argpos )

warnOnUnknownAttr = true;
numAttrs = length(attrs);
idx = 1;
isAttributeScalar = false;

% isAttributeScalar is logical true when 'scalar' is one of the attributes
% provided by the user

for i=1:numAttrs
    
    if isstring(attrs{i}) && ismissing(attrs{i})
        error(message('MATLAB:validateattributes:missingValueInAttributeList'))
    elseif (ischar(attrs{i}) || isstring(attrs{i})) && strcmp(attrs{i},'scalar')
        isAttributeScalar = true;
    end
end

while idx <= numAttrs
    attr = attrs{idx};
    
    attributor = findSupportedAttr( attr, isAttributeScalar); 
    if isempty(attributor) 
        % only warn once if the attribute wasn't found in the supported list
        if warnOnUnknownAttr
            if ischar( attr ) || isstring( attr )
                warning(message('MATLAB:validateattributes:attributeNotFound', char(attr) ))
            else
                warning(message('MATLAB:validateattributes:attributeBadClass', class(attr)))
            end
            warnOnUnknownAttr = false;
        end
        idx = idx + 1;
        continue
    end
    
    switch nargin( attributor )
        case 5
            attributor(A, fname, msgId, argname, argpos)
            idx = idx + 1;
            
        case 6
            if idx == numel(attrs)
                error(message('MATLAB:validateattributes:notEnoughArguments', attr))
            end
            
            attributor(A, attrs{idx+1}, fname, msgId, argname, argpos )
            idx = idx + 2;
            
    end
    
end
 
end

function [ attributor ] = findSupportedAttr( attr, isAttributeScalar)

% attribute not found value
attributor = [];

% attribute must be a char
if isstring( attr )
    attr = char(attr);
elseif ~ischar( attr )
    return;
end

switch attr
    case '2d'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @ismatrix, A, 'twod', fname, 'expected2D', msgId, argname, argpos);
    case '3d'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @(x)(ndims(x) <= 3), A, 'threed', fname, 'expected3D', msgId, argname, argpos);
    case 'square'
        fcn =  @(x) (ismatrix(x) && (size(x,1) == size(x,2)));
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor(fcn, A, 'square', fname, 'expectedSquare', msgId, argname, argpos);
    case 'scalar'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @isscalar, A, 'scalar', fname, 'expectedScalar', msgId, argname, argpos);
    case 'vector'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @isvector, A, 'vector', fname, 'expectedVector', msgId, argname, argpos);
    case 'row'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @isrow, A, 'row', fname, 'expectedRow', msgId, argname, argpos);
    case 'column'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @iscolumn, A, 'column', fname, 'expectedColumn', msgId, argname, argpos);
    case 'nonempty'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @(x)~isempty(x), A, 'nonempty', fname, 'expectedNonempty', msgId, argname, argpos);
    case 'nonsparse'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @(x)~issparse(x), A, 'nonsparse', fname, 'expectedNonsparse', msgId, argname, argpos);
    case 'nonzero'
        fcn = @(x)(isnumeric(x) || islogical(x)) && ~isempty(x) && nnz(x)==numel(x);
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'nonzero', fname, 'expectedNonZero', msgId, argname, argpos);
    case 'binary'
        fcn = @(x)(islogical(x) || (isnumeric(x)) && all( x(:)==0 | x(:)==1 ));
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'binary', fname, 'expectedBinary', msgId, argname, argpos);
    case 'integer'
        fcn = @(x)islogical(x) || (isnumeric(x) && isreal(x) && all(isfinite(x(:))) && all(floor(x(:))==x(:)));
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'integer', fname, 'expectedInteger', msgId, argname, argpos);
    case 'scalartext'
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( @(x) (isa(x,'string') && isscalar(x) && ~ismissing(x)) || (ischar(x) && size(x,1)<=1), A, 'scalartext', fname, 'expectedScalartext', msgId, argname, argpos);
        
        % value related attributes most be real numeric, regardless of CLASSES
    case 'odd'
        fcn = @(x)(isnumeric(x) || islogical(x) ) && isreal(x) && all( mod(x(:),2)==1 );
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'odd', fname, 'expectedOdd', msgId, argname, argpos);
    case 'even'
        fcn = @(x)(isnumeric(x) || islogical(x) ) && isreal(x) && all( mod(x(:),2)==0 );
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'even', fname, 'expectedEven', msgId, argname, argpos);
    case 'positive'
        fcn = @(x)(isnumeric(x) || islogical(x) ) && isreal(x) && ~any( x(:)<=0 );
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'positive', fname, 'expectedPositive', msgId, argname, argpos);
    case 'nonnegative'
        fcn = @(x)(isnumeric(x) || islogical(x) ) && isreal(x) && ~any( x(:)<0 );
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'nonnegative', fname, 'expectedNonnegative', msgId, argname, argpos);
    case 'finite'
        fcn = @(x)(isnumeric(x) || islogical(x) ) && all(isfinite(x(:)));
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'finite', fname, 'expectedFinite', msgId, argname, argpos);
    case 'real'
        % if it is not numeric, it is not real
        %fcn = @(x)~isnumeric(x) || isreal(x) || all(imag(x(:))==0);
        fcn = @(x)~isnumeric(x) || isreal(x);
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'real', fname, 'expectedReal', msgId, argname, argpos);
    case 'nonnan'
        fcn = @(x)(isnumeric(x) || islogical(x) ) && ~any(isnan(x(:))); 
        attributor = @(A, fname, msgId, argname, argpos )valueAttributor( fcn, A, 'nonnan', fname, 'expectedNonNaN', msgId, argname, argpos);      
    case 'diag'
        attributor = @(A, fname,msgId, argname, argpos)diagAttributor( A, 'diag', fname, 'expectedDiag', msgId, argname, argpos);  
    case 'size'
        attributor = @(A,v,fname,msgId, argname, argpos)sizeAttributor(A,v,fname, 'incorrectSize', msgId, argname, argpos);
    case 'ndims'
        attributor = @(A,v,fname,msgId, argname, argpos)dimsAttributor(A, v, attr, fname, 'incorrectNumdims', msgId, argname, argpos, isAttributeScalar);
    case 'numel'
        attributor = @(A,v,fname,msgId, argname, argpos)sizeTypeAttributor( @numel, A, v, attr, fname, 'incorrectNumel', msgId, argname, argpos, isAttributeScalar);
    case 'nrows'
        attributor = @(A,v,fname,msgId, argname, argpos)sizeTypeAttributor( @(x)size(x,1), A, v, attr, fname, 'incorrectNumrows', msgId, argname, argpos, isAttributeScalar);
    case 'ncols'
        attributor = @(A,v,fname,msgId, argname, argpos)sizeTypeAttributor( @(x)size(x,2), A, v, attr, fname, 'incorrectNumcols', msgId, argname, argpos, isAttributeScalar);
    case '<'
        attributor = @(A,v, fname, msgId, argname, argpos)relationalAttributor( @lt,A,v,attr,fname,'notLess',msgId, argname, argpos, isAttributeScalar);
    case '<='
        attributor = @(A,v, fname, msgId, argname, argpos)relationalAttributor( @le,A,v,attr,fname,'notLessEqual',msgId, argname, argpos, isAttributeScalar);
    case '>'
        attributor = @(A,v, fname, msgId, argname, argpos)relationalAttributor( @gt,A,v,attr,fname,'notGreater',msgId, argname, argpos, isAttributeScalar);
    case '>='
        attributor = @(A,v, fname, msgId, argname, argpos)relationalAttributor( @ge,A,v,attr,fname,'notGreaterEqual',msgId, argname, argpos, isAttributeScalar);
    case 'increasing'
        attributor = @(A, fname, msgId, argname, argpos)monotonicAttributor(@gt,A,attr,fname,'increasing',msgId, argname, argpos);
    case 'decreasing'
        attributor = @(A, fname, msgId, argname, argpos)monotonicAttributor(@lt,A,attr,fname,'decreasing',msgId, argname, argpos);
    case 'nonincreasing'
        attributor = @(A, fname, msgId, argname, argpos)monotonicAttributor(@le,A,attr,fname,'nonincreasing',msgId, argname, argpos);
    case 'nondecreasing'
        attributor = @(A, fname, msgId, argname, argpos)monotonicAttributor(@ge,A,attr,fname,'nondecreasing',msgId, argname, argpos);    
end

end

function valueAttributor( fcn, A, attrName, fname, id, msgId, argname, argpos)

if ~fcn(A)
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    attributeDes = getString(message( ['MATLAB:validateattributes:' attrName] ) );
    error( matlab.internal.validators.generateId( fname, id ), '%s', ...
        getString(message('MATLAB:validateattributes:expected', argDes, attributeDes)) )
end

end

function monotonicAttributor( fcn, A, attrName, fname, id, msgId, argname, argpos)

 if ~isnumeric( A )
     error( message('MATLAB:validateattributes:UnsupportedTypeForComparison', class(A), attrName) )
 end

if any(isnan(A(:))) || ~isreal(A) || ~all( fcn(diff(A),0) )
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    
    error( matlab.internal.validators.generateId( fname, id ), '%s', ...
            getString(message('MATLAB:validateattributes:expected', argDes, attrName)))
end

end

function relationalAttributor( fcn, A, v, attrName, fname, id, msgId, argname, argpos, isAttributeScalar )

if ~(isnumeric( v ) && isreal( v ) && ...
        isscalar( v ) && ~issparse( v ) && isfinite( v ) )
    error( message('MATLAB:validateattributes:badComparison', attrName) )
end

if ~isnumeric( A )
    error( message('MATLAB:validateattributes:UnsupportedTypeForComparison', class(A), attrName) )
end

if ~all( fcn(A(:),v) )   
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    
    if(isAttributeScalar)
        error( matlab.internal.validators.generateId( fname, id ), '%s', ...
            getString(message('MATLAB:validateattributes:expectedScalar', argDes, attrName, num2str(v) )))
    else 
        error( matlab.internal.validators.generateId( fname, id ), '%s', ...
            getString(message('MATLAB:validateattributes:expectedArray', argDes, attrName, num2str(v) )))
    end
end

end

function sizeTypeAttributor( fcn, A, v, attrName, fname, attrId, msgId, argname, argpos, isAttributeScalar)

% check that v is a usable expected value
if ~isreal(v) || issparse(v) || ~isnumeric(v) || ~isscalar(v) || isinf(v) || v < 0
    error( ['MATLAB:validateattributes:bad' attrName], '%s', ...
        getString(message('MATLAB:validateattributes:badArgument', attrName ) ) )
end

% no checking on A

if fcn(A) ~= v
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    attributeDes = getString(message( ['MATLAB:validateattributes:' attrName] ) );
    
    if(isAttributeScalar)
        error( matlab.internal.validators.generateId( fname, attrId ), '%s', ...
            getString(message('MATLAB:validateattributes:expectedScalarEqual', argDes, attributeDes, num2str(v) )))
    else
        error( matlab.internal.validators.generateId( fname, attrId ), '%s', ...
            getString(message('MATLAB:validateattributes:expectedArrayEqual', argDes, attributeDes, num2str(v) )))
    end
end

end

function sizeAttributor( A, v, fname, id, msgId, argname, argpos)

% check that v is a usable expected size, don't do empties correctly
if ~isreal(v) || issparse(v) || ~isnumeric(v) || isscalar(v) || any(isinf(v(:))) || any(v(:) < 0 )
    error( message('MATLAB:validateattributes:badSizeArray') )
end

% one size vector will be used for any error message, another will be used
% for the actual check since missing trailing 1s is ok
szsDisp = size(A);
szs = szsDisp;

if numel( szs ) < numel( v )
    % pad out any needed 1s
    szs( end+1:numel(v) ) = 1;
end

% only check where the user input isn't NaN
dimensionsToCompare = ~isnan(v);

if numel( szs ) ~= numel( v ) || ~all( szs(dimensionsToCompare)==v(dimensionsToCompare) )
    sA = getSizeStr(szsDisp);
    
    sE = getSizeStr(v);
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    error( matlab.internal.validators.generateId( fname, id ), ...
        '%s', getString(message('MATLAB:validateattributes:expectedSize', argDes, sE, sA )))
end

end


function diagAttributor(x, attrName, fname, id, msgId, argname, argpos)

[nrows,ncols] = size(x);

isInputDiagonal = true;

% If input matrix is not square, the matrix is not considered diagonal
if ~ismatrix(x) || (nrows ~= ncols)
    isInputDiagonal = false;
else
    % Reading each non-diagonal value present in the matrix and comparing 
    % it with value '0'.
    for i= 1:numel(x)
        
         % When mod(i-1,nrows + 1) is 0, the element lies on the diagonal.        
         if ( mod(i-1,nrows + 1) ~= 0 && x(i) ~= 0)
                isInputDiagonal = false;
                break;
         end
         
    end   
    
end

if ~isInputDiagonal    
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    attributeDes = getString(message( ['MATLAB:validateattributes:' attrName] ) );
    error( matlab.internal.validators.generateId( fname, id ), '%s', ...
        getString(message('MATLAB:validateattributes:expected', argDes, attributeDes)) )
end

end

function dimsAttributor( A, v, attrName, fname, attrId, msgId, argname, argpos, isAttributeScalar)

% check that v is a valid dimension value
if ~isscalar(v) || ~isreal(v) || isinf(v) || ~isnumeric(v) || ~(v>1) || ~(v == floor(v))
    error( message('MATLAB:validateattributes:badDimsArray') )
end

if (ndims(A) ~= v)
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    attributeDes = getString(message( ['MATLAB:validateattributes:' attrName] ) );
    
    if(isAttributeScalar)
        error( matlab.internal.validators.generateId( fname, attrId ), '%s', ...
            getString(message('MATLAB:validateattributes:expectedScalarEqual', argDes, attributeDes, num2str(v) )))
    else
        error( matlab.internal.validators.generateId( fname, attrId ), '%s', ...
            getString(message('MATLAB:validateattributes:expectedArrayEqual', argDes, attributeDes, num2str(v) )))
    end
    
end

end


function s = getSizeStr(v)

% which letters to use in case of NaNs in the expected size vector
ltr = 'M';

s = '';
for idx = v
    if ~isnan(idx)
        s = sprintf( '%s%dx', s, idx );
    else
        s = sprintf( '%s%cx', s, ltr );
        if ltr == 'Z'
            ltr = 'M';
        else
            ltr = char(ltr+1);
        end
    end
end
s(end) = [];
end

function checkClass( A, classes, fname, msgId, argname, argpos )

% if A wasn't one of the classes, generate the appropriate error message 
% and throw the error

isAInClasses = false;
num = numel(classes);

for i = 1:num
    if isa(A,classes{i})
        isAInClasses = true;
        break;
    end
end

if ~isAInClasses
    classesStr = sprintf( '%s, ', classes{:} );
    if ~isempty( classesStr )
        classesStr(end-1:end) = [];
    end

    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    error( matlab.internal.validators.generateId( fname, 'invalidType' ), '%s', ...
        getString(message( 'MATLAB:validateattributes:invalidType', ...
        argDes, classesStr, class(A) )));
end

end

function [ A, classes, attrs, fname, msgId, argname, argpos ]  = checkInputs( inputs )

A = inputs{1};
classes = inputs{2};
attrs = inputs{3};

if (isstring(classes))
    if any(ismissing(classes))
        error(message('MATLAB:validateattributes:missingValueInClassList'))
    end
    
    classes = cellstr(classes);
elseif ~iscellstr( classes )
    error(message('MATLAB:validateattributes:badClassList'))
end

if ~iscell( attrs )
    error( message('MATLAB:validateattributes:badAttributeList') ) 
end

[ fname, msgId, argname, argpos ] = matlab.internal.validators.generateArgumentDescriptor( ...
    inputs(4:end), 'validateattributes' );

end
