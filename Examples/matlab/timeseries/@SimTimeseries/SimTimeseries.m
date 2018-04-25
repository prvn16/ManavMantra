% Copyright 2006 The MathWorks, Inc.

classdef (CaseInsensitiveProperties=true) SimTimeseries<timeseries
    methods
        function this = SimTimeseries(varargin)
          this.TimeInfo = Simulink.TimeInfo;
          this.DataInfo = tsdata.datametadata;
          this.QualityInfo = tsdata.qualmetadata;
          this.DataInfo.Interpolation = tsdata.interpolation('linear');
          if nargin ==1 && isa(varargin{1},'char')
             this.Name = varargin{1};
             return
          end
          if nargin>0
              this.Name = 'unnamed';
          end
        end
        % Work around g311250 
        function iseq = isequal(ts1,ts2)
            iseq = builtin('isequal',ts1,ts2);
            if iseq && numel(ts1)==1 && numel(ts2)==1
                iseq = eq(ts1,ts2);
            end    
        end              
    end   
end

