function [massType, massM, massFcn, massArgs, dMoptions] = ...
    odemass(FcnHandlesUsed,ode,t0,y0,options,extras)
%ODEMASS  Helper function for the mass matrix function in ODE solvers
%    ODEMASS determines the type of the mass matrix, initializes massFcn to
%    the mass matrix function and creates a cell-array of extra input
%    arguments. ODEMASS evaluates the mass matrix at(t0,y0).  
%
%   See also ODE113, ODE15S, ODE23, ODE23S, ODE23T, ODE23TB, ODE45.

%   Jacek Kierzenka
%   Copyright 1984-2011 The MathWorks, Inc.

massType = 0;  
massFcn = [];
massArgs = {};
massM = speye(length(y0));  
dMoptions = [];    % options for odenumjac computing d(M(t,y)*v)/dy

if FcnHandlesUsed     % function handles used    
  Moption = odeget(options,'Mass',[],'fast');
  if isempty(Moption)
    return    % massType = 0
  elseif isnumeric(Moption)
    massType = 1;
    massM = Moption;            
  else % try feval
    massFcn = Moption;
    massArgs = extras;  
    Mstdep = odeget(options,'MStateDependence','weak','fast');
    switch lower(Mstdep)
      case 'none'
        massType = 2;
      case 'weak'
        massType = 3;
      case 'strong'
        massType = 4;
        
        dMoptions.diffvar  = 3;       % d(odeMxV(Mfun,t,y)/dy
        dMoptions.vectvars = [];  
        
        atol = odeget(options,'AbsTol',1e-6,'fast');
        dMoptions.thresh = zeros(size(y0))+ atol(:);  
        
        dMoptions.fac  = [];
        
        Mvs = odeget(options,'MvPattern',[],'fast'); 
        if ~isempty(Mvs)
          dMoptions.pattern = Mvs;          
          dMoptions.g = colgroup(Mvs);
        end
                  
      otherwise
        error(message('MATLAB:odemass:MStateDependenceMassType'));    
    end      
    if massType > 2   % state-dependent
      massM = feval(massFcn,t0,y0,massArgs{:});
    else   % time-dependent only
      massM = feval(massFcn,t0,massArgs{:});
    end
  end  
  
else % ode-file
  mass = lower(odeget(options,'Mass','none','fast'));

  switch(mass)
    case 'none', return;  % massType = 0
    case 'm', massType = 1;
    case 'm(t)', massType = 2;
    case 'm(t,y)', massType = 3;
    otherwise
      error(message('MATLAB:odemass:InvalidMassProp', mass));
  end
  massFcn = ode;  
  massArgs = [{'mass'}, extras];
  massM = feval(massFcn,t0,y0,massArgs{:});    

end



