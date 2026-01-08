function [RelAmp] = relAmplitude(inSignal,inSrate,FreqIn, FreqFin, BoundIn, BoundFin)
%relAmplitude calculates the relative frequency amplitude given
%   inSignal - input signal as a signal to be FFT transformed (vector)
%   inSrate - the input signal sampling rate
%   FreqIn - the initial frequency of interest (in Hz), e.g. for delta = 1
%   FreqFin - the last frequency of interest (in Hz), e.g. for delta = 4
%   BoundIn - initial frequency of the range interest, e.g. from 1 to 70,
%               in this case BoundIn = 1
%   BoundFin - final frequency of the range of interest, e.g. from 1 to 70,
%               in this case BoundFin = 70
%   RelAmp - output relative amplitue, unitless
%
%   Janir Ramos da Cruz @IST and @EPFL, 08/11/2017

% Calculate the FFT
L = length(inSignal);                           % length of the signal of interest
NFFT = 2^nextpow2(length(inSignal));            % number of points for FFT computation
f = inSrate/2*linspace(0,1,NFFT/2+1);           % the frequencies axis
Y_tmp = fft(inSignal,NFFT)/L;                   % fft transformation (double-sided)
Y = 2*abs(Y_tmp(1:NFFT/2+1));                   % one sided FFT

% Find the position of the frequencies in the f vector
[~,f_in] = min(abs((f-FreqIn)));                % for the initial freq of interest
[~,f_fin] = min(abs((f-FreqFin)));              % for the end freq of interest
[~,f_boundIn] = min(abs((f-BoundIn)));          % for the initial freq of interest
[~,f_boundFin] = min(abs((f-BoundFin)));        % for the initial freq of interest

% Calculates the relative amplitude
RelAmp = ((sum(Y(f_in:f_fin)))/(FreqFin-FreqIn))...
            /((sum(Y(f_boundIn:f_boundFin)))/(BoundFin-BoundIn));

end

