classdef tscollection < matlab.mixin.SetGet
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetObservable, GetObservable)
        TsValue = [];
        DataChangeEventsEnabled logical = true;
    end
    
    properties (Transient, SetObservable, GetObservable)
        Name = '';
        Time = [];
        TimeInfo = [];
    end
    
    events
        datachange
    end
    
    methods
        function h = tscollection(varargin)
            
            
            % h = tsdata.tscollection;
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1},'tscollection')
                h.TsValue = varargin{1};
            elseif nargin==1 && isa(varargin{1},'tsdata.tscollection')
                h.TsValue = varargin{1}.TsValue;
            else
                h.TsValue = tscollection(varargin{:});
            end
        end
    end
    
    methods
        function value = get.Name(obj)
            fGet = @(es,ed)getInternalProp(es,ed,'Name');
            value = fGet(obj,obj.Name);
        end
        
        function set.Name(obj,value)
            fSet = @(es,ed)setInternalProp(es,ed,'Name');
            obj.Name = fSet(obj,value);
        end
        
        function value = get.Time(obj)
            fGet = @(es,ed)getInternalProp(es,ed,'Time');
            value = fGet(obj,obj.Time);
        end
        
        function set.Time(obj,value)
            fSet = @(es,ed)setInternalProp(es,ed,'Time');
            obj.Time = fSet(obj,value);
        end
        
        function value = get.TimeInfo(obj)
            fGet = @(es,ed)getInternalProp(es,ed,'TimeInfo');
            value = fGet(obj,obj.TimeInfo);
        end
        
        function set.TimeInfo(obj,value)
            fSet = @(es,ed)setInternalProp(es,ed,'TimeInfo');
            obj.TimeInfo = fSet(obj,value);
        end
        
        function set.DataChangeEventsEnabled(obj,value)
            obj.DataChangeEventsEnabled = value;
        end
        
    end
    
    methods
        [boo,offending_name] = utChkforSlashInName(h)
    end
    
    methods (Hidden)
        addsampletocollection(this,varargin)
        addts(this,data,varargin)
        tscout = copy(tsc,varargin)
        node = createTstoolNode(ts,h)
        delsamplefromcollection(this,method,value)
        display(this)
        index = end(this,position,numindices)
        fireDataChangeEvent(h,varargin)
        propVal = getInternalProp(h,eventData,propName)
        tscout = getsampleusingtime(this,StartTime,varargin)
        memberVars = gettimeseriesnames(h)
        init(this,varargin)
        boo = isempty(this)
        l = length(this)
        h = removets(h,tsname)
        resample(this,timevec,varargin)
        propVal = setInternalProp(h,eventData,propName)
    end
    
    methods (Static)
        h = loadobj(s)
    end
end