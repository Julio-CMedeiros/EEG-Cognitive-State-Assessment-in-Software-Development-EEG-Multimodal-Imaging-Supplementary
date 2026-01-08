function [ out_data ] = hann_intersection( in_data, srate, fraction, len_seg)
%HANN_INTERSECTION applies a hanning window at the intersection of
%concatonated data
%   in_data - input matrix row is channels and column are time samples
%   srate - is the sampling rate
%   fraction - is the fraction of the segment that the hanning window will be applied
%   len_seg - is the length of one segment in time points

% data length
L = size(in_data,2);
% hanning window but we will use only half
han_window = hanning(srate*2, 'symmetric');
N = length(han_window);
% inverse hanning window
inv_han = 1-han_window';
% window only on the last fraction of the window
inv_h_window_1 = [ones(1,len_seg*(1-fraction)),inv_han(1:N/2)];
% window applied to all sides
inv_h_window_2 = [inv_han(N/2+1:end),ones(1,len_seg*(1-2*fraction)),inv_han(1:N/2)];

% divide the length of the data by the lenght of segment length to know how
% many times to repeat the window
rep_n = L/len_seg;

all_window_tmp = repmat(inv_h_window_2,1,rep_n-2);
all_window = [inv_h_window_1,all_window_tmp,fliplr(inv_h_window_1)];

out_data = all_window.*in_data;
end

