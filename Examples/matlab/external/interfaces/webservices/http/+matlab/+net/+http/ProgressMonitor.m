classdef (Abstract) ProgressMonitor < handle
% ProgressMonitor Abstract base class for an HTTP progress monitor
%   To implement a progress monitor for HTTP requests, create a subclass of
%   this class and specify a ProgressMonitorFcn in HTTPOptions that returns an
%   instance of your subclass. Your ProgressMonitor should listen to changes
%   in various properties of this object to implement a progress update or
%   display of your choice.
%
%   ProgressMonitor properties:
%      Interval     - maximum progress reporting interval (seconds)
%      CancelFcn    - (read-only) function to call to cancel operation
%      Max          - (read-only) maximum bytes in current transfer, if known
%      Direction    - (abstract, MessageType) direction of current transfer
%      Value        - (abstract, integer) number of bytes transferred so far
%      InUse        - (read-only, logical) true if ProgressMonitor is in use 
%
%   If you are implementing a graphical progress indicator, you must implement
%   the Direction and Value properties and you should implement set-methods to
%   monitor their changes. MATLAB initially sets Maximum, CancelFcn and
%   Direction (to MessageType.Request) when you issue RequestMessage.send, and
%   sets Value repeatedly as the the body of the RequestMessage is being sent
%   is taking place. When receipt of the ResponseMessage begins, MATLAB sets
%   Direction to MessageType.Response and again sets Value repeatedly. On the
%   first set of Value after a change of Direction, you may display a
%   graphical progress indicator or other indication of progress, and on each
%   subsequent set of Value you would update that indicator to the current
%   Value. You may also just use this mechanism to programmatically monitor
%   progress.
%
%   Each time MATLAB sets Direction, this indicates the previous transfer is
%   done and a new transfer may start as part of the RequestMessage.send
%   operation. An operation may involve multiple messages in both directions
%   in the case of redirects and authentication. At any time you can call the
%   CancelFcn to cancel the operation, which has the same effect as if you
%   interrupted the send function in the command window.
%
%   MATLAB calls done when all transfers for a send have been completed.
%
%   Following is an example of a ProgressMonitor subclass that displays a
%   progress bar in a MATLAB waitbar. The window has a cancel button which
%   stops transfer. If the message is of unknown length, the waitbar just
%   displays the number of bytes transferred.
%
% classdef MyProgressMonitorNew < matlab.net.http.ProgressMonitor
%     properties
%         ProgHandle
%         Direction matlab.net.http.MessageType
%         Value uint64
%         NewDir matlab.net.http.MessageType = matlab.net.http.MessageType.Request
%     end
%     
%     methods
%         function obj = MyProgressMonitorNew
%             obj.Interval = .01;
%         end
%         
%         function done(obj)
%             obj.closeit();
%         end
%         
%         function delete(obj)
%             obj.closeit();
%         end
%         
%         function set.Direction(obj, dir)
%             obj.Direction = dir;
%             obj.changeDir();
%         end
%         
%         function set.Value(obj, value)
%             obj.Value = value;
%             obj.update();
%         end
%     end
%     
%     methods (Access = private)
%         function update(obj,~)
%             % called when Value is set
%             import matlab.net.http.*
%             if ~isempty(obj.Value)
%                 if isempty(obj.Max)
%                     % no maximum means we don't know length, so message changes on
%                     % every call
%                     value = 0;
%                     if obj.Direction == MessageType.Request
%                         msg = sprintf('Sent %d bytes...', obj.Value);
%                     else
%                         msg = sprintf('Received %d bytes...', obj.Value);
%                     end
%                 else
%                     % maximum known; update proportional value
%                     value = double(obj.Value)/double(obj.Max);
%                     if obj.NewDir == MessageType.Request
%                         % message changes only on change of direction
%                         if obj.Direction == MessageType.Request
%                             msg = 'Sending...';
%                         else
%                             msg = 'Receiving...';
%                         end
%                     end
%                 end
%                 if isempty(obj.ProgHandle)
%                     % if we don't have a progress bar, display it for first time
%                     obj.ProgHandle = ...
%                         waitbar(value, msg, 'CreateCancelBtn', @(~,~)cancelAndClose(obj));
% 
%                     obj.NewDir = MessageType.Response;
%                 elseif obj.NewDir == MessageType.Request || isempty(obj.Max)
%                     % on change of direction or if no maximum known, change message
%                     waitbar(value, obj.ProgHandle, msg);
%                     obj.NewDir = MessageType.Response;
%                 else
%                     % no direction change else just update proportional value
%                     waitbar(value, obj.ProgHandle);
%                 end
%             end
%             
%             function cancelAndClose(obj)
%                 % Call the required CancelFcn and then close our progress bar. This is
%                 % called when user clicks cancel or closes the window.
%                 obj.CancelFcn();
%                 obj.closeit();
%             end
%         end
%         
%         function changeDir(obj,~)
%             % Called when Direction is set or changed. Leave the progress bar displayed.
%             obj.NewDir = matlab.net.http.MessageType.Request;
%         end
%     end
%     
%     methods (Access=private)
%         function closeit(obj)
%             % Close the progress bar by deleting the handle so CloseRequestFcn isn't
%             % called, because waitbar calls our cancelAndClose(), which would cause
%             % recursion.
%             if ~isempty(obj.ProgHandle)
%                 delete(obj.ProgHandle);
%                 obj.ProgHandle = [];
%             end
%         end
%     end
% end
%
%   To use the above:
%
%     req = RequestMessage;
%     opt = HTTPOptions('ProgressMonitorFcn', @MyProgressMonitor, ...
%                       'UseProgressMonitor', true);
%     resp = req.send('http://...some URL...', opt);

