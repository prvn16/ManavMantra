function out = startMultiExecution(varargin)
%startMultiExecution start an evaluation session that expands over multiple
% gather statements.
%
% Syntax:
%   session = matlab.bigdata.internal.startMultiExecution() creates a
%   multiple gather execution that uses the default progress reporting.
%
%   session = matlab.bigdata.internal.startMultiExecution(...
%           'OutputFunction', fcn, 'PrintBasicInformation', tf) disables
%   the default progress reporting and calls output function on each
%   progress tic. If PrintBasicInformation is true, the progress reporting
%   header/tail will still be printed.
%
%  The output function must have signature:
%     function fcn(progressValue, passIndex, numPasses);
%  Where progressValue is a value between 0 and 1, passIndex is the current
%  pass index since the start of evaluation and numPasses is NaN.
%
% Example:
%
%  function fcn(in)
%  session = matlab.bigdata.internal.startMultiExecution();
%  for ii = 1:10
%     gather(mean(in));
%  end
%  endMultiExecution(session);
%
%  function fcn(in)
%  session = matlab.bigdata.internal.startMultiExecution('OutputFunction', @(varargin)disp(varargin));
%  for ii = 1:10
%     gather(mean(in));
%  end
%  endMultiExecution(session);

%   Copyright 2016 The MathWorks, Inc.

out = matlab.bigdata.internal.executor.ExecutionSession(varargin{:});
