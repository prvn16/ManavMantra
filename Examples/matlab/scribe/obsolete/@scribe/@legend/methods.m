function varargout = methods(this,fcn,varargin)
%METHODS Methods for legend class

%   Copyright 1984-2011 The MathWorks, Inc.

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    varargout{1} = get(m,'Name');
    return;
end

args = [{fcn,this},varargin];
if nargout == 0
  feval(args{:});
else
  [varargout{1:nargout}] = feval(args{:});
end

function handled = ploteditbup(~, ~)
handled = false;

function bdowncb(~,~,~)

function tbdowncb(~,~)

function refresh_cb(~,~,~)

function delete_cb(~,~,~)

function localOpenPropertyEditor(~,~,~)

function localGenerateMCode(~,~,~)
