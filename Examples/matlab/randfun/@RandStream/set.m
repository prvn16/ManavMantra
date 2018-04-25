function b = set(s,varargin)
%SET Set a random stream property value.
%   SET(S,'PropertyName',VALUE) sets the property 'PropertyName' of the
%   random stream S to the value VALUE.
%  
%   SET(S,'Property1',Value1,'Property2',Value2,...) sets multiple
%   random stream property values with a single statement.
%  
%   SET(S,A), where A is a structure whose field names are property names of
%   the random stream S, sets the properties of S named by each field with the
%   values contained in those fields.
%
%   SET(S,'Property') or A = SET(S,'Property') displays or returns possible
%   values for the specified property of S.
%
%   SET(S) or A = SET(S) displays or returns the possible values for all
%   writable properties of S.
%
%   See also RANDSTREAM, RANDSTREAM/GET.

%   Copyright 2008-2010 The MathWorks, Inc. 

if (~isvalid(s) || s.StreamID==0) && nargin > 1
    error(message('MATLAB:RandStream:InvalidHandle'));
end

readOnlyPropertyNames = {'Type' 'NumStreams' 'StreamIndex' 'Seed'};
writablePropertyNames = {'Substream' 'State' 'NormalTransform' 'Antithetic' 'FullPrecision'};

if nargin == 2 && isstruct(varargin{1}) % values in fields of a structure
    a = varargin{1};
    fn = fieldnames(a);
    % Look for a structure that came from get.
    getStructNames = [readOnlyPropertyNames writablePropertyNames];
    [fnDiff,ifn,iget] = setxor(fn,getStructNames);
    if isempty(fnDiff)
        isGetStruct = true;
    else
        isGetStruct = false;
    end
    for i = 1:length(fn)
        propname = fn{i};
        readOnly = any(strcmp(propname,readOnlyPropertyNames));
        for j = 1:numel(a) % what HG does
            p = a(j).(propname);
            if readOnly && isGetStruct && isequal(p,s.(propname))
                % If the structure appears to have come from get, allow it to
                % contain fields for read-only properties, as long as they are
                % the same as the corresponding stream properties.  Otherwise
                % let setproperty error out if the new value differs.
            else
                setproperty(s,propname,p);
            end
        end
    end
    
elseif nargin < 3
    propertyVals   = cell2struct(cell(size(writablePropertyNames)), writablePropertyNames, 2);
    propertyDescrs = cell2struct(cell(size(writablePropertyNames)), writablePropertyNames, 2);
    
%     genTypes = getset_mex('generatorlist',true);
%     propertyVals.Type          = {};
%     propertyDescrs.Type        = sprintf('''%s'' | ', genTypes{:}); propertyDescrs.Type(end-2:end) = [];
%     propertyVals.NumStreams    = {};
%     propertyDescrs.NumStreams  = 'Positive integer scalar';
%     propertyVals.StreamIndex   = {};
%     propertyDescrs.StreamIndex = 'Positive integer scalar';
    propertyVals.Substream        = {};
    propertyDescrs.Substream      = 'Positive integer scalar';
%     propertyVals.Seed          = {};
%     propertyDescrs.Seed        = 'Non-negative integer scalar';
    propertyVals.State            = {};
    propertyDescrs.State          = 'Numeric vector | Cell array';
    propertyVals.NormalTransform    = {'Ziggurat', 'Polar', 'Inversion'};
    propertyDescrs.NormalTransform  = '''Ziggurat'' | ''Polar'' | ''Inversion''';
    propertyVals.Antithetic       = {true false};
    propertyDescrs.Antithetic     = 'Logical scalar';
    propertyVals.FullPrecision    = {true false};
    propertyDescrs.FullPrecision  = 'Logical scalar';
    
    if nargin == 2
        propname = varargin{1};
        i = find(strcmpi(propname,writablePropertyNames));
        if isempty(i)
            i = find(strcmpi(propname,readOnlyPropertyNames));
            if isempty(i)
                error(message('MATLAB:RandStream:set:UnrecognizedProperty', propname));
            elseif strcmpi(propname,'seed')
                error(message('MATLAB:RandStream:set:IllegalSeedAssignment'));
            else
                error(message('MATLAB:RandStream:set:IllegalPropertyAssignment', propname));
            end
        end
        
        if nargout == 1
            b = propertyVals.(writablePropertyNames{i});
        else
            disp(propertyDescrs.(writablePropertyNames{i}));
        end        
    else
        if nargout == 1
            b = propertyVals;
        else
            fields = fieldnames(propertyDescrs);
            for i = 1:length(fields)
                f = fields{i};
                disp(sprintf('%16s: %s',f,propertyDescrs.(f)));
            end
        end
    end
    
    
elseif mod(nargin,2) == 1 %name/value pairs
    if nargout > 0
        error(message('MATLAB:RandStream:set:MaxLHS'));
    end
    for i = 1:(nargin-1)/2
        propname = varargin{2*i-1};
        p = varargin{2*i};
        setproperty(s,propname,p);
    end
else
    error(message('MATLAB:RandStream:set:WrongNumberArgs'));
end


function p = setproperty(s,propname,p)
switch lower(propname)
case 'substream'
    builtin('_RandStream_getset_mex','substream',s.StreamID,p);
case 'state'
    builtin('_RandStream_getset_mex','state',s.StreamID,p);
case 'normaltransform'
    builtin('_RandStream_getset_mex','randnalg',s.StreamID,p);
case 'antithetic'
    builtin('_RandStream_getset_mex','antithetic',s.StreamID,p);
case 'fullprecision'
    builtin('_RandStream_getset_mex','fullprecision',s.StreamID,p);
case 'seed'
    error(message('MATLAB:RandStream:set:IllegalSeedAssignment'));
case {'type' 'numstreams' 'streamindex'}
    error(message('MATLAB:RandStream:set:IllegalPropertyAssignment', propname));
otherwise
    error(message('MATLAB:RandStream:set:UnrecognizedProperty', propname));
end
