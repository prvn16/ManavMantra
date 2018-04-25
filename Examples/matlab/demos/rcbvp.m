function rcbvp
%RCBVP  Example C of Russell and Christiansen solved with BVP4C and BVP5C
%   Example C of Russell and Christiansen [1] solved at very crude tolerances
%   shows the errors controlled by BVP4C and BVP5C are rather different. In
%   particular, it is clear that BVP5C controls the true error. At more
%   stringent tolerances the differences are not visible.
%
%   1. R.D. Russell and J. Christiansen, Adaptive mesh selection stragegies
%      for solving boundary value problems, SIAM J. Numer. Anal., 14 (1978)
%      pp. 59-80.
%
%   See also BVP4C, BVP5C, BVPINIT, BVPSET, FUNCTION_HANDLE.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2014 The MathWorks, Inc.

a = 1/(3*pi);
b = 1;
solinit = bvpinit(linspace(a,b,10),[1; 1]);
opts = bvpset('FJacobian',@jac,'RelTol',0.1,'AbsTol',0.1,'Stats','on');

fprintf('\n  Solution obtained with BVP4C: \n');
sol4 = bvp4c(@odes,@bcs,solinit,opts);

fprintf('\n  Solution obtained with BVP5C: \n');
sol5 = bvp5c(@odes,@bcs,solinit,opts);

xplot = linspace(a,b,200);
yplot = truey(xplot);

figure
plot(xplot,yplot(1,:),'k',sol4.x,sol4.y(1,:),'ro',sol5.x,sol5.y(1,:),'b*')
title('Example C of Russell and Christiansen')
legend('True','BVP4C','BVP5C','Location','SouthEast')
axis([0.1 1 -1.1 1.1])
xlabel('{\bf{Very}} crude tolerances show the solvers control different errors.')
ylabel('solution y')

% -----------------------------------------------------------------------
% Nested functions -- b is provided by the outer function.
%

   function dydx = odes(x,y)
      dydx = [ y(2);
         -2*y(2)/x - y(1)/x^4];
   end  % odes
% -----------------------------------------------------------------------

   function dFdy = jac(x,y)
      dFdy = [   0,        1;
         -1/x^4    -2/x ];
   end  % jac
% -----------------------------------------------------------------------

   function res = bcs(ya,yb)
      res = [ ya(1);
         yb(1)-sin(b)];
   end  % bcs
% -----------------------------------------------------------------------

   function v = truey(x)
      v = [  sin(1./x);
         -cos(1./x)./x.^2 ];
   end  % truey
% -----------------------------------------------------------------------

end  % rcbvp
