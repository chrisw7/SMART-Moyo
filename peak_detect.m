clear all;clc;%close all;
%Choose file w/dialog

% filename = uigetfile({'*.csv','Compression Data'},...
%                       'Select Raw Compression Data',...
%                       'C:\Users\Christopher\Google Drive\MetaHealth Data');

% filename = 'Accelerometer_20170224-160058346.csv';
% filename = 'Accelerometer_20170307-155158277.csv';
% filename = 'Accelerometer_20170307-155121747.csv';

%Ideal example data
filename = 'Accelerometer_20170228-182720191.csv';

%Extract Raw Data
Acc = importdata(filename);
t = Acc.data(:,1);
a = Acc.data(:,4);

Ts = (t(2)-t(1));
% [bh,ah] = butter(2,0.04,'high');
% plot(t,a,t,filter(bh,ah,a))

%Rough normalization of acceleration signal for initial peak detection
a2 = (a - mean(a))*9.80665;%

aInit = find(a2<min(a2)/2,1);
startIndex = find(t == floor(t(aInit)),1);
aFinal = find(fliplr(a2)>max(a2)/3,1);
endIndex = find(t == ceil(t(end - aFinal)),1);

%Normalize using no-motion mean, 
a = (a - mean(a(1:startIndex)))*9.80665;

%Trim Data
t = t(startIndex:endIndex);
a = a(startIndex:endIndex);

% Detect compression indicator peaks 
[pks,locs] = findpeaks(a,'MINPEAKHEIGHT',-.5);
locs = locs(pks<1.25);
pks = pks(pks<1.25);

%Remove pre-peaks
for i = 2:length(locs)
    if locs(i)-locs(i-1) < 15
        locs(i-1) = 0;
        pks(i-1)  = 0;
    end
end

pks = pks(locs~=0);
locs = locs(locs~=0);

%Initialize integrated values
v = zeros(length(t),1);
s = v;
s2 = v;
zv = v;
zs = v;

%Manual zeroing of acceleration signal
a(1:locs(1)-20)=0;

%Compute raw velocity & displacement
for i = locs(1):length(v)
    v(i) = v(i-1)+(a(i)+a(i-1))*Ts/2;
    s(i) = s(i-1)+(v(i)+v(i-1))*Ts/2;
end

% Detrend and zero velocity
v2 = detrend(v);
v2 = v2 - v2(1);

%Compute displacement from detrended velocity signal
for i = locs(1):length(v)
    s2(i) = s2(i-1)+(v2(i)+v2(i-1))*Ts/2;
end

%Detrend displacement
s2 = detrend(s2);

%Zero-reset algorthim (not perfectly synced)
for i = locs(1):length(v)
    if any(locs == i)
        zv(i) = 0;
        zs(i) = 0;
    else
        zv(i) = zv(i-1)+(a(i)+a(i-1))*Ts/2;
        zs(i) = zs(i-1)+(zv(i)+zv(i-1))*Ts/2;
    end
end

%Compute compression rate/depth

---% TODO: Implement lean approximation (quantitative measure of zero-reset) 
bpm = length(locs(2:end-1))/(t(locs(end-1))-t(locs(2)))*60;

c_d = zeros(length(locs)-1,1);
for i = 2:length(locs)
    intv = zs(locs(i-1):locs(i));
    c_d(i-1) = max(intv)-min(intv);
end

%Find displacement pekas (minimums)
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

%----------- Plot and Print ------------------

% fprintf('Interval Start:\t\t\t%0.2f\ts\n', t(locs(2)));
% fprintf('Interval End:\t\t\t%0.2f\ts\n', t(locs(end-1)));
% fprintf('Interval Duration:\t\t%0.2f\ts\n\n', t(locs(end-1))-t(locs(2)));
% 
% fprintf('Compression Rate (CR) :\t%0.2f\tbpm\n',      bpm);
% fprintf('Compression Depth (CD):\t%0.2f\tcm\n\n',     100*mean(c_d));
% 
% if bpm < 100
%     fprintf('Compressions should be at least %0.2g%% faster\n', 100-bpm);
% elseif bpm > 120
%     fprintf('Compressions should be at least %0.2g%% slower\n---\n', (bpm/1.2)-100);
% end
% 
% subplot(4,1,1:2)
% plot(t, a,'k', t,10*zv,'-r',t,100*zs,'-b')%, t(locs), pks, 'vr');
% hold on
% for i = 1:length(locs2)
%    plot([t(locs2(i)) t(locs2(i))], 100*[-pks2(i) -pks2(i)+c_d(i)],'-g','LineWidth',2)
% end
% 
% vline(t(locs),':k');
% hline(0,':k');
% title('Windowed Compressions','FontSize', 14)
% % xlim([t(1) t(1)+3])
% % xlabel('Elapsed Time (s)','FontSize', 12)
% ylabel('Motion Signals'   ,'FontSize', 12)
% set(gca,'fontsize',12)
% legend('Acceleration (m/s/s)', 'Velocity (dm/s)', 'Displacement (cm)')
% 
% subplot(4,1,3)
% plot(t,100*v,'-r',t,100*zv,'-b')
% vline(t(locs),':k');
% hline(0,':k');
% title('Velocity','FontSize', 13)
% % xlim([t(1) t(1)+3])
% % xlabel('Elapsed Time (s)','FontSize', 10)
% ylabel('Velocity (cm/s)'   ,'FontSize', 12)
% set(gca,'fontsize',12)
% legend('Raw Velocity', 'Zeroed Velocity')
% 
% %Plot ZCV example for ***191.csv
% if strcmp(filename,'Accelerometer_20170228-182720191.csv')
%     hold on
%     plot(t([107 126]),zv([107 126]),'vk','MarkerFace', 'g')
%     vline(t([107 126]),'-.g')
%     hold on
%     area(t(107:126),100*zv(107:126),'FaceColor','g');
%     zcv = -trapz(t(107:126),zv(107:126));
%     fprintf('ZCV calculated CD:\t\t%0.3f\tcm\n',     100*zcv)
%     fprintf('Window-integrated CD:\t%0.3f\tcm\n',    100*c_d(5))
%     fprintf('Percent Difference:\t\t%0.2g%%\n\n',     100*abs(c_d(5)-zcv)/c_d(5))
% end
% 
% subplot(4,1,4)
% plot(t,100*s,'-r',t,100*zs,'-b')
% hold on
% for i = 1:length(locs2)
%    plot([t(locs2(i)) t(locs2(i))], 100*[-pks2(i) -pks2(i)+c_d(i)],'-g','LineWidth',2)
% end
% vline(t(locs),':k');
% hline(0,':k');
% title('Displacement','FontSize', 13)
% % xlim([t(1) t(1)+3])
% ylim([-10 2])
% xlabel('Elapsed Time (s)','FontSize', 12)
% ylabel('Displacment (cm)'   ,'FontSize', 12)
% set(gca,'fontsize',12)
% legend('Raw Displacement', 'Zeroed Displacement')
