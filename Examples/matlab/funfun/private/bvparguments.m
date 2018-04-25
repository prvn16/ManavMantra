function [neqn,nparam,nregions,atol,rtol,nmax,vectorized,printstats] = ...
        bvparguments(solver_name,odefun,bcfun,solinit,options,extras)
%BVPARGUMENTS  Helper function for processing arguments for BVP solvers.
%
%   See also BVP4C, BVP5C, BVPSET.

%   Copyright 2007-2010 The MathWorks, Inc.

    % Handle extra arguments
    if nargin < 6
        extras = {};
    end

    % error/warning introductory messages
    solverNameUpper = upper(solver_name);
    if isempty(options)
        optionalArgumentsStr = '';
    else
        optionalArgumentsStr = ',OPTIONS';
    end
    if ~isempty(extras)        
        optionalArgumentsStr = strcat(optionalArgumentsStr,',P1,P2...');
    end
    errIntro =getString(message('MATLAB:bvparguments:ErrorCallingFun',...
                       solverNameUpper,optionalArgumentsStr));   
    warningIntro =getString(message('MATLAB:bvparguments:WarningCallingFun',...
                           solverNameUpper,optionalArgumentsStr));       
    
    % Validate odefun and bcfun (and solver_name)    
    switch solver_name
        
      case 'bvp5c'  % BVP5C requires function_handles
        if ~isa(odefun,'function_handle')
            error(message('MATLAB:bvparguments:ODEfunNotFunctionHandle', errIntro));  
        end
        if ~isa(bcfun,'function_handle')
            error(message('MATLAB:bvparguments:BCfunNotFunctionHandle', errIntro));  
        end
        ode = odefun;
        bc  = bcfun;
        
      case 'bvp4c' 
        % avoid fevals
        ode = fcnchk(odefun);
        bc  = fcnchk(bcfun);
        
      otherwise
        error(message('MATLAB:bvparguments:SolverNameUnrecognized', solver_name));
    end
    
    % Validate initial guess
    if ~isstruct(solinit)
        error(message('MATLAB:bvparguments:SolinitNotStruct', errIntro));
    elseif ~isfield(solinit,'x')
        error(message('MATLAB:bvparguments:NoXInSolinit', errIntro));
    elseif ~isfield(solinit,'y')
        error(message('MATLAB:bvparguments:NoYInSolinit', errIntro));              
    end

    if isempty(solinit.x) || (length(solinit.x) < 2)
        error(message('MATLAB:bvparguments:SolinitXNotEnoughPts', errIntro));   
    end

    if any( sign(solinit.x(end)-solinit.x(1)) * diff(solinit.x) < 0)
        error (message('MATLAB:bvparguments:SolinitXNotMonotonic', errIntro)); 
    end
    
    if isempty(solinit.y)           
        error(message('MATLAB:bvparguments:SolinitYEmpty', errIntro));  
    end
    
    if size(solinit.y,2) ~= length(solinit.x)
        error(message('MATLAB:bvparguments:SolXSolYSizeMismatch', errIntro)); 
    end

    % Determine problem size
    neqn = size(solinit.y,1);
    % - unknown parameters
    if isfield(solinit,'parameters')
        nparam = numel(solinit.parameters);
    else
        nparam = 0;
    end
    % - multi-point BVPs 
    interfacePoints = find(diff(solinit.x) == 0); 
    nregions = 1 + length(interfacePoints);                      

    % Test the outputs of ODEFUN and BCFUN
    if nparam > 0
        extras = [solinit.parameters(:), extras];
    end                   
    x1 = solinit.x(1);
    y1 = solinit.y(:,1);    
    if nregions == 1
        odeExtras = extras;  
        bcExtras = extras;
        ya = solinit.y(:,1);
        yb = solinit.y(:,end);
    else
        odeExtras = [1, extras];  % region = 1 
        bcExtras = extras;
        ya = solinit.y(:,[1, interfacePoints + 1]); % pass internal interfaces to BC
        yb = solinit.y(:,[interfacePoints,length(solinit.x)]);        
    end
    testODE = ode(x1,y1,odeExtras{:});   
    testBC = bc(ya,yb,bcExtras{:});                        
    if length(testODE) ~= neqn       
        error(message('MATLAB:bvparguments:ODEfunOutputSize', errIntro, neqn)); 
    end    
    if length(testBC) ~= (neqn*nregions + nparam)
        error(message('MATLAB:bvparguments:BCfunOutputSize', errIntro,neqn*nregions + nparam));         
    end
    
    % BVP5C cannot concatenate row vectors with equations for unknown parameters
    if strcmp(solver_name,'bvp5c') && (nparam > 0)
        if size(testODE,2) ~= 1       
            error(message('MATLAB:bvparguments:ODEfunOutputSize', errIntro, neqn)); 
        end
        if size(testBC,2) ~= 1
            error(message('MATLAB:bvparguments:BCfunOutputSize', errIntro, neqn*nregions + nparam));         
        end
    end        
            
    % Extract/validate BVPSET options:
    % - tolerances
    rtol = bvpget(options,'RelTol',1e-3);      
    if ~(isscalar(rtol) && (rtol > 0))
        error(message('MATLAB:bvparguments:RelTolNotPos', errIntro));    
    end
    if rtol < 100*eps
        rtol = 100*eps;
        warning(message('MATLAB:bvparguments:RelTolIncrease', warningIntro, sprintf('%g',rtol)));
    end  
    atol = bvpget(options,'AbsTol',1e-6);
    if isscalar(atol)
        atol = atol(ones(neqn,1));
    else
        if length(atol) ~= neqn
            error(message('MATLAB:bvparguments:SizeAbsTol', errIntro, neqn));  
        end  
        atol = atol(:);
    end
    if any(atol<=0)
        error(message('MATLAB:bvparguments:AbsTolNotPos', errIntro));   
    end  
 
    % - max number of meshpoints
    nmax = bvpget(options,'Nmax',floor(10000/neqn));  

    % - vectorized
    vectorized = strcmp(bvpget(options,'Vectorized','off'),'on');

    % 'vectorized' ODEFUN must return column vectors
    if vectorized
        if size(testODE,2) ~= 1      
            error(message('MATLAB:bvparguments:ODEfunOutputSize', errIntro, neqn)); 
        end
    end
        
    % - printstats
    printstats = strcmp(bvpget(options,'Stats','off'),'on');
    
end  % bvparguments
