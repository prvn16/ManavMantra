function [odefinal,bcfinal,jacfinal,bcjacfinal,Joptions,dBCoptions] = ...
        bvpfunctions(solver_name,odefun,bcfun,options,...
                     neqn,nparam,nregions,extras)
%BVPFUNCTIONS  Helper function for processing functional arguments for BVP solvers.
%
%   See also BVP4C, BVP5C, BVPSET.

%   Copyright 2007-2008 The MathWorks, Inc.

    % handle multipoint BVP
    if nargin < 7
        nregions = 1;
    end
    
    % handle extra arguments
    if nargin < 8
        extras = {};
    end
    
    % Jacobian functions
    jac = bvpget(options,'FJacobian',[]);
    if ~( isempty(jac) || isa(jac,'function_handle') || ischar(jac) || isa(jac,'inline') || ...
          (nparam == 0 && isnumeric(jac) || (nparam > 0 && iscell(jac)))) 
        error(message('MATLAB:bvpfunctions:InvalidFJacobian'));  
    end
    bcjac = bvpget(options,'BCJacobian',[]);
    if ~( isempty(bcjac) || isa(bcjac,'function_handle') || ischar(bcjac) || ...
          iscell(bcjac) || isa(bcjac,'inline')) 
        error(message('MATLAB:bvpfunctions:InvalidBCJacobian'));  
    end            
    
    % make functions feval-free
    ode = fcnchk(odefun);
    bc  = fcnchk(bcfun);
    if ischar(jac)
        jac = str2func(jac);
    end
    if ischar(bcjac)
        bcjac = str2func(bcjac);
    end        
    
    odefinal = ode;
    bcfinal = bc;
    jacfinal = jac;
    bcjacfinal = bcjac;    
    
    % incorporate known parameters (for BVP4C)
    if ~isempty(extras) && strcmp(solver_name,'bvp4c')
        if nparam == 0 
            if nregions == 1
                odefinal = @(x,y) ode(x,y,extras{:});
                if isa(jac,'function_handle')
                    jacfinal = @(x,y) jac(x,y,extras{:});
                end
            else
                odefinal = @(x,y,region) ode(x,y,region,extras{:});
                if isa(jac,'function_handle')
                    jacfinal = @(x,y,region) jac(x,y,region,extras{:});
                end
            end
            bcfinal = @(ya,yb) bc(ya,yb,extras{:});
            if isa(bcjac,'function_handle')
                bcjacfinal = @(ya,yb) bcjac(ya,yb,extras{:});
            end
        else
            if nregions == 1
                odefinal = @(x,y,p) ode(x,y,p,extras{:});
                if isa(jac,'function_handle')
                    jacfinal = @(x,y,p) jac(x,y,p,extras{:});
                end
            else
                odefinal = @(x,y,region,p) ode(x,y,region,p,extras{:});
                if isa(jac,'function_handle')
                    jacfinal = @(x,y,region,p) jac(x,y,region,p,extras{:});
                end
            end                
            bcfinal = @(ya,yb,p) bc(ya,yb,p,extras{:});
            if isa(bcjac,'function_handle')
                bcjacfinal = @(ya,yb,p) bcjac(ya,yb,p,extras{:});
            end
        end
    end            
    
    % incorporate unknown parameters (for BVP5C)
    if (nparam > 0) && strcmp(solver_name,'bvp5c')
        if nregions == 1
            odefinal = @odeParameters;
            if ~isempty(jac) 
                jacfinal = @jacParameters;
            end
            bcfinal  = @bcParameters;
            if ~isempty(bcjac) 
                bcjacfinal = @bcjacParameters;
            end
        else
            odefinal = @odeRegionParameters;
            if ~isempty(jac) 
                jacfinal = @jacRegionParameters;
            end
            bcfinal  = @bcRegionParameters;
            if ~isempty(bcjac)                 
                bcjacfinal = @bcjacRegionParameters;                
            end
        end
    end
    
    % data for numerical Jacobians
    switch solver_name
      case 'bvp4c'  
        total_eqns = neqn;
      case 'bvp5c'
        total_eqns = neqn + nparam;  % add equations for unknown parameters
    end    
    Joptions = [];
    dBCoptions = [];
    threshval = 1e-6;
    if isempty(jacfinal)
        Joptions.diffvar = 2;  % dF(x,y)/dy
        vectorized = strcmp(bvpget(options,'Vectorized','off'),'on');
        if vectorized  % xy-vectorized   
            Joptions.vectvars = [1,2]; 
        else
            Joptions.vectvars = [];
        end
        Joptions.thresh = threshval(ones(total_eqns,1));
    end  
    if isempty(bcjacfinal)
        dBCoptions.vectvars = [];
        dBCoptions.thresh = threshval(ones(nregions*total_eqns,1));
        dBCoptions.fac_dya = [];
        dBCoptions.fac_dyb = [];
    end  

