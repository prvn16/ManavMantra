classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) StreamingStorage<handle
    
    %   Copyright 2009 The MathWorks, Inc.
    
    % Class used by incremental signal logging so that data can be
    % stored with the last dimension aligned with time even for timeseries
    % objects where isTimeFirst is true.
    
    properties (SetAccess = private) 
        Data;
        SampleDimensions;
        IsTimeStorageFirst = false;
    end
    properties (Hidden = true, GetAccess = protected, SetAccess = protected)
        Version = 10.1;
    end        
    
    methods
        
        function this = StreamingStorage(data)
            if nargin>=1
                this.Data = data;
            end
        end
        
        function setSampleDimensions(this,sampleDims)  
            this.SampleDimensions = sampleDims;
        end
        
        function setIsTimeStorageFirst(this,isTimeFirst)
            this.IsTimeStorageFirst = isTimeFirst;
        end

        
        % The setData method just return the newdata and a null Storage_ 
        % object so that data becomes memory resident. This effectively 
        % forces copy-on-write behavior for the timeseries Data property
        % preventing implicit sharing of data between timeseries sharing 
        % the same StreamingStorage handles.
        function [newval,nullobj] = setData(~,newval) 
            nullobj = [];
        end
        
        function A = getData(this,varargin)
            % If the IsTimeStorageFirst disagrees with the isTimeFirst
            % representation in the @timeseries, transpose the data and
            % remember the state.
            data = this.Data;
            n = ndims(data);
            if this.needsTranspose
                this.Data = permute(data,[n 1:n-1]);
                this.IsTimeStorageFirst = ~this.IsTimeStorageFirst;
            end
            A = this.Data;
        end
 
        function sdata = getSize(this,varargin)
            sdata = size(this.Data);
            if this.needsTranspose
                sdata = sdata([end 1:end-1]);
                % Strip trailing ones
                if length(sdata)>2
                    trailingOneStart = length(sdata)+2-find(fliplr(sdata)~=1,1);
                    if tralingOneStart>=3
                        sdata = sdata(1:trailingOneStart-1);
                    end
                end
            end
        end
        
    end
    
    methods (Access = private)

        % Compute the isTimeFirst timeseries property based on the 
        % SampleDimensions. If it disagrees with the
        % IsTimeStorageFirst then the data needs to be transposed when
        % returned from the getData method.
        function needsTrans = needsTranspose(this)
            if isempty(this.SampleDimensions)
                needsTrans = false;
                return
            end
            % The calculated isTimeFirst will be true iff we are logging a
            % single dimension scalar signal
            isTimeFirst = length(this.SampleDimensions)<=1;
            needsTrans = (isTimeFirst~=this.IsTimeStorageFirst);
        end
            
    end
end
        