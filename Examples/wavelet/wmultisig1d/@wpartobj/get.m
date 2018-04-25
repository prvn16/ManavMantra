function varargout = get(P,varargin)
%GET Get WPARTOBJ object fields contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(P,'FieldName1','FieldName2', ...) returns
%   the contents of the specified fields for the WPARTOBJ
%   object P.
%
%   [...] = GET(P) returns all the field contents of P.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-May-2006.
%   Last Revision: 01-Jun-2006.
%   Copyright 1995-2006 The MathWorks, Inc.

% part_INFO = struct('Method',[],'part_PAR',[],'part_VAR',[]);
% clu_INFO  = struct('NbCLU',[],'IdxCLU',[],'NbInCLU',[],'IdxInCLU',[]);
% Part = struct('Name',[],'NbDAT',[],'NbCLA',[],...
%               'part_INFO',part_INFO,'clu_INFO',clu_INFO);

nbArg = length(varargin);
[varargout{1:nbArg}] = wgfields(Inf,struct(P),varargin{:});