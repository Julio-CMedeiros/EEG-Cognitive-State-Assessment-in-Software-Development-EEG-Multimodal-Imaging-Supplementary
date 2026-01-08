function [ outlier_ind ] = myFindOutliers( input_var )
%myFindOutliers tries to automatically find outliers
%   Tests for normality by using SW test
%   If normal distributed uses modified z-score
%   If not normal distributed it uses adjusted boxplot
%   
%   This function was updated on 25/11/2017 to take into account outliers
%   in the data when testing for normality. However, it will have further
%   updates in order to get a test that is robust enough
%
%   By Janir Ramos da Cruz @ EPFL and IST

input = reshape(input_var,1,length(input_var)); % local copy
z_criterion = 3.5; % rejection criterion according to literature 
inner_fence = 1.85; % inner_fence criterion for extreme outliers

% Account for outliers in the normality testing
% Do modified z-score since it's robust, we don't care at this stage if
% skewed
ind_tmp = modified_zscore(input);
input_tmp = input; % local copy
% remove outliers for normality test 
% but in other testing we the original data
input_tmp(ind_tmp) = []; 

[h,p,~] = swtest(input_tmp,0.01);

if h==0
    
    outlier_ind = modified_zscore(input);
    
elseif h==1
    
    outlier_ind = adjusted_Boxplot(input);
    
else
end

% the function for the modified fold z-score
% ref: 
% Boris Iglewicz and David Hoaglin (1993), "Volume 16: How to Detect and Handle Outliers", 
% The ASQC Basic References in Quality Control: Statistical Techniques, 
% Edward F. Mykytka, Ph.D., Editor.

    function [indices] = modified_zscore(X);
        
        % calculates the median absolute deviation
        X_mad = median(abs((X-repmat(median(X),1,length(X)))));
        % calculates the modified z-score
        X_zscore = 0.6745*(X-repmat(median(X),1,length(X)))./repmat(X_mad,1,length(X));
        % indices of the outliers
        indices = find(abs(X_zscore) > z_criterion);
        
    end

% the function for the adjusted boxplot
% ref:
% E. Vanderviere; M. Huber (2004). An Adjusted Boxplot for Skewed
% Distributions. COMPSTAT'2004 Symposium, Physica-Verlag/Springer.
%
% G. Brys; M. Hubert; P.J. Rousseeuw (2005). A Robustification of
% Independent Component Analysis. Journal of Chemometrics 19(5-7),
% pp. 364-375.
%
% J.W. Tukey (1977). Exploratory Data Analysis. Addison Wesley.

    function [indices] = adjusted_Boxplot(X);
        
        X_tmp = X; % local copy
        % computes the medcouple
        MC = myMedcouple(X_tmp);
        k1 = -3.5*(MC>=0);
        k1 = k1 - 4*(MC<0);
        k3 = 4*(MC>=0);
        k3 = k3 + 3.5*(MC<0);
        % sort the data
        Y = sort(X_tmp);
        % compute the 25th percentile
        Q1 = median(Y(find(Y<median(Y))));
        % compute the 50th percentile
        Q2 = median(Y);
        % compute the 75th percentile
        Q3 = median(Y(find(Y>median(Y))));
        % compute the Interquartile Range
        IQR = Q3 - Q1;
        % find Q1 outliers
        Outlier_ind1 = find(Y < repmat(Q1 - inner_fence*exp(k1.*MC).*IQR,1,length(Y)));
        % find Q3 outliers
        Outlier_ind2 = find(Y > repmat(Q3 + inner_fence*exp(k3.*MC).*IQR,1,length(Y)));
        % The value of the outliers
        Outliers = Y([Outlier_ind1 Outlier_ind2]);
        % Find the indice of the outliers
        Outliers_ind = ismember(X,Outliers);
        indices = find(Outliers_ind == 1);
        
    end
end