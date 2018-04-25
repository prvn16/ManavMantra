function varargout = gather( varargin )
%GATHER collect values into current workspace
%    X = GATHER(A), where A is a tall array, returns an array in the local
%    workspace formed from the contents of A.
%
%    X = GATHER(A), where A is a codistributed array, returns a replicated
%    array with all the data of the array on every lab. This would
%    typically be executed inside SPMD statements, or in parallel jobs.
%
%    X = GATHER(A), where A is a distributed array, returns an array in the
%    local workspace with the data transferred from the multiple labs. This
%    would typically be executed outside SPMD statements.
%
%    X = GATHER(A), where A is a gpuArray, returns an array in the local
%    workspace with the data transferred from the GPU device.
%
%    If A is not one of the types mentioned above, then no operation is
%    performed and X is the same as A.
%
%    [X,Y,Z,...] = GATHER(A,B,C,...) gathers multiple arrays.
% 
%    See also TALL, DISTRIBUTED, CODISTRIBUTED, GPUARRAY.

% Copyright 2016 The MathWorks, Inc.

narginchk(1, inf)
if nargout > nargin
    error(message('MATLAB:bigdata:array:GatherInsufficientInputs'));
end

% We only get here if no input has its own gather method, so just copy the
% inputs to the outputs (always at least one).narginchk(1,Inf)
varargout = varargin(1:max(1,nargout));
