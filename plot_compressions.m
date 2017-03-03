clear all;clc;close all;
%Choose file w/dialog
% filename = uigetfile({'*.csv','Compression Data'},...
%                       'Select Raw Compression Data',...
%                       'C:\Users\Christopher\Google Drive\MetaHealth Data');
% filename = 'Accelerometer_20170224-160058346.csv';
filename = 'Accelerometer_20170228-182720191.csv';
% filename = 'MetaWear1_2017-02-14T12.26.29.046_CA_4F_11_2D_38_3E_Accelerometer_100.000 Hz.csv';

%Extract Raw Data
Acc = importdata(filename);
t = Acc.data(:,1);
a = Acc.data(:,4);

Ts = (t(2)-t(1));
% [bh,ah] = butter(2,0.04,'high');
% plot(t,a,t,filter(bh,ah,a))
a = (a - mean(a))*9.80665;%better normalization?

aInit = find(a<min(a)/3,1);
% startIndex = 540;
startIndex = find(t == floor(t(aInit)),1);
aFinal = find(fliplr(a)>max(a)/3,1);
% endIndex = 1800;
endIndex = find(t == ceil(t(end - aFinal)),1);


%Trim Data
t = t(startIndex:endIndex);
a = a(startIndex:endIndex);


%Initialize integrated values
v = zeros(length(t),1);
s = v;
s2 = s;

%Compute velocity & displacement
for i = 2:length(t)
    v(i) = v(i-1)+(a(i)+a(i-1))*Ts/2;
    s(i) = s(i-1)+(v(i)+v(i-1))*Ts/2;
end
v2 = detrend(v);
for i = 2:length(t)
    s2(i) = s2(i-1)+(v2(i)+v2(i-1))*Ts/2;
end

% figure
% [pks,locs] = findpeaks(a);
% plot(t, a, t(locs), pks, 'or');

figure

subplot(3,12,1:12)
plot(t,a)
title('Raw Acceleration Signal')

subplot(3,12,13:18)
plot(t,v*100)
title('Integrated Velocity')

subplot(3,12,19:24)
plot(t,detrend(v)*100)
title('Integrated Velocity (Linear Detrend)')

subplot(3,12,25:27)
plot(t,s*1000)
title('Integrated Displacement')
% ylim([-0.01 0.01]*1000)

subplot(3,12,28:30)
plot(t,s2*1000)
title('Detrend-Integrated Displacement')
% ylim([-0.01 0.01]*1000)

subplot(3,12,31:33)
[p,std,mu] = polyfit(t,s,10);
f_y = polyval(p,t,[],mu);
dt_s = s - f_y;
plot(t,dt_s*1000)
title('Integrated Displacement (Non-Linear Detrend)')
% ylim([-0.01 0.01]*1000)

subplot(3,12,34:36)
[p,std,mu] = polyfit(t,s2,10);
f_y2 = polyval(p,t,[],mu);
dt_s2 = s2 - f_y2;
plot(t,detrend(dt_s2*1000))
title('Detrend-Integrated Displacement (Non-Linear Detrend)')
% ylim([-0.01 0.01]*1000)

% figure
% subplot(2,1,1)
% plot(t,s)
% 
% subplot(2,1,2)
% plot(t,s2)
