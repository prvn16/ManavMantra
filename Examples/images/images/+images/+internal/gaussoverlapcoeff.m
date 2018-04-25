function area = gaussoverlapcoeff(mu1, mu2, sigma1, sigma2)
% GAUSSOVERLAPCOEFF Overlapping Coefficient between two 1D normal distributions.
% 
% It is the integral over the entire real line of min(N(x|mu1, sigma1),
% N(x|mu2,sigma2)).
% 
% This is an internal function and can change without notice in future
% releases.

%   Copyright 2014 The MathWorks, Inc.

validateattributes(mu1,{'double','single'},{'scalar','real','finite'});
validateattributes(mu2,{'double','single'},{'scalar','real','finite'});
validateattributes(sigma1,{'double','single'},{'scalar','real','finite','nonnegative'});
validateattributes(sigma2,{'double','single'},{'scalar','real','finite','nonnegative'});

if sigma1 == sigma2
    % When both pdfs have the same variance
    if sigma1 == 0
        % Case 1: Equal and zero variance
        area = double(mu1 == mu2);
    else
        % Case 2: Equal, but non-zero variance 
        mu_shift = - 1/2 * abs(mu1 - mu2);
        area = 2 * gaussiancdf(mu_shift, 0, sigma1);
    end
    
else
    % When the two PDFs have different variances
    if sigma1 > sigma2
        % swap sigma1 and sigma2, swap mu1 and mu2
        tmp = sigma1; sigma1 = sigma2; sigma2 = tmp;
        tmp = mu1; mu1 = mu2; mu2 = tmp;
    end
    
    if (sigma1 == 0)
        % Case 3: Different variances but one has zero variance        
        area = exp(-0.5 * ((mu1 - mu2)./sigma2).^2) ./ (sqrt(2*pi) .* sigma2);
        
    else        
        % Case 4: Different and non-zero variances
        tau1 = 1 / sigma1^2; tau2 = 1 / sigma2^2 ; 
        % Two intersection points (pdf curve). Compute location of two
        % intersections, solve Ax^2 + Bx + C = 0;
        A = (tau1 - tau2);
        B = -2 * (tau1 * mu1 - tau2 * mu2);
        C = tau1*mu1^2 - tau2*mu2^2 - log(tau1) + log(tau2);
        
        d = sqrt(B^2 - 4*A*C);
        
        assert(isreal(d), 'Determinant negative - should not happen.')
        % Find two points of intersection
        x_left = (-B - d) / (2 * A);
        x_right = (-B + d) / (2 * A);
        
        area1 = gaussiancdf(x_left, mu1, sigma1) + (1 - gaussiancdf(x_right, mu1, sigma1));
        area2 = gaussiancdf(x_right, mu2, sigma2) - gaussiancdf(x_left, mu2, sigma2);
        area = area1 + area2;
    end
        
end

end

function p = gaussiancdf(x, mu, sigma)

p = 0.5 * erfc(-((x-mu)/sigma) ./ sqrt(2));

end