function hann_win = hann_window(eeg, Rej_epoch, nTR, fraction, len_seg)
%HANN_INTERSECTION applies a hanning window at the intersection of
%concatonated data
%   in_data - input matrix row is channels and column are time samples
%   srate - is the sampling rate % no needed - kept to be consistent with
%           previous versions
%   fraction - is the fraction of the segment that the hanning window will be applied
%   len_seg - is the length of one segment in time points
%
% example on how to use:
% srate = 512 % sampling rate
% t = [0:1/srate:60-1/srate];
% y = sin(2*pi*0.1*t);
% len_seg = length(y)/10; % the length of each segment
% fraction = 1/10; % fraction of data to apply inverse hanning window (both sides of epoch)
% out_data = hann_intersection( y, srate, fraction, len_seg)
%
%   This example is ugly because it's a sinusoidal, with your data it might
%   be prettier :)
%
% Janir da Cruz at EPFL and IST - version 2
% 02/04/2020 - fixed bugs with the length of the inverse hanning window

% data length
L = size(eeg,2)*size(eeg,3);
% length of the hanning window
N = 2*floor(fraction * len_seg); 
% hanning window but we will use only half of it
han_window = hanning(N);
% inverse hanning window
inv_han = 1-han_window';
% window only on the last fraction of the window
inv_h_window_1 = [ones(1,len_seg-N/2),inv_han(1:N/2)];
% window applied to all sides
inv_h_window_2 = [inv_han(N/2+1:end),ones(1,len_seg-N),inv_han(1:N/2)];

% divide the length of the data by the lenght of segment length to know how
% many times to repeat the window
rep_n = L/len_seg;

all_window_tmp = repmat(inv_h_window_2,1,rep_n-2);
all_window = [inv_h_window_1,all_window_tmp,fliplr(inv_h_window_1)];

% do not set to zero if there is no discontinuity
[ ~, p ] = findpeaks(1-all_window); % identify current discontinuities (at all epochs)
keepEP = find(~ismember(1:nTR, Rej_epoch)); dEP = diff(keepEP); fEP = find(dEP == 1);

% update hanning window
hann_win = all_window; for i = fEP, hann_win(p(i)-ceil(fraction*len_seg):p(i)+ceil(fraction*len_seg)) = 1; end
end

