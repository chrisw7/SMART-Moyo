clear all;clc;close all;%tic;

% Choose file w/dialog

% filename = uigetfile({'*.csv','Compression Data'},...
%                       'Select Raw Compression Data',...
%                       'C:\Users\Christopher\Google Drive\MetaHealth Data');

% filename = 'Data/Accelerometer_20170224-160058346.csv';
% filename = 'Data/Accelerometer_20170307-155158277.csv';
% filename = 'Data/Accelerometer_20170307-155121747.csv';

filename = 'sample_data.csv';
[t, Fs, a, v, s, zv, zs, locs] = extract(filename);

%--------------------- CR/CD from integration

%--- TODO: Implement lean approximation (quantitative measure of zero-reset) 
bpm = length(locs(2:end-1))/(t(locs(end-1))-t(locs(2)))*60;

CD = zeros(length(locs)-1,1);
for i = 2:length(locs)
    intv = zs(locs(i-1):locs(i));
    CD(i-1) = max(intv)-min(intv);
end


%----------------------------  ZCV

%Find displacement peaks (minimums)
[pks2, locs2] = findpeaks(-zs,'MINPEAKHEIGHT',0.01);

%Zero-crossing algorithm (not robust)
z_locs = [];
k = 0;
for i = 1:length(zv)-1
    if ((zv(i) > 0 && zv(i+1) < 0) || (zv(i) < 0 && zv(i+1) > 0)) && k > 7
        if (abs(zv(i)-0)<abs(zv(i+1)-0))
            z_locs = [z_locs i];
            k=0;
        else
            z_locs = [z_locs i+1];
            k=0;
        end
    else
        k = k +1;
    end
end

%-----------------------  Spectral Analysis
figure

%Define interval and apply window
% a_fft = a(locs(2):locs(5));

Ts = .01;
a_fft = 4*cos(14*pi*(0:Ts:2)) + 5*cos(6*pi*(0:Ts:2)) + 5*cos(pi*(0:Ts:2)+pi/3);
a_fft = a_fft'.*hamming(length(a_fft));
Fs = 1/Ts;
% plot(0:Ts:2,a_fft);hold on;

%Compute 2048 pt. DFT and extract single-sided amplitude
N = 2048;
P1 = fft(a_fft,N)/length(a_fft);
P1 = P1(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);

%Plot amplitude spectrum
f = Fs*(0:N/2)/N;
plot(f,abs(P1),'b','LineSmoothing','on');hold on

[pks3,locs3] = findpeaks(abs(P1),'MINPEAKHEIGHT',max(abs(P1))/5,'MINPEAKDISTANCE',10);
plot(f(locs3),pks3,'vr');

% CD_SA = 60 * f(locs3(1));
% 
Ak = abs(P1(locs3(1:3)));
Phi = atan2(imag(P1(locs3(1:3))),real(P1(locs3(1:3))));


As = 0;
for k = 1:3
    As = As + Ak(k)*cos(2*pi*k*f(locs3(k))*(0:Ts:2)+Phi(k));
end
% plot(0:Ts:2,As,'r')
%runTime = toc;