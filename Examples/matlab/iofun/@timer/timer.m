classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) timer < matlab.mixin.SetGet & matlab.mixin.internal.CustomSaveLoadObjectArray
    %MATLAB Timer Object Properties and Methods.
    %
    % Timer properties.
    %   AveragePeriod    - Average number of seconds between TimerFcn executions.
    %   BusyMode         - Action taken when TimerFcn executions are in progress.
    %   ErrorFcn         - Callback function executed when an error occurs.
    %   ExecutionMode    - Mode used to schedule timer events.
    %   InstantPeriod    - Elapsed time between the last two TimerFcn executions.
    %   Name             - Descriptive name of the timer object.
    %   Period           - Seconds between TimerFcn executions.
    %   Running          - Timer object running status.
    %   StartDelay       - Delay between START and the first scheduled TimerFcn execution.
    %   StartFcn         - Callback function executed when timer object starts.
    %   StopFcn          - Callback function executed after timer object stops.
    %   Tag              - Label for object.
    %   TasksExecuted    - Number of TimerFcn executions that have occurred.
    %   TasksToExecute   - Number of times to execute the TimerFcn callback.
    %   TimerFcn         - Callback function executed when a timer event occurs.
    %   Type             - Object type.
    %   UserData         - User data for timer object.
    %
    % timer methods:
    % Timer object construction:
    %   @timer/timer            - Construct timer object.
    %
    % Getting and setting parameters:
    %   get              - Get value of timer object property.
    %   set              - Set value of timer object property.
    %
    % General:
    %   delete           - Remove timer object from memory.
    %   display          - Display method for timer objects.
    %   inspect          - Open the inspector and inspect timer object properties.
    %   isvalid          - True for valid timer objects.
    %   length           - Determine length of timer object array.
    %   size             - Determine size of timer object array.
    %   timerfind        - Find visible timer objects with specified property values.
    %   timerfindall     - Find all timer objects with specified property values.
    %
    % Execution:
    %   start            - Start timer object running.
    %   startat          - Start timer object running at a specified time.
    %   stop             - Stop timer object running.
    %   wait             - Wait for timer object to stop running.
    
    % Copyright 2002-2017 The MathWorks, Inc.
    
    properties (SetAccess = private, Hidden)
        ud = {};
    end
    
    properties (Access = private, Hidden)
        jobject;
    end    

    properties (Access = private, Hidden, Transient)
        id_= "";
    end

    properties (Dependent)
        BusyMode
        ErrorFcn
        ExecutionMode
        Name
        ObjectVisibility
        Period
        StartDelay
        StartFcn
        StopFcn
        Tag
        TasksToExecute
        TimerFcn
        UserData
    end
    
    properties (SetAccess = private, Dependent)
        AveragePeriod
        InstantPeriod
        Running
        TasksExecuted
    end
    
    properties (Constant)
        Type = 'timer';
    end
    
    methods
        function obj = timer(varargin)
            %TIMER Construct timer object.
            %
            %    T = TIMER constructs a timer object with default attributes.
            %
            %    T = TIMER('PropertyName1',PropertyValue1, 'PropertyName2', PropertyValue2,...)
            %    constructs a timer object in which the given Property name/value pairs are
            %    set on the object.
            %
            %    Note that the property value pairs can be in any format supported by
            %    the SET function, i.e., param-value pairs, structures, and
            %    param-value cell array pairs.
            %
            %    Example:
            %       % To construct a timer object with a timer callback mycallback and a 10s interval:
            %         t = timer('TimerFcn',@mycallback, 'Period', 10.0);
            %
            %    See also TIMER/SET, TIMER/TIMERFIND, TIMER/START, TIMER/STARTAT.
            
            % Create the default class.
            mlock
            
            obj.id_ = string(java.util.UUID.randomUUID);
            % this flavor of the constructor is not intended to be for the end-user
            if nargin == 1 && isa(varargin{1}, 'handle') && all(isJavaTimer(varargin{1}))
                obj = makeFromJobject(obj,varargin{1});
                return
            end
            
            if nargin > 0 ...
                    && (isa(varargin{1},'timer') ...
                    || (isstruct(varargin{1}) && isfield(varargin{1}, 'jobject'))) %support for old style timer object
                obj = makeFromStruct(obj,varargin{1});
                mltimerpackage('Add', obj);
                return
            end
            
            obj.jobject = makeDefaultJobject();
            
            if (nargin > 0)
                % user gave PV pairs, so process them by calling set.
                try
                    set(obj, varargin{:});
                catch exception
                    delete(obj);
                    throw(fixexception(exception));
                end
            end
            
            mltimerpackage('Add', obj);
        end
        
        function delete(obj)
            %DELETE Remove timer object from memory.
            %
            %    DELETE(OBJ) removes timer object, OBJ, from memory. If OBJ
            %    is an array of timer objects, DELETE removes all the objects
            %    from memory.
            %
            %    When a timer object is deleted, it becomes invalid and cannot
            %    be reused. Use the CLEAR command to remove invalid timer
            %    objects from the workspace.
            %
            %    If multiple references to a timer object exist in the workspace,
            %    deleting the timer object invalidates the remaining
            %    references. Use the CLEAR command to remove the remaining
            %    references to the object from the workspace.
            %
            %    See also CLEAR, TIMER, TIMER/ISVALID.

            stopWarn = false;
            javaTimer = obj.getJobjects;
            
            try
                % Make sure the timer is stopped before invoking asynchronous delete
                areRunning = logical([javaTimer.isRunning]);
                stopWarn = any(areRunning);
                for i = find(areRunning)
                    javaTimer(i).stop()
                end
                
                % Call the Java method, to trigger an asynchronous delete call.
                javaTimer.Asyncdelete;
            catch 
            end
            
            if stopWarn
                state = warning('backtrace','off');
                warning(message('MATLAB:timer:deleterunning'));
                warning(state);
            end

            mltimerpackage('Delete',obj);
        end
    end
    
    methods % get/set
        
        function set.ObjectVisibility(obj,rhs)
            obj.jobject.ObjectVisibility = rhs;
        end
        
        function val = get.ObjectVisibility(obj)
            val = obj.getProperty('ObjectVisibility');
        end
        
        function set.BusyMode(obj,rhs)
            obj.jobject.BusyMode = rhs;
        end
        
        function val = get.BusyMode(obj)
            val = obj.getProperty('BusyMode');
        end
        
        function set.ErrorFcn(obj,rhs)
            obj.jobject.ErrorFcn = rhs;
        end
        
        function val = get.ErrorFcn(obj)
            val = obj.getProperty('ErrorFcn');
        end
        
        function set.ExecutionMode(obj,rhs)
            obj.jobject.ExecutionMode = rhs;
        end
        
        function val = get.ExecutionMode(obj)
            val = obj.getProperty('ExecutionMode');
        end
        
        function set.Name(obj,rhs)
            obj.jobject.Name = rhs;
        end
        
        function val = get.Name(obj)
            val = obj.getProperty('Name');
        end
        
        function set.Period(obj,rhs)
            obj.jobject.Period = rhs;
        end
        
        function val = get.Period(obj)
            val = obj.getProperty('Period');
        end
        
        function set.StartDelay(obj,rhs)
            obj.jobject.StartDelay = rhs;
        end
        
        function val = get.StartDelay(obj)
            val = obj.getProperty('StartDelay');
        end
        
        function set.StartFcn(obj,rhs)
            obj.jobject.StartFcn = rhs;
        end
        
        function val = get.StartFcn(obj)
            val = obj.getProperty('StartFcn');
        end
        
        function set.StopFcn(obj,rhs)
            obj.jobject.StopFcn = rhs;
        end
        
        function val = get.StopFcn(obj)
            val = obj.getProperty('StopFcn');
        end
        
        function set.Tag(obj,rhs)
            obj.jobject.Tag = rhs;
        end
        
        function val = get.Tag(obj)
            val = obj.getProperty('Tag');
        end
        
        function set.TasksToExecute(obj,rhs)
            obj.jobject.TasksToExecute = rhs;
        end
        
        function val = get.TasksToExecute(obj)
            val = obj.getProperty('TasksToExecute');
        end
        
        function set.TimerFcn(obj,rhs)
            obj.jobject.TimerFcn = rhs;
        end
        
        function val = get.TimerFcn(obj)
            val = obj.getProperty('TimerFcn');
        end
        
        function set.UserData(obj,rhs)
            obj.jobject.UserData = rhs;
        end
        
        function val = get.UserData(obj)
            val = obj.getProperty('UserData');
        end
        
        function val = get.AveragePeriod(obj)
            val = obj.getProperty('AveragePeriod');
        end
        
        function val = get.InstantPeriod(obj)
            val = obj.getProperty('InstantPeriod');
        end
        
        function val = get.Running(obj)
            val = obj.getProperty('Running');
        end
        
        function val = get.TasksExecuted(obj)
            val = obj.getProperty('TasksExecuted');
        end
        
    end
    
    methods (Static=true, Hidden=true)
        obj = loadobj(B)
        obj = loadObjectArray(B)
    end
    
    methods (Hidden=true)
        B = saveObjectArray(obj);
        output = sharedTimerfind(varargin);
        
        function jobj = getJobjects(obj)
            try
                jobj = reshape([obj(:).jobject],size(obj));
            catch
                jobj = [];
                for i = 1:numel(obj)
                    try
                        jobj(i) = obj(i).jobject; %#ok<AGROW>
                    catch
                    end
                end
            end
        end
        
        function [matches,ids] = matchTimers(t,objarray)
            try
                [matches,ids] = ismember(t.id_,[objarray.id_]);
            catch
                valid_lhs = isvalid(t);
                if any(valid_lhs)
                    valid_rhs = isvalid(objarray);
                    rhsIds(valid_rhs) = [objarray(valid_rhs).id_];
                    lhsIDs(valid_lhs) = t(valid_lhs).id_;
                    [matches(valid_lhs),ids(valid_lhs)] = ismember(lhsIDs,rhsIds);
                else
                    matches = false(size(t));
                    ids = zeros(size(t));
                end
            end
        end
    end
    
    methods (Access=private)
        function val = getProperty(obj,name)
            if isvalid(obj)
                j = obj.jobject;
                val = j.(name);
            else
                error(message('MATLAB:class:InvalidHandle'))
            end
        end
    end
