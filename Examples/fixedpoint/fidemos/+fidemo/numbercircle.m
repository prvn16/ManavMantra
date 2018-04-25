function numbercircle(fmt,displaymode,clockwise)
%NUMBERCIRCLE Plot a two's complement circle of numbers.
%   NUMBERCIRCLE(FMT) plots a circle of two's complement numbers
%   where  FMT = [W F] is a two-vector of W=wordlength, F=fractionlength.
%   If FMT is missing or empty, the default is FMT = [3 2].  Zero is on the
%   positive x-axis, and the numbers go toward the positive y-axis.
%
%   NUMBERCIRCLE(Q) plots the number circle, where Q is a Quantizer object.
%
%   Examples:
%     numbercircle
%     numbercircle([3 0])
%     q=quantizer('ufixed',[3 0]);numbercircle(q)
%
%   See also QUANTIZER.

%   Copyright 1999-2011 The MathWorks, Inc.

% Default parameters
if nargin<1, fmt = []; end
if nargin<2, displaymode=[]; end
if nargin<3, clockwise = []; end
if isempty(fmt), fmt = [3 2]; end
if isempty(clockwise), clockwise=1; end
if isempty(displaymode), displaymode='pow2'; end

% The 
if isquantizer(fmt)
  q = fmt;
else
  % The quantizer that is used
  q=quantizer('fixed',fmt);
end

switch q.mode
 case {'double','single','float','none'}
  error('NUMBERCIRCLE is only defined for fixed-point quantizers.')
end

% Form a data vector, x, over the range of the quantizer.
[a,b] = range(q);
x = (a:eps(q):b)';

% Form an angle vector, t, around the circle, and compute the coordinates,
% (c,s) of the points around the circle.
n = length(x);
switch mode(q)
 case 'fixed'
  t = (-n/2:n/2-1)*2*pi/n;
 case 'ufixed'
  t = (0:n-1)*2*pi/n;
end
if clockwise
  t = -t + pi/2;
end
c = cos(t); s = sin(t);

% Form up the binary string representation
f = fractionlength(q);
w = wordlength(q);
bin = num2bin(q,x);

% Form up the string 'binary representation = decimal value' using the
% "equivalence" sign for = (three horizontal lines instead of two in "=").
equiv = ' \equiv '; equiv = equiv(ones(size(bin,1),1),:);
equals = ' = '; equals = equals(ones(size(bin,1),1),:);


switch displaymode
 case 'pow2'
  if f == 0
    % Integers
    num = [bin equiv num2str(num2int(q,x))];
  else
    bin = add_dot_to_bin(bin,w,f);
    % *2^-f
    div = '\cdot 2^{-'; div = div(ones(size(bin,1),1),:);
    leftbrace = '}'; leftbrace = leftbrace(ones(size(bin,1),1),:);
    den = num2str(f); den = den(ones(size(bin,1),1),:);
    num = [bin equiv num2str(num2int(q,x)) div den leftbrace equals num2str(x)];
  end
 case 'rational'
  if f == 0
    % Integers
    num = [bin equiv num2str(num2int(q,x))];
  else
      bin = add_dot_to_bin(bin,w,f);
    % Fractions
    div = '/'; div = div(ones(size(bin,1),1),:);
    den = num2str(2^f); den = den(ones(size(bin,1),1),:);
    num = [bin equiv num2str(num2int(q,x)) div den];
  end
 case 'decimal'
  num = [bin equiv num2str(x)];  
 otherwise
  error('Choices for display mode are pow2, rational, and decimal');
end

figure(gcf);clf

% Plot the text around the circle.
h = text(c,s,num,'horizontalalignment','center',...
         'verticalalignment','middle',...
         'interpreter','tex');
t2 = linspace(0,2*pi,128);
c2 = cos(t2);
s2 = sin(t2);
line(c2,s2,'color',.9*[1 1 1]);

% Set the figure color to be complimentary to the text color.
set(gcf,'color',~get(h(1),'color'))

axis([-1.1 1.1 -1.1 1.1])
axis square
axis equal
axis off

function bin = add_dot_to_bin(bin,w,f)
    if w >= f && f >= 0
        % Put the binary point in if it is within the word
        dot = '.';dot = dot(ones(size(bin,1),1),:);
        bin = [bin(:,1:w-f),dot,bin(:,w-f+1:end)];
    end
