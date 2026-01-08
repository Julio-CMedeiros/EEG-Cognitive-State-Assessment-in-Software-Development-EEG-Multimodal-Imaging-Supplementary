function [MC] = myMedcouple(X)

% Aims to compute the medcouple measure, a robust measure of skewness
% for a skewed distribution. Takes into account cases where the
% observations are equal to the median of the series.
%
% Data in 'X' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% [MC] = medcouple(X) returns the following:
% MC    - vector with the medcouple measure of the data series
%
% Ref:
% G. Brys; M. Hubert; A. Struyf (2004). A Robust Measure of Skewness.
% Journal of Computational and Graphical Statistics 13(4), 996-1017.

X = reshape(X,length(X),1);
[n, c] = size(X);

[s_X,iX] = sort(X);
X_med = median(X);
z = s_X - repmat(X_med,n,1);

MC = zeros(1,c);
for w = 1:c,
[ip, jp] = find(z(:,w)>=0); % These are the positions in z of z+
[im, jm] = find(z(:,w)<=0); % These are the positions in z of z-

p = size(ip,1);
q = size(im,1);

[mi, mj] = ind2sub([p,q],1:p*q); % Positions of all combinations of z+
% and z- as elements in a pxq matrix

zp = z(ip,w); % z+ repeated to account for all cells in the matrix
zm = z(im,w); % z- repeated to account for all cells in the matrix

h = (zp(mi)+zm(mj))./(zp(mi)-zm(mj)); % same size as mi, mj

[ipz,jpz]= find(zp==0); % row numbers of z+ = 0, i.e., X_{i} = median(X)
[imz,jmz]= find(zm==0); % row numbers of z- = 0, i.e., X_{i} = median(X)
piz = ismember(mi,ipz); % positions in mi where z+=0
pjz = ismember(mj,imz); % positions in mi where z-=0
zmember = piz+pjz; % same size as mi, mj
pijz = find(zmember == 2); % positions where z+ = z- = 0, i.e., X_{i} =
% = X_{j} = median(X)
[indi,indj] = ind2sub([p,q],pijz); % pxq matrix position of the zero entries
indi = indi - min(indi) + 1; % row position of the zero entries as if they
% were in a separated matrix
indj = indj - min(indj) + 1; % column position of the zero entries as if they
% were in a separated matrix

for i=1:size(pijz,2),
    if (indi(i) + indj(i) - 1) > size(find(z==0),1),
    h(pijz(i)) = 1;
    elseif (indi(i) + indj(i) - 1) < size(find(z==0),1),
    h(pijz(i)) = -1;
    else
    h(pijz(i)) = 0;
    end
end

MC(w) = median(h);
end

