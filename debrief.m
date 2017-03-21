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
a_fft = a(locs(2):locs(5));

Ts = 1/50;
% a_fft = 4*cos(14*pi*(0:Ts:2*pi)) + ...%7Hz
%     10*cos(8*pi*(0:Ts:2*pi)) +...%4Hz
%     5*cos(pi*(0:Ts:2*pi)+0);%0.5Hz

a_fft_h = a_fft;%'.*hamming(length(a_fft));
Fs = 1/Ts;
% plot(0:Ts:2,a_fft);hold on;

%Compute 2048 pt. DFT and extract single-sided amplitude
N = 2048*2;
P_raw = fft(a_fft,N)/length(a_fft);
% P1s = fftshift(P1);
P_smooth = fft(a_fft_h,N)/length(a_fft_h);
P_one = P_smooth(1:N/2+1);
P_one(2:end-1) = 2*P_one(2:end-1);

%Plot amplitude spectrum
f = Fs*(0:N/2)/N;
f_full = Fs*(-N/2:N/2-1)/N;

plot(f,abs(P_one),'b','LineSmoothing','on');hold on;
[pks3,locs3] = findpeaks(abs(P_one),'MINPEAKHEIGHT',max(abs(P_raw))/2,'MINPEAKDISTANCE',10);
plot(f(locs3),pks3,'vr');

figure

% subplot(211)
plot(a_fft);
xlim([0 2/Ts])
hold on;
% subplot(212)
% plot(ifft(P_raw))
% xlim([0 2/Ts])

fprintf('Frequencies: %f %f %f\n',f(locs3));
fprintf('Amplitudes: %f %f %f\n\n',pks3);



% P1c = P1s
% CD_SA = 60 * f(locs3(1));
% 
% Ak = 2*real(P_smooth(locs3))/N;
Ak = 2*pks3;
Phi = atan2(imag(P_raw(locs3(1:3))),real(P_raw(locs3(1:3))));

PX = P_raw;
threshold = max(abs(P_raw))/100; %tolerance threshold
PX(abs(P_raw)<threshold) = 0; %maskout values that are below the threshold
phase=atan2(imag(PX),real(PX))*180/pi; %phase information

As = zeros(3,length((0:Ts:2*pi)));
for k = 1:3
    As(k,:) = As(k,:) + Ak(k)*cos(2*pi*f(locs3(k))*(0:Ts:2*pi)) + Ak(k)*sin(2*pi*f(locs3(k))*(0:Ts:2*pi));
end
plot(sum(As,1),'r')
xlim([0 2/Ts])
% plot(0:Ts:2,As,'r')
%runTime = toc;