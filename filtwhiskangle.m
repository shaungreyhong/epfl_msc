function [Filt_Signal]= filtwhiskangle(Signal, SR, Freq1, Freq2)

% Band-cut filter

% INPUTS:
% Signal= Signal to be filtered
% SR = Signal sampling rate (pt/s)
% Freq1 = low-pass filter (Hz)
% Freq2= high-pass filter (Hz)

Signal=Signal-median(Signal); % subtract the mean of the signal 

[Zs,Ps,K]=ellip(4,.1,20,[Freq1 Freq2]*2/SR);
[SOS,G]=zp2sos(Zs,Ps,K);
Filt_Signal=filtfilt(SOS,G,Signal);

end