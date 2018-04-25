function Out = set(ts,varargin)
%SET  Set properties of time series object.
%
%   SET(TS,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the time series TS to the value VALUE.  An equivalent syntax 
%   is 
%       TS.PropertyName = VALUE
%
%   SET(TS,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   time series property values with a single statement.
%
%   SET(TS,'Property') displays values for the specified property in TS.
%
%   SET(TS) displays all properties of TS and their values. 
%
%   See also TIMESERIES\GET.

%   Copyright 2005-2016 The MathWorks, Inc.

ni = nargin;
no = nargout;
if builtin('isempty',ts)
    ts = timeseries;
end

% Get public properties and their assignable values
AllProps = properties(ts);
if ni<=2
   PropValues = cell(length(AllProps),1);
   for k=1:length(AllProps)
       PropValues{k} = ts.(AllProps{k});
   end
end

% Handle read-only cases
if ni==1
   % SET(TS) or S = SET(TS)
   if numel(ts)~=1
      error(message('MATLAB:timeseries:set:noarray'));
   end
   if no
      Out = cell2struct(PropValues,AllProps,1);
   else
      disp(cell2struct(PropValues,AllProps,1))
   end
   
elseif ni==2
   % SET(TS,'Property') or STR = SET(TS,'Property')
   % Return admissible property value(s)
   if numel(ts)~=1
      error(message('MATLAB:timeseries:set:noarray'));
   end
   try
      [~,imatch] = tspnmatch(varargin{1},AllProps,10);
      AsgnValues = tspvformat(PropValues);
      if no
         Out = AsgnValues{imatch};
      else
         disp(AsgnValues{imatch})
      end
   catch me
      me.rethrow;
   end
   
else
   % SET(TS,'Prop1',Value1, ...)
   if rem(ni-1,2)~=0,
      error(message('MATLAB:timeseries:set:propValPairs'))
   end
   
   % Temporarily turn off consistency checking.
   beingBuiltCache = false(size(ts));
   for k=1:numel(ts)
      beingBuiltCache(k) = ts(k).BeingBuilt;
      ts(k).BeingBuilt = true;
   end
   % Match specified property names against list of public properties and
   % set property values at object level
   % RE: a) Include all properties to appropriately detect multiple matches
   %     b) Limit comparison to first 10 chars (because of qualityinfo)
   dataPropertySet = false;
   timePropertySet = false;
   qualPropertySet = false;
   try
      for i=1:2:ni-1
          propName = tspnmatch(varargin{i},AllProps,10);
           
          % Validate that base @timeseries property values are not structs
          if ~strcmpi(propName,'userdata') && isstruct(varargin{i+1})
              c = metaclass(ts);
              for k=1:length(c.PropertyList)
                  if strcmpi(c.PropertyList(k).Name,propName) && isequal(c.PropertyList(k).DefiningClass,?timeseries)
                      error(message('MATLAB:timeseries:set:nostruct'))
                  end
              end
          end
          
          if strcmpi(propName,'data')
              dataPropertySet = true;
          elseif strcmpi(propName,'time')
              timePropertySet = true;
          elseif strcmpi(propName,'quality')
              qualPropertySet = true;
          elseif strcmpi(propName, 'istimefirst')
              % storing the user specified isTimeFrist to be validated (only for backwards compatibility)
              istimefirstPropertySet = varargin{i+1};
          end
          for k=1:numel(ts)
              ts(k).(char(propName)) = varargin{i+1};
          end
      end
   catch me
      me.rethrow;
   end
   
   for k=1:numel(ts)
       if ~beingBuiltCache(k)
          try % Report errors from the set method.
              % Check specified properties first.
              if dataPropertySet
                  % Attempt to reshape the data to match other properties.
                  ts(k).Data = ts(k).formatData(ts(k).Data); 
                  ts(k).chkDataProp(ts(k).Data);
              end
              if timePropertySet
                  ts(k).chkTimeProp(ts(k).Time);
              end
              if qualPropertySet
                  % Attempt to reshape the quality to match other properties.
                  ts(k).Quality = ts(k).formatQuality(ts(k).Quality); 
              end 
              % Validate the user specified isTimeFirst value. 
              % If different from the computed value, throw error message.
              if exist('istimefirstPropertySet','var')
                ts(k).chkIsTimeFirstProp(istimefirstPropertySet);
              end
              % Validate unspecified properties.    
              if ~dataPropertySet
                  ts(k).chkDataProp(ts(k).Data);
              end
              if ~timePropertySet
                  ts(k).chkTimeProp(ts(k).Time);
              end
              if ~qualPropertySet
                  ts(k).chkQualityProp(ts(k).Quality);
              end
          catch me
              me.throw;
          end
       end
       ts(k).BeingBuilt = beingBuiltCache(k);
   end
   % Assign ts in caller's workspace
   tsname = inputname(1);
   if no
       Out = ts;     
   elseif ~isempty(tsname)
       assignin('caller',tsname,ts)
   else
       warning(message('MATLAB:timeseries:set:noinplaceset'));
   end
end

