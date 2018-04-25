function s = logreport(varargin)
%LOGREPORT Quantization report logging
%   LOGREPORT(A) displays the min, max, number of underflows, number of
%   overflows, and number of quantization operations for Fixed-Point object fi.
%
%   LOGREPORT(A, B, ...) displays the report for each fi object A, B, etc.
%
%   Example:
%     
%     fipref('LoggingMode','On');
%     A = fi(pi);
%     B = fi(randn(10),1,8,7);
%     q = quantizer;
%     y = quantize(q,randn(100,1));
%     logreport(A,B,q)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/QUANTIZE 

%   Thomas A. Bryan, 5 April 2005
%   Copyright 1999-2011 The MathWorks, Inc.



% We might trigger a lot of warnings that we don't want to see, so turn
% them off and save their states.
[last_warn_msg, last_warn_id] = lastwarn;
warn_id = {'fixed:qlogger:loggingReset', ...
           'fixed:qlogger:loggingOff', ...
           'fixed:qlogger:loggingOffAndReset', ...
          };
for k = 1:length(warn_id)
  warn_state = warning('off',warn_id{k});
end

fprintf('%12s%15s%15s%15s%15s%15s\n',' ','minlog','maxlog',...
        'nunderflows','noverflows','noperations') 
struct_index = 0;
for k=1:length(varargin)
  q = varargin{k};
  if isa(q,'embedded.fi') || isa(q,'embedded.quantizer')
    name = inputname(k);
    if isempty(name)
      name = 'ans';
    end
    log_report_line(q,name)
    if nargout>0
      struct_index = struct_index+1;
      s(struct_index).name        = name;
      s(struct_index).minlog      = q.minlog;
      s(struct_index).maxlog      = q.maxlog;
      s(struct_index).nunderflows = q.nunderflows;
      s(struct_index).noverflows  = q.noverflows;
      s(struct_index).noperations = q.noperations;
    end
  end
end
% Reinstate the warnings
warning(warn_state)
lastwarn(last_warn_msg, last_warn_id);


function log_report_line(q,name)
if isempty(q.minlog) || (q.maxlog < q.minlog)
  % fi was reset
  fprintf('%12s%15s%15s%15s%15s%15s',name,'reset','reset','reset','reset','reset');
else
  fprintf('%12s%15.4g%15.4g%15d%15d%15d',...
          name, q.minlog, q.maxlog, ...
          q.nunderflows, q.noverflows, q.noperations);
end
fprintf('\n')
