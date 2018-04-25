function p = get(s,propname)
%GET Get a random stream property.
%   GET(S) prints the list of properties for the random stream S.
%
%   P = GET(S) returns all properties of S in a scalar structure.
%
%   P = GET(S,'PropertyName') returns the property 'PropertyName'.
%
%   See also RANDSTREAM, RANDSTREAM/SET.

%   Copyright 2008-2010 The MathWorks, Inc. 

if ~isvalid(s) || s.StreamID==0
    error(message('MATLAB:RandStream:InvalidHandle'));
end
    
if nargin == 1
    % The order here matches that of the disp method
    props = struct('Type',getproperty(s,'type'), ...
                   'NumStreams',getproperty(s,'numstreams'), ...
                   'StreamIndex',getproperty(s,'streamindex'), ...
                   'Substream',getproperty(s,'substream'), ...
                   'Seed',getproperty(s,'seed'), ...
                   'State',{getproperty(s,'state')}, ... % this might be a cell array
                   'NormalTransform',getproperty(s,'normaltransform'), ...
                   'Antithetic',getproperty(s,'antithetic'), ...
                   'FullPrecision',getproperty(s,'fullprecision'));
    if nargout == 1
        p = props;
    else
        disp(props);
    end
    
elseif nargin == 2
    if iscellstr(propname)
        p = cell(1,numel(propname));
        for i = 1:length(p)
            p{i} = getproperty(s,propname{i});
        end
    else
        p = getproperty(s,propname);
    end
end


function p = getproperty(s,propname)
switch lower(propname)
case 'type'
    p = s.Type;
case 'numstreams'
    p = s.NumStreams;
case 'streamindex'
    p = s.StreamIndex;
case 'substream'
    p = builtin('_RandStream_getset_mex','substream',s.StreamID);
case 'seed'
    p = s.Seed;
case 'state'
    p = builtin('_RandStream_getset_mex','state',s.StreamID);
case 'normaltransform'
    p = builtin('_RandStream_getset_mex','randnalg',s.StreamID);
case 'antithetic'
    p = builtin('_RandStream_getset_mex','antithetic',s.StreamID);
case 'fullprecision'
    p = builtin('_RandStream_getset_mex','fullprecision',s.StreamID);
otherwise
    error(message('MATLAB:RandStream:get:UnrecognizedProperty', propname));
end