% ---------------------------------------------------------
% Nested functions
% ---------------------------------------------------------
    
    function f = odeParameters(x,y)
        p = y(neqn+1:neqn+nparam,1);  % extract p from y(:,1)
        % add trivial equations for unknown parameters
        f = [ ode(x,y(1:neqn,:),p);
              zeros(nparam,numel(x))];
    end  % odeParameters
    
    % ---------------------------------------------------------
  
    function res = bcParameters(ya,yb)
        p = ya(neqn+1:neqn+nparam);   % extract p from ya
        res = bc(ya(1:neqn),yb(1:neqn),p);
    end  % bcParameters
    
    % ---------------------------------------------------------
  
    function J = jacParameters(x,y)
        if iscell(jac)  % constant Jacobians 
            dfdy = jac{1};
            dfdp = jac{2};
        else
            p = y(neqn+1:neqn+nparam,1);   % extract p from y(:,1)
            [dfdy,dfdp] = jac(x,y(1:neqn,:),p);
        end
        % add trivial equations for unknown parameters                                                                                    
        J = [dfdy, dfdp;
             zeros(nparam,neqn+nparam)];
    end  % jacParameters
    
    % ---------------------------------------------------------
  
    function [dya,dyb] = bcjacParameters(ya,yb)
        if iscell(bcjac)  % constant Jacobians
            dbcdya = bcjac{1};
            dbcdyb = bcjac{2};
            dbcdp  = bcjac{3};
        else 
            p = ya(neqn+1:neqn+nparam);   % extract p from ya
            [dbcdya,dbcdyb,dbcdp] = bcjac(ya(1:neqn),yb(1:neqn),p);
        end
        dya = [dbcdya, dbcdp];
        dyb = [dbcdyb, zeros(size(dbcdp))];        
    end  % bcjacParameters

    % ---------------------------------------------------------

    function f = odeRegionParameters(x,y,region)
        p = y(neqn+1:neqn+nparam,1);  % extract p from y(:,1)
        % add trivial equations for unknown parameters
        f = [ ode(x,y(1:neqn,:),region,p);
              zeros(nparam,numel(x))];
    end  % odeRegionParameters
    
    % ---------------------------------------------------------

    function res = bcRegionParameters(Ya,Yb)
        p = Ya(neqn+1:neqn+nparam,1);   % extract p from Ya(:,1)
        res1 = bc(Ya(1:neqn,:),Yb(1:neqn,:),p);
        res2 = Ya(neqn+1:neqn+nparam,2:end) - Yb(neqn+1:neqn+nparam,1:end-1);
        res = [res1;res2(:)];        
    end  % bcRegionParameters
    
    % ---------------------------------------------------------
         
    function J = jacRegionParameters(x,y,region)
        if iscell(jac)  % constant Jacobians 
            dfdy = jac{1};
            dfdp = jac{2};
        else
            p = y(neqn+1:neqn+nparam,1);   % extract p from y(:,1)
            [dfdy,dfdp] = jac(x,y(1:neqn,:),region,p);
        end
        % add trivial equations for unknown parameters                                                                                    
        J = [dfdy, dfdp;
             zeros(nparam,neqn+nparam)];
    end  % jacRegionParameters

    % ---------------------------------------------------------
  
    function [dYa,dYb] = bcjacRegionParameters(Ya,Yb)            
        if iscell(bcjac)  % constant Jacobians
            dbcdya = bcjac{1};
            dbcdyb = bcjac{2};
            dbcdp  = bcjac{3};
        else 
            p = Ya(neqn+1:neqn+nparam,1);   % extract p from Ya(:,1)
            [dbcdya,dbcdyb,dbcdp] = bcjac(Ya(1:neqn,:),Yb(1:neqn,:),p);
        end

        % nBCs specified by the user. The rest coming from continuity of param(s).
        nbcs = nregions*neqn + nparam; 
        
        dYa = zeros(nregions*(neqn+nparam));
        dyidx = (1:neqn);
        dpidx  = (neqn+1:neqn+nparam);
        dbcidx = (1:neqn);
        for i = 1 : nregions
            dYa(1:nbcs,dyidx) = dbcdya(:,dbcidx);        
            if i == 1
                % boundary conditions for parameters
                dYa(1:nbcs,dpidx) = dbcdp;
            else 
                % continuity conditions for parameters
                dYa(nbcs+(i-2)*nparam+(1:nparam),dpidx) = eye(nparam);
            end            
            dyidx = dyidx + (neqn + nparam);
            dpidx = dpidx + (neqn + nparam);
            dbcidx = dbcidx + neqn;
        end
        
        dYb = zeros(nregions*(neqn+nparam));        
        dyidx = (1:neqn);
        dpidx  = (neqn+1:neqn+nparam);
        dbcidx = (1:neqn);
        for i = 1 : nregions
            dYb(1:nbcs,dyidx) = dbcdyb(:,dbcidx);        

            if i < nregions
                % continuity conditions for parameters
                dYb(nbcs+(i-1)*nparam+(1:nparam),dpidx) = -eye(nparam);
            end
                
            dyidx = dyidx + (neqn + nparam);
            dpidx = dpidx + (neqn + nparam);
            dbcidx = dbcidx + neqn;
        end
        
    end  % bcjacRegionParameters

% ---------------------------------------------------------    

end  % bvpfunctions