% Copyright 2015-2017 The MathWorks, Inc.

    properties
        % Interval - maximum progress reporting interval 
        %   This is the amount of time in seconds after the start of transfer before
        %   the first setting of Value should occur, and a suggested maximum amount
        %   of time between settings of Value, regardless of progress. If the total
        %   time to transfer the data is less than this, Value will not be set, and
        %   if no data has been transferred in Interval seconds since the last
        %   setting of Value, Value may be set again to the same value. In this way
        %   your ProgressMonitor can cancel a transfer (by calling CancelFcn) even if
        %   there is no progress.
        %
        %   This value is a suggestion and not a guarantee: there is no guarantee
        %   that MATLAB will set Value within Interval seconds if there has been no
        %   progress.
        %
        %   The default interval, if this is empty, is 2 seconds. If you want to
        %   specify a different value, you should set this in your constructor. The
        %   minimum interval that will be honored between consecutive settings of
        %   Value when no progress is being made is 0.1 seconds, though it is
        %   possible that Value will be set more often than this if it changes.
        %
        %   Once Value has been set for the first time, there will be no delay in
        %   setting Value for subsequent messages in the same exchange.
        %
        % See also Value, CancelFcn
        Interval double
    end
    
    properties (SetAccess=?matlab.net.http.internal.ProgressReporter)
        % CancelFcn - (read-only function handle) function to call to cancel progress
        %   MATLAB sets this to the function your ProgressMonitor should call to
        %   cancel a transfer. Calling this function has the same effect as
        %   interrupting the operation in the command window.
        CancelFcn function_handle
        % InUse - (read-only logical) indicates that this object is in use
        %   MATLAB sets this to indicate whether it is actively using this
        %   ProgressMonitor during a transfer. This property is provided to avoid
        %   reuse of this object for more than one transfer at a time.
        InUse logical
        % Max - (set-observable) maximum length of the transfer
        %   MATLAB sets this at the beginning of each send and receive operation to
        %   the expected number of bytes to be transferred, based on the
        %   Content-Length header field. This would be the maximum value of any
        %   progress indicator that you might choose to display. If the message does
        %   not contain a Content-Length, this value is [], in which case it is not
        %   possible for you to determine the propertion of the transfer that has
        %   been completed (though you can still monitor changes in Value).
        Max uint64
   end
    
    properties (Abstract)
        % Direction - direction of the transfer
        %   MATLAB sets this to either MessageType.Request or MessageType.Response, to
        %   indicate whether progress is currently being monitored for a
        %   RequestMessage or ResponseMessage. It is empty if no transfer is taking
        %   place.
        %
        % See also MessageType, RequestMessage, ResponseMessage
        Direction matlab.net.http.MessageType
        % Value - length transferred so far
        %   MATLAB sets this property repeatedly to the total number of bytes
        %   transferred for the current message. However it delays setting this
        %   property the first time in an exchange (the duration of a
        %   RequestMessage.send operation) until at least Interval seconds have
        %   elapsed since the start of the current message. You should implement a
        %   set.Value method for this property in order to monitor progress of the
        %   transfer. If you choose to implement the ability to cancel the operation
        %   from within the ProgressMonitor, you can do so from within the set.Value
        %   method (though you can also do so from within any event listener).
        % 
        %   MATLAB may set this to empty at the end of a given transfer, to indicate
        %   transfer in the current direction has ended, though this is not
        %   guaranteed. MATLAB will always set this to empty, prior to calling done,
        %   at the conclusion of all transfers.
        %
        %   You cannot control the frequency at which MATLAB updates this Value.
        %   However MATLAB may attempt to set this value at least once every Interval
        %   seconds, even if no progress has been made, thereby allowing you to call
        %   the CancelFcn if a transfer is not progressing. This value might be zero
        %   if no bytes have been transfered for Interval seconds since transfer has
        %   begun.
        %
        % See also Interval, CancelFcn, Direction, done, matlab.net.http.RequestMessage.send
        Value uint64
    end
    
    methods (Abstract)
        % done Indicates all transfers are done
        %   MATLAB calls this method when all transfers for a given
        %   RequestMessage.send operation have been completed. This indicates the
        %   ProgressMonitor is no longer being used by MATLAB and no more calls will
        %   be made, unless you provide this object to another operation. In this
        %   method you can safely delete any windows or other objects you have
        %   created to display progress.
        %   
        done(obj);
    end
end