function Out = set(tsc,varargin)
%SET  Set properties of time series object.
%
%   SET(TSC,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the tscollection TSC to the value VALUE.  An equivalent syntax 
%   is 
%       TSC.PropertyName = VALUE
%
%   SET(TSC,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   tscollection property values with a single statement.
%
%   SET(TSC,'Property') displays values for the specified property in TSC.
%
%   SET(TSC) displays all properties of TSC and their values. 
%
%   See also TSCOLLECTION\GET.

%   Copyright 2004-2016 The MathWorks, Inc.

ni = nargin;
no = nargout;

% Get public properties and their assignable values
tsNames = tsc.gettimeseriesnames;
basePropsNames = setdiff(properties(tsc),tsNames);
allPropNames = cell(length(basePropsNames)+length(tsNames),1);
allPropNames(1:length(basePropsNames)) = basePropsNames(:);
allPropNames(length(basePropsNames)+1:end) = tsNames(:); 
if ni<=2
    allPropVals = cell(length(basePropsNames)+length(tsNames),1);   
    for k=1:length(basePropsNames)
        if isprop(tsc,char(basePropsNames{k}))
            allPropVals{k} = tsc.(char(basePropsNames{k}));
        end
    end
    l = length(basePropsNames);
    for k=l+1:l+length(tsNames)
        allPropVals{k} = tsc.getts(tsNames{k-l});
    end
    asgnValues = tspvformat(allPropVals);
end

% Handle read-only cases
if ni==1
   % SET(tsc) or S = SET(tsc)
   if no
      Out = cell2struct(asgnValues,allPropNames,1);
   else
      disp(cell2struct(asgnValues,allPropNames,1));
   end
elseif ni==2
   % SET(tsc,'Property') or STR = SET(tsc,'Property')
   % Return admissible property value(s)
   try
      [Property,imatch] = tspnmatch(varargin{1},allPropNames,20);
      if no
         Out = asgnValues{imatch};
      else
         disp(asgnValues{imatch})
      end
   catch me 
      rethrow(me)
   end   
else
   % SET(tsc,'Prop1',Value1, ...)
   tscname = inputname(1);
   if rem(ni-1,2)~=0
      error(message('MATLAB:tscollection:set:usePairs'))
   end
   
   % Match specified property names against list of public properties and
   % set property values at object level
   % RE: a) Include all properties to appropriately detect multiple matches
   %     b) Limit comparison to first 20 chars
   try
      for i=1:2:ni-1
         varargin{i} = tspnmatch(varargin{i},allPropNames,20);
         tsc.(varargin{i}) = varargin{i+1};
      end
   catch me
      rethrow(me)
   end
   
   % Assign tsc in caller's workspace
   if no
       Out = tsc;     
   else
       assignin('caller',tscname,tsc)
   end
end

