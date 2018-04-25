function P = set(P,varargin)
%SET Set WPARTOBJ object fields contents.
%   P = SET(P,'FieldName1',Value1,'FieldName2',Value2,...)
%   sets the contents of the specified fields for the 
%   WPARTOBJ object P.
%   
%   The valid choices for 'FieldName' are:
%

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-May-2006.
%   Last Revision: 01-Jun-2006.
%   Copyright 1995-2006 The MathWorks, Inc.

% part_INFO = struct('Method',[],'part_PAR',[],'part_VAR',[]);
% clu_INFO  = struct('NbCLU',[],'IdxCLU',[],'NbInCLU',[],'IdxInCLU',[]);
% Part = struct('Name',[],'NbDAT',[],'NbCLA',[],...
%               'part_INFO',part_INFO,'clu_INFO',clu_INFO);

P = wsfields(struct(P),varargin{:});
P = wpartobj(P);