end

function obj = makeFromStruct(obj,orig)
if (isa(orig,'timer') && ~isvalid(orig)) || all(~isJavaTimer(orig.jobject(:)))
    error(message('MATLAB:timer:invalid'));
end
len = length(orig.jobject);
% foreach valid object in the original timer object array...
for lcv=1:len
    obj(lcv).jobject = orig.jobject(lcv);
    if isJavaTimer(orig.jobject(lcv))
        % for valid java timers found, make new java timer object,...
        obj(lcv).jobject = handle(com.mathworks.timer.TimerTask);
        obj(lcv).jobject.MakeDeleteFcn(@(){});
        % duplicate copy of settable properties from the old object to the new object,and ...
        propnames = fieldnames(set(orig.jobject(lcv)));
        propvals = get(orig.jobject(lcv),propnames);
        set(obj(lcv).jobject,propnames,propvals);
    end
end
end

function obj = makeFromJobject(obj,javaObjects)
if ~isvector(javaObjects) % not a vector, sorry.
    error(message('MATLAB:timer:creatematrix'));
end

if all(~isJavaTimer(javaObjects))
    % This is ONLY for preserving timer legacy behavior when ALL java
    % objects _started_ out invalid before the constructor call; on the
    % other hand, if they become all invalid during the constructor call, it
    % should return all invalid
    obj = timer.empty;
    return;
end

% make a MATLAB timer object from one or more java timer object(s) if the
% javaObjects get invalid after the isJavaTimer check above, the returned
% timer objects would be invalid
for i = 1:numel(javaObjects)
    obj(i).jobject = javaObjects(i);
end
end

function jobject = makeDefaultJobject()
jobject = handle(com.mathworks.timer.TimerTask);
jobject.setName(['timer-' num2str(mltimerpackage('Count'))]);
jobject.timerFcn = '';
jobject.errorFcn = '';
jobject.stopFcn = '';
jobject.startFcn = '';
jobject.MakeDeleteFcn(@(){});
end

