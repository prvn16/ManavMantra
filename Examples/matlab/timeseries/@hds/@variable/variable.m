function this = variable(var,~)
% Returns instance of @variable class

%   Copyright 1986-2005 The MathWorks, Inc.
this = hds.variable;
this.Name = var;
% 
% 
% 
% 
% ni = nargin;
% if ni==0
%    error('Variable name must be specified.')
% elseif isa(var,'char')
%    var = strrep(deblank(var),' ','_');
%    if var(end)=='_',
%       % Protection against redefining private properties
%       error('Last character of variable name cannot be an underscore.')
%    end
%    if ni==1
%       % Delegate to variable manager
%       this = findvar(hds.VariableManager,var);
%    else
%       % Special signature for Variable manager
%       this = hds.variable;
%       this.Name = var;
%       this.Version = 1;
%    end
% elseif isa(var,'hds.variable')
%    this = var;
% else
%    error('First argument must be a string or a hds.variable object.')
% end
