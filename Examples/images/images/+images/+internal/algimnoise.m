function b = algimnoise(a, code, classIn, classChanged, p3, p4)
% Main algorithm used by imnoise function. See imnoise for more
% details

% No input validation is done in this function.

%   Copyright 2013 The MathWorks, Inc.

  sizeA = size(a);

  switch code
   case 'gaussian' % Gaussian white noise
    b = a + sqrt(p4)*randn(sizeA) + p3;
    
   case 'localvar_1' % Gaussian white noise with variance varying locally
                     % imnoise(a,'localvar',v)
                     % v is local variance array
    b = a + sqrt(p3).*randn(sizeA); % Use a local variance array
    
   case 'localvar_2' % Gaussian white noise with variance varying locally
                     % Use an empirical intensity-variance relation
    intensity = p3(:); 
    var       = p4(:);
    minI  = min(intensity);
    maxI  = max(intensity);
    b     = min(max(a,minI),maxI);
    b     = reshape(interp1(intensity,var,b(:)),sizeA);
    b     = a + sqrt(b).*randn(sizeA);
    
   case 'poisson' % Poisson noise
    switch classIn
     case 'uint8'
      a = round(a*255); 
     case 'uint16'
      a = round(a*65535);
     case 'single'
      a = a * 1e6;  % Recalibration
     case 'double'
      a = a * 1e12; % Recalibration        
    end
    
    a = a(:);

    %  (Monte-Carlo Rejection Method) Ref. Numerical 
    %  Recipes in C, 2nd Edition, Press, Teukolsky, 
    %  Vetterling, Flannery (Cambridge Press)
    
    b = zeros(size(a),'like', a);
    idx1 = find(a<50); % Cases where pixel intensities are less than 50 units
    if (~isempty(idx1))
      g = exp(-a(idx1));
      em = -ones(size(g));
      t = ones(size(g));
      idx2 = (1:length(idx1))';
      while ~isempty(idx2)
        em(idx2) = em(idx2) + 1;
        t(idx2) = t(idx2) .* rand(size(idx2));
        idx2 = idx2(t(idx2) > g(idx2));
      end
      b(idx1) = em;
    end

    % For large pixel intensities the Poisson pdf becomes 
    % very similar to a Gaussian pdf of mean and of variance
    % equal to the local pixel intensities. Ref. Mathematical Methods
    % of Physics, 2nd Edition, Mathews, Walker (Addison Wesley)
    idx1 = find(a >= 50); % Cases where pixel intensities are at least 50 units
    if (~isempty(idx1))
      b(idx1) = round(a(idx1) + sqrt(a(idx1)) .* randn(size(idx1)));
    end
    
    b = reshape(b,sizeA);
    
   case 'salt & pepper' % Salt & pepper noise
    b = a;
    x = rand(sizeA);
    b(x < p3/2) = 0; % Minimum value
    b(x >= p3/2 & x < p3) = 1; % Maximum (saturated) value
    
   case 'speckle' % Speckle (multiplicative) noise
    b = a + sqrt(12*p3)*a.*(rand(sizeA)-.5);
    
  end

  % Truncate the output array data if necessary
  if strcmp(code,{'poisson'})
    switch classIn
     case 'uint8'
      b = uint8(b); 
     case 'uint16'
      b = uint16(b);
     case 'single'
      b = max(0, min(b / 1e6, 1));
     case 'double'
      b = max(0, min(b / 1e12, 1));
    end
  else    
    b = max(0,min(b,1));
    % The output class should be the same as the input class
    if classChanged,
      b = images.internal.changeClass(classIn, b);
    end
  end
