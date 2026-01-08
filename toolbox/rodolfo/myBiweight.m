function [ bi_mean, bi_std ] = myBiweight( x )
% myBiweight calculates the biweight mean and std
%   X - is the input matrix, where the rows are the variables and 
%       columns are the samples
%   outputs:
%   bi_mean - the biweight mean
%   bi_std - the biweight std
%
%   Ref: 
%   Hoaglin, D., Mosteller, F., and J. Tukey 1983. Understanding Robust 
%       and Exploratory Data Analysis, John Wiley and Sons, New York, 447 pp.
%   Lanzante JR. 1996. Resistant, robust and non-parametric techniques for
%       the analysis of climate data: theory and examples, including applications
%       to historical radiosonde station data. International Journal of
%       Climatology, vol.16, 1197-1226.

N   = size(x,2);                % number of values in the sample
% c=6;
c   = 7.5;                     % censor value, it corresponds to a certain number of standard
% c   = 9;   %alterei valor     %                            deviations for a normal distribution:
                                % c=6 is 4 std; c=7.5 is 5 std; c=9 is 6 std.
for i=1:size(x,1)
    X = x(i,:);                 % local copy 
    M   = median(X);            % median of the sample
    MAD = median(abs(X-M));     % median absolute deviation that is the median of the sample
                                % of the absolute values of the differences from the median
    w   = (X-M)/(c*MAD);        % weights for the computation of the biweight mean
    w(abs(w)>1) = 1;            % censoring of the wheights
    bi_mean(i)  = M+ sum((X-M).*(1-w.^2).^2)/sum((1-w.^2).^2); % computation of biwheight mean
    bi_std(i)  = sqrt(N*sum((X-M).^2.*(1-w.^2).^4))/abs(sum((1-w.^2).*(1-5*w.^2))); % computation of biwheight std
    
    clear M MAD w
end

end

