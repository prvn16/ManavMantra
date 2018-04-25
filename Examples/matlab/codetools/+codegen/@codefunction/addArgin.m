function addArgin(hThis,varargin)

% Copyright 2003-2015 The MathWorks, Inc.

for n = 1:numel(varargin)
    if ~isa(varargin{n}, 'codegen.codeargument')
        % Wrap the value in a codeargument
        varargin{n} = codegen.codeargument('Value', varargin{n});
    end
end

argin = get(hThis,'Argin');
set(hThis,'Argin',[argin, varargin{:}]);
