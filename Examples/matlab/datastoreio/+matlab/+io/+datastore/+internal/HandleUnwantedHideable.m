classdef (Hidden = true, Abstract) HandleUnwantedHideable < handle
%HANDLEUNWANTEDHIDEABLE Remove unwanted methods or stuff from handle inheritance.
%   Subclasses can use this class whenever unwanted methods like addlistener,
%   listener, findprop, notify, etc., need to be hidden.
%   This class throws undefined method error on the following methods:
%       - ge
%       - gt
%       - le
%       - lt
%       - findobj
%
%   This class hides the following methods:
%       - eq
%       - ne
%       - findprop
%       - addlistener
%       - listener
%       - notify
%
%   See also handle.

%   Copyright 2017 The MathWorks, Inc.

    % behavior for handle class inherited methods.
    methods (Hidden)
        % Methods that we inherit from base handle class, but do not want to support. So error.
        function res = ge(obj, varargin),     matlab.io.datastore.internal.throwUndefinedError(class(obj)); end %#ok<STOUT>
        function res = gt(obj, varargin),     matlab.io.datastore.internal.throwUndefinedError(class(obj)); end %#ok<STOUT>
        function res = le(obj, varargin),     matlab.io.datastore.internal.throwUndefinedError(class(obj)); end %#ok<STOUT>
        function res = lt(obj, varargin),     matlab.io.datastore.internal.throwUndefinedError(class(obj)); end %#ok<STOUT>
        function res = findobj(obj, varargin),matlab.io.datastore.internal.throwUndefinedError(class(obj)); end %#ok<STOUT>

        % methods we inherit from handle, but want to hide.
        function res = eq(varargin),          res = eq@handle(varargin{:});          end
        function res = ne(varargin),          res = ne@handle(varargin{:});          end
        function res = findprop(varargin),    res = findprop@handle(varargin{:});    end
        function res = addlistener(varargin), res = addlistener@handle(varargin{:}); end
        function res = listener(varargin),    res = listener@handle(varargin{:});    end
        function notify(varargin),            notify@handle(varargin{:});            end
    end
end
