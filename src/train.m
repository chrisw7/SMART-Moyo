function [RATE, DEPTH, T, A] = train(N,L,OUTPUT)
%train Capture IMU data and compute rate/depth of compression
%   [RATE, DEPTH] = train(N,L) returns the RATE of compressions
%   (bpm) and DEPTH of compression (cm) for a given sampling period, L, and
%   number of repetitions, REPS
% 
%   [RATE, DEPTH] = train(N,L,OUTPUT) additional output options for
%   debugging/LabVIEW demo purposes
%   - Set OUTPUT.debug to 'true' to enable detailed output including plots
%   (signal, fft, reconstructed signal) for each interval (req. colors.m).
%   - Set the value of OUTPUT.simple to 'true' to transform the output
%   into an integer between -1 and 1 indicating whether the calculated
%   rate/depth is below the recommended range (-1), above said range (1) or
%   within said range (0).
%   ---
%   Authour: Chris Williams | Last Updated: April 18, 2017
%   McMaster University 2017

%Check for 'debug' (verbose output) & 'simple' (boolean output) params
if nargin<2
    error('Too few parameters; at least two (T,A) are required.');
elseif nargin==2
    OUTPUT.debug  = false;
    OUTPUT.simple = false;
else 
    if ~isfield(OUTPUT, 'debug')
        OUTPUT.debug = false;
    end
    if ~isfield(OUTPUT, 'simple')
        OUTPUT.simple = false;
    end
end

%# of samples
if L > 10
    L = 10;
elseif L<2
    L = 2;
end

Nsamples = round(L)*100;%for 100 Hz!

[T, A] = deal(zeros(Nsamples,N));

pause(1);
for i = 1:N
    %Capture serial data
    [T(:,i),A(:,i)] =  extract(Nsamples, 'COM4');
    
    %Compute CD/CPM
    [RATE, DEPTH] = process(T(:,i),A(:,i),OUTPUT);
end
beep
end