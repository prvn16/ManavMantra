function P = wpartobj(varargin)
%WPARTOBJ Constructor for the class WPARTOBJ.
%   P = WPARTOBJ(VARARGIN) returns a partition object.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-May-2006.
%   Last Revision: 08-Sep-2006.
%   Copyright 1995-2006 The MathWorks, Inc.

nbIN = length(varargin);
switch nbIN
    case 0 ,    newPart = true;
    case 1 ,    newPart = false;
    otherwise , newPart = true;   %%% A VOIR %%%
end

if newPart
    part_INFO = struct('Method',[],'part_PAR',[],'part_VAR',[]);
    clu_INFO  = struct('NbCLU',[],'IdxCLU',[],'NbInCLU',[],'IdxInCLU',[]);
    P = struct('Name',[],'NbDAT',[],'NbCLA',[],...
        'part_INFO',part_INFO,'clu_INFO',clu_INFO);
else
    P = struct(varargin{1});
end

switch nbIN
    case 0
    case 1
    otherwise , P = wsfields(struct(P),varargin{:});
end
P = class(P,'wpartobj');