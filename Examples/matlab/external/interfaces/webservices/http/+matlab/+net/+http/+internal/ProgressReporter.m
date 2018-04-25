classdef ProgressReporter < handle
% This class is instantiated by HTTPConnector when the user specifies a
% ProgressMonitorFcn in HTTPOptions and UseProgressMonitor is set.  It saves a
% reference to the user's ProgressMonitor and acts as link between C++ and the
% user's ProgressMonitor.
%
% When a request is sent, HTTPConnector.m sets ProgressMonitor.Maximum to the
% expected number of bytes to be sent and Direction to Request.  C++ code then
% calls out to the update() function to update progress, which determines
% whether it's time to display or update the progress monitor based on
% ProgressMonitor.interval.  If so, it sets the user's ProgressMonitor.Value
% to the number of bytes transferred.
%
% As soon as HTTPConnector receives the header of a ResponseMessage, it sets
% Direction to Response, changes the Maximum, and then during transfer C++ calls
% out to update() again.
%
% When transfer is all done, HTTPConnector destroys this object, which calls
% ProgressMonitor.done() (but does not delete it).
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http.  Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2015-2017 The MathWorks, Inc.
    properties (Access=private)
        ProgressMonitor     % user's matlab.net.http.ProgressMonitor
        StartTime           % datetime we should start reporting progress
        Started = false     % true if started
        Cancel = false
    end
    
    properties (Dependent, GetAccess=private)
        Maximum % the Content-Length, empty if unknown length
        Direction
    end
    
    methods 
        function obj = ProgressReporter(pm)
            if nargin > 0
                if pm.InUse
                    error(message('MATLAB:http:MonitorInUse'));
                end
                obj.ProgressMonitor = pm;
                obj.Direction = matlab.net.http.MessageType.Request;
                pm.InUse = true;
                % The user's pm will call CancelFcn to cancel
                pm.CancelFcn = @(o,e)setCancel(obj);
            end
            function setCancel(obj)
            % On cancel, just set a flag that the next update call will look at
                obj.Cancel = true;
            end
        end
    end
    
    methods 
        function ok = update(obj, value)
        % Called from the C++ InterruptibleStreamCopier to update progress.  
        %   value   - number of bytes transferred
        %   ok      - false if user's ProgressMonitor called the cancel function
            assert(~isempty(obj.StartTime)); % expect Direction was set before this
            % Don't set Value after start of transfer until Interval seconds have
            % elapsed since the last change of direction.
            if obj.Started || datetime('now') > obj.StartTime
                obj.ProgressMonitor.Value = value;
                ok = ~obj.Cancel;
                obj.Started = true;
                if ~ok
                    obj.done();
                end
            else
                ok = true;
            end
        end
    
        function set.Direction(obj, value)
            obj.ProgressMonitor.Direction = value;
            interval = obj.ProgressMonitor.Interval;
            if isempty(interval)
                interval = 2;
            end
            validateattributes(interval, {'numeric'}, ...
                 {'scalar', 'real', 'nonnegative'}, 'ProgressMonitor', 'Interval');
            % TBD implement interval between update calls.  This requires
            % communicating the interval to the HTTPConnectionAdapter where the
            % actual timing will be done (in the InterruptibleStreamCopier).
            if ~obj.Started
                % On each change of direction, if ProgressMonitor has not yet been
                % called to update, postpone first setting of value until interval
                % seconds have elapsed.  One it is started, we don't wait for
                % interval.
                obj.StartTime = datetime('now') + seconds(interval);
            end
        end
        
        function set.Maximum(obj, value)
            obj.ProgressMonitor.Max = value;
        end
        
        function delete(obj)
            obj.done();
        end
    end
    
    methods (Access=private)
        function done(obj)
            if ~isempty(obj.ProgressMonitor) && isvalid(obj.ProgressMonitor)
                obj.ProgressMonitor.done();
                obj.ProgressMonitor.InUse = false;
            end
        end
    end 
end