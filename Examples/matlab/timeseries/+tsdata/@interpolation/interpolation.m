classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) interpolation
    
    %Defines properties for @interpolation class.
    
    % Copyright 2005-2016 The MathWorks, Inc.
    
    properties
        Fhandle;
        Name = '';
    end
    properties (Hidden = true, GetAccess = protected, SetAccess = protected)
        Version = 10.1;
    end       
    methods
        
        function this = interpolation(varargin)
            
            if nargin==0
                return;
            else
                interpMethod = varargin{1};
            end
            
            
            if ischar(interpMethod) || isstring(interpMethod)
                this.Fhandle = {@tsinterp char(interpMethod)};
                this.Name = interpMethod;
            elseif isa(interpMethod,'function_handle')
                this.Fhandle = {interpMethod};
                if isempty(inputname(1))
                    this.Name = 'myFuncHandle';
                else
                    this.Name = inputname(1);
                end
            end
        end
        
        function out = interpolate(h,time,data,t,timedim,noduptimes)
            %INTERPOLATE Performs interpolation using the interpolation object.
            %
            %   INTERP_DATA = INTERPOLATE(H,TIME,DATA,INTERP_TIME) where H is the
            %   interpolation object, TIME is the original time vector, DATA is the
            %   original data array, and INTERP_TIME is the target time vector for the
            %   interpolation.
            %
            %   INTERP_DATA = INTERPOLATE(H,TIME,DATA,INTERP_TIME,DIM) where DIM is the
            %   specified dimension which is aligned with time vector. For example, if
            %   TIME is 10x1 and DATA is 5x6x10, you must specify DIM to be 3 to align
            %   the 3rd dimension of DATA to TIME.
            %
            
            % Default value for noduptimes is false
            if nargin<=5
                noduptimes = false;
            end
            
            % Force time to be aligned with the specified dimension before passing
            % to the interpolation function which always assumes that time is
            % aligned with the 1st dimension
            if nargin>=5 && ~isempty(timedim)
                n = ndims(data);
                data = permute(data,[timedim 1:(timedim-1) (timedim+1):n]);
            end
            
            % h.fhandle is either a function_handle or a cell array where
            % the first element is a function_handle. If additional
            % arguments beyond t,T,X are allowed pass the noduptimes
            % variable.
            if iscell(h.fhandle)
                fH = h.fhandle{1};
                if nargin(fH)>= length(h.fhandle)-1+4
                    out = tsarrayFcn({h.fhandle{:} t}, time, data, length(t),noduptimes); %#ok<CCAT>
                else
                    out = tsarrayFcn({h.fhandle{:} t}, time, data, length(t)); %#ok<CCAT>
                end
            elseif isa(h.fhandle,'function_handle')
                % Interpolation always acts independently on 'columns' and so can
                % be deferred to the tsarrayFcn for handling NaNs
                if nargin(h.fhandle)>= 4
                    out = tsarrayFcn({h.fhandle t}, time, data, length(t),noduptimes);
                else
                    out = tsarrayFcn({h.fhandle t}, time, data, length(t));
                end
            else
                error(message('MATLAB:tsdata:interpolation:interpolate:invalfhandle'))
            end
            
            % If the data matrix was permuted to get time to be aligned with the
            % first dim, permute back
            if nargin>=5 && ~isempty(timedim)
                out = permute(out,[2:timedim 1 (timedim+1):n]);
            end
            
        end
    end
    methods (Static = true)
        function this = loadobj(obj)
            if isstruct(obj)
                this = tsdata.interpolation;
                if isfield(obj,'Fhandle')
                    this.Fhandle = obj.Fhandle;
                end
                if isfield(obj,'Name')
                    this.Name = obj.Name;
                else
                    this.Name = '';
                end
            elseif isa(obj,'tsdata.interpolation')
                this = obj;
            else
                error(message('MATLAB:tsdata:interpolation:loadobj:invloadinterp'));
            end
        end
        
        function linIterpolation = createLinear
            persistent h;
            
            if isempty(h)
                h = tsdata.interpolation('linear');
            end
            linIterpolation = h;            
        end
        
        function linIterpolation = createZOH
            persistent h;
            
            if isempty(h)
                h = tsdata.interpolation('zoh');
            end
            linIterpolation = h;            
        end
    end
end

