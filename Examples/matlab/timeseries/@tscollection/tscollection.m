%TSCOLLECTION  Create a tscollection object using time or time series objects.
%
%   TSC = TSCOLLECTION(TIME) creates a tscollection object TSC
%   using TIME. Note: When the times are date strings,
%   the TIME must be specified as a cell array of date strings. 
%
%   TSC = TSCOLLECTION(TS) creates a tscollection object TSC with
%   a time series object TS. Note: the times in TS will be used as the
%   common time vector.  
%
%   TSC = TSCOLLECTION(TS) creates a tscollection object TSC with a
%   cell array of time series objects stored in TS.
%
%   You can enter property-value pairs after the TIME or TS arguments:
%       'PropertyName1', PropertyValue1, ...
%   that set the following additional properties of tscollection object: 
%       (1) 'Name': a string that specifies the name of this tscollection object.  
%       (2) 'isDatenum': a logical value, when TRUE, indicates that the time vector
%       consists of DATENUM values. Note that 'isDatenum' is not a property
%       of the tscollection object.
%

%   Copyright 2005-2016 The MathWorks, Inc.

classdef (CaseInsensitiveProperties = true) tscollection
   properties
      Name = '';
   end
   properties (Dependent = true)
      Time
   end
   properties
       TimeInfo
   end
   properties (Dependent = true)
      Length
   end
   properties (SetAccess = 'private', Hidden = true)
      Time_ = [];
      Members_ = [];
   end
   properties (Hidden = true)
      BeingBuilt = true;
   end
   methods
      function this = tscollection(varargin)
         if nargin ==1 && isa(varargin{1},'tsdata.tscollection')
            this = varargin{1}.TsValue;
         elseif nargin>0
            this = init(this,varargin{:});
         else
            this = init(this,[]);
         end
      end
      function outdata = get.Time(this)
           timeMetadata = this.TimeInfo;
           if ~isempty(timeMetadata)
               outdata = timeMetadata.getData;
           else
               outdata = [];
           end
      end
      function this = set.Time(this,input)
           if ~this.BeingBuilt && length(input)~=this.Length
               error(message('MATLAB:tscollection:set:Time:badlength'));
           end
           this.TimeInfo = this.TimeInfo.reset(input);
      end
      function outdata = get.Length(this)
           if isempty(this.TimeInfo)
               outdata = 0;
           else
               outdata = this.TimeInfo.Length;
           end
      end
      
      function hasDupTimes = hasduplicatetimes(this)
            hasDupTimes = false;
            if ~isempty(this.TimeInfo)
                % Deal with legacy TimeInfo with no hasDuplicateTimes
                % method
                try
                    hasDupTimes = this.TimeInfo.hasDuplicateTimes;
                catch me
                    if strcmp('MATLAB:noSuchMethodOrField',me.identifier)
                        return;
                    end
                end
            end
      end
        
   end 
   methods (Access = 'private')
       % Creates timeseries from Members_ data struct and the time vec
       function ts = getts(this,name)
         for k=1:length(this.Members_)
             if strcmpi(this.Members_(k).Name,name)
                 if ~isfield(this.Members_(k),'Class') || strcmp(this.Members_(k).Class,'timeseries')
                     ts = timeseries(this.Members_(k).Data,this.Time,...
                       this.Members_(k).Quality,'IsTimeFirst',this.Members_(k).IsTimeFirst);
                 else % Proper @timeseries subclass
                     ts = feval(this.Members_(k).Class);
                     ts = init(ts,this.Members_(k).Data,this.Time,...
                        this.Members_(k).Quality,'IsTimeFirst',this.Members_(k).IsTimeFirst);
                 end
                 ts.TimeInfo = this.TimeInfo;
                 ts.DataInfo = this.Members_(k).DataInfo;
                 ts.QualityInfo = this.Members_(k).QualityInfo;
                 ts.Name = name;
                 ts.Events = this.Members_(k).Events;
                 if isfield(this.Members_(k),'TreatNaNasMissing') % UserData may not exist for <=12a saved tscollections
                     ts.TreatNaNasMissing = this.Members_(k).TreatNaNasMissing;
                 end
                 if isfield(this.Members_(k),'UserData') % UserData may not exist for <=11b saved tscollections
                     ts.UserData = this.Members_(k).UserData;
                 end
                 % Add back extra fields for proper @timeseries subclass
                 if isfield(this.Members_(k),'ExtraProps') && ~isempty(this.Members_(k).ExtraProps)       
                     extraFields = setdiff(fields(this.Members_(k).ExtraProps),{'Time','Data','Quality',...
                     'DataInfo','QualityInfo','Name','IsTimeFirst','Events','Class',...
                     'Length','TimeInfo','TreatNaNasMissing'});
                     for j=1:numel(extraFields)
                         ts = set(ts,extraFields{j},this.Members_(k).ExtraProps.(extraFields{j}));
                     end
                 end
                 return
             end
         end
         ts = [];
       end
       % Updates the Members_ data struct with a modified or added
       % timeseries
       function this = setts(this,ts,name)
         x = struct('Data',ts.Data,'Quality',ts.Quality,'DataInfo',...
             ts.DataInfo,'QualityInfo',ts.QualityInfo,'Name',char(name),...
             'IsTimeFirst',ts.IsTimeFirst,'Events',ts.Events,...
             'TreatNaNasMissing',ts.TreatNaNasMissing,'UserData',ts.UserData, 'Class',....
             class(ts),'ExtraProps',[]);
         % Add timeseries subclass fields
         if ~isequal(metaclass(ts),?timeseries)
             extraFields = setdiff(fieldnames(ts),{'Time','Data','Quality',...
                 'DataInfo','QualityInfo','Name','IsTimeFirst','Events','Class',...
                 'Length','TimeInfo','TreatNaNasMissing'});
             extraPropStruct = struct;
             for k=1:numel(extraFields)
                 extraPropStruct.(extraFields{k}) = get(ts,extraFields{k});
             end
             x.ExtraProps = extraPropStruct;
         end
         I = [];
         if ~isempty(this.Members_)
             I = find(strcmp(x.Name,{this.Members_.('Name')}));
         end
         if isempty(I)
             this.Members_ = [this.Members_; x];
         else
             this.Members_(I(1)) = x;
         end
       end
   end
   
   methods (Static = true)
        
        function h = loadobj(h)           
             if isa(h,'tscollection')
                 % Move time storage to TimeInfo if it was previously stored in
                 % the Time_ property
                 if ~isempty(h.Time_) 
                     h.TimeInfo = h.TimeInfo.reset(h.Time_);
                     h.Time_ = [];
                 end
             elseif isstruct(h) && isfield(h,'objH')
                 h = h.objH.TsValue;
             end
        end
   end
 end
