function solinit = bvpxtend(sol,xnew,ynew,pnew)
%BVPXTEND  Form a guess structure for extending BVP solution. 
%   SOLINIT = BVPXTEND(SOL,XNEW,YNEW) uses solution SOL computed on
%   [a,b] to form a solution guess for the interval extended to XNEW. 
%   The extension point XNEW must be outside the interval [a,b], but 
%   it can be on either side. The vector YNEW provides a guess for the
%   solution at XNEW.
%  
%   SOLINIT = BVPXTEND(SOL,XNEW,EXTRAP) forms the guess at XNEW by
%   extrapolating the solution SOL. EXTRAP is a string that determines 
%   the extrapolation method. EXTRAP has three values:
%     'constant' -- YNEW is value at nearer end point of solution in SOL.
%     'linear' -- YNEW is value at XNEW of linear interpolant to value and 
%                 slope at nearer end point of solution in SOL.
%     'solution' -- YNEW is value of (cubic) solution in SOL at XNEW.
%   The value of EXTRAP is case-insensitive and only the leading, unique
%   portion needs to be specified. SOLINIT = BVPXTEND(SOL,XNEW) is a
%   short form of SOLINIT = BVPXTEND(SOL,XNEW,'constant'). 
%   
%   If there are unknown parameters, values present in SOL are used as
%   initial guess for parameters in SOLINIT.  Specify a different guess
%   PNEW with SOLINIT = BVPXTEND(SOL,XNEW,YNEW,PNEW). With extrapolation, 
%   use SOLINIT = BVPXTEND(SOL,XNEW,EXTRAP,PNEW).  Use [] as place holder
%   for XNEW and YNEW when modifying parameters without changing interval.
%
%   See also BVP4C, BVP5C, BVPINIT.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2016 The MathWorks, Inc.

  if nargin < 2 
    error(message('MATLAB:bvpxtend:NotEnoughInputs'));
  end    
  
  solinit = sol;
  if (nargin == 4)
    solinit.parameters = pnew;
  end
  
  a = sol.x(1);
  b = sol.x(end);
  anew = [];
  bnew = [];
  yanew = [];
  ypanew = [];
  ybnew = [];  
  ypbnew = [];
  ymida = [];  
  ymidb = [];  
  
  % Check for XNEW nearly the same as an end point.
  if abs(xnew - a) <= 100*eps(max(abs(xnew),abs(a)))
    solinit.x(1) = xnew;
    return
  elseif abs(xnew - b) <= 100*eps(max(abs(xnew),abs(b)))
    solinit.x(end) = xnew;
    return 
  end
  
  % Check for XNEW inside [a,b].
  if (a < b)     
    if (xnew < a)
      anew = xnew;
    elseif (xnew <= b)        
      error(message('MATLAB:bvpxtend:XnewInsideInterval'));
    else  
      bnew = xnew;
    end
  else  % cannot be equal, so a > b 
    if (xnew < b)
      bnew = xnew;
    elseif (xnew <= a)        
      error(message('MATLAB:bvpxtend:XnewInsideInterval'));
    else  
      anew = xnew;
    end  
  end

  % Check if need extrapolate and determine the method
  extrap = '';  % no extrapolation -- numerical YNEW provided
  if (nargin < 3) || isempty(ynew)

      extrap = 'constant'; % default constant extrapolation
  
  elseif ischar(ynew) || (isstring(ynew) && isscalar(ynew))  % extrapolation method specified
    extrap = char(ynew);
    extrap_method = {'constant','linear','solution'};          
    idx = strmatch(deblank(lower(extrap)),extrap_method);      
    if isscalar(idx) % unique match found
      extrap = extrap_method{idx};
    else
      error(message('MATLAB:bvpxtend:UnexpectedExtrapolationMethod', extrap));
    end
  
  elseif ~isnumeric(ynew)
    error(message('MATLAB:bvpxtend:YnewIncorrectType'));  
  end  
  
  if strcmp(extrap,'linear')
    switch sol.solver
      case 'bvp4c' 
        ypa = sol.yp(:,1);
        ypb = sol.yp(:,end);
      case 'bvp5c'      
        ypa = sol.idata.yp(:,1);
        ypb = sol.idata.yp(:,end);    
    end
  end
          
  if ~isempty(anew)
    switch extrap
      case ''
        yanew = ynew(:);
        ypanew = zeros(size(yanew));  % Dummy slope      
      case 'constant'
        yanew = sol.y(:,1);
        ypanew = zeros(size(yanew));
      case 'linear'
        yanew = sol.y(:,1) + (anew - a)*ypa;
        ypanew = ypa;        
      case 'solution'
        if ~isfield(sol,'solver') 
          error(message('MATLAB:bvpxtend:NoSolverInSol', extrap));      
        else    
          switch sol.solver 
            case 'bvp4c'
              [yanew,ypanew] = ntrp3h(anew,sol.x(1),sol.y(:,1),...
                                      sol.x(2),sol.y(:,2),...
                                      sol.yp(:,1),sol.yp(:,2));
            case 'bvp5c'  
              [yanew,ypanew] = ntrp4h(anew,sol.x(1),sol.y(:,1),...
                                      sol.x(2),sol.y(:,2),sol.idata.ymid(:,1),...
                                      sol.idata.yp(:,1),sol.idata.yp(:,2));            
            otherwise
              error(message('MATLAB:bvpxtend:UnrecognizedSolverInSol', sol.solver));
          end        
        end  
    end    
    
    if strcmp(sol.solver,'bvp5c')  % compute ymid
        if strcmp(extrap,'solution')
            xmida = (anew + a)/2;
            ymida = ntrp4h(xmida,sol.x(1),sol.y(:,1),...
                           sol.x(2),sol.y(:,2),sol.idata.ymid(:,1),...
                           sol.idata.yp(:,1),sol.idata.yp(:,2));
        else  % linear interpolation
            ymida = (yanew + sol.y(:,1))/2;
        end
    end
    
  end
  
  if ~isempty(bnew)
    switch extrap
      case ''
        ybnew = ynew(:);
        ypbnew = zeros(size(ybnew));  % Dummy slope           
      case 'constant'
        ybnew = sol.y(:,end);
        ypbnew = zeros(size(ybnew));
      case 'linear'
        ybnew = sol.y(:,end) + (bnew - b)*ypb;
        ypbnew = ypb;
      case 'solution'
        if ~isfield(sol,'solver') 
          error(message('MATLAB:bvpxtend:NoSolverInSol', extrap));      
        else    
          switch sol.solver 
            case 'bvp4c'
              [ybnew,ypbnew] = ntrp3h(bnew,sol.x(end-1),sol.y(:,end-1),...
                                      sol.x(end),sol.y(:,end),...
                                      sol.yp(:,end-1), sol.yp(:,end));
              
            case 'bvp5c' 
              [ybnew,ypbnew] = ntrp4h(bnew,sol.x(end-1),sol.y(:,end-1),...
                                      sol.x(end),sol.y(:,end),sol.idata.ymid(:,end),...
                                      sol.idata.yp(:,end-1), sol.idata.yp(:,end));

            otherwise
              error(message('MATLAB:bvpxtend:UnrecognizedSolverInSol', sol.solver));
          end 
        end
    end
    
    if strcmp(sol.solver,'bvp5c')  % compute ymid
        if strcmp(extrap,'solution')
            xmidb = (b + bnew)/2;
            ymidb = ntrp4h(xmidb,sol.x(end-1),sol.y(:,end-1),...
                           sol.x(end),sol.y(:,end),sol.idata.ymid(:,end),...
                           sol.idata.yp(:,end-1), sol.idata.yp(:,end));
        else  % linear interpolation
            ymidb = (sol.y(:,end) + ybnew)/2;
        end
    end                    
    
  end
  
  solinit.x  = [ anew,  sol.x,  bnew];
  solinit.y  = [yanew,  sol.y,  ybnew];
  
  switch sol.solver
    case 'bvp4c'
      solinit.yp = [ypanew, sol.yp, ypbnew];
    case 'bvp5c'    
      solinit.idata.yp   = [ypanew, sol.idata.yp,  ypbnew];
      solinit.idata.ymid = [ymida,  sol.idata.ymid, ymidb];
  end
  
