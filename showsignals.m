
%----------- Plot and Print ------------------
opengl software;
% fprintf('Script Run Time:\t\t%0.2f\ts\n\n', runTime);

fprintf('Interval Start:\t\t\t%0.2f\ts\n', t(locs(2)));
fprintf('Interval End:\t\t\t%0.2f\ts\n', t(locs(end-1)));
fprintf('Interval Duration:\t\t%0.2f\ts\n\n', t(locs(end-1))-t(locs(2)));

fprintf('Compression Rate :\t\t%0.2f\tbpm\n',       bpm);
fprintf('Compression Rate (SA):\t%0.2f\tcm\n\n', CD_SA);

fprintf('Compression Depth:\t\t%0.2f\tcm\n\n',      100*mean(CD));
% fprintf('Compression Depth (SA):\t%0.2f\tcm\n\n',  ); %TODO

if bpm < 100
    fprintf('Compressions should be at least %0.2g%% faster\n', 100-bpm);
elseif bpm > 120
    fprintf('Compressions should be at least %0.2g%% slower...\n---\n',...
            (bpm/1.2)-100);
end

figure
subplot(4,1,1:2)
p1 = plot(t, a,'k', t,10*zv,'-r',t,100*zs,'-b'); hold on
set(p1, 'LineSmoothing','on')

for i = 1:length(locs2)
   plot([t(locs2(i)) t(locs2(i))], 100*[-pks2(i) -pks2(i)+CD(i)],'-g',...
       'LineWidth',2,...
       'LineSmoothing','on')
end

vline(t(locs),':k');
hline(0,':k');
title('Windowed Compressions','FontSize', 14)
ylabel('Motion Signals'   ,'FontSize', 12)
set(gca,'fontsize',12)
legend('Acceleration (m/s/s)',...
        'Velocity (dm/s)',...
        'Displacement (cm)');...
        legend BOXOFF

subplot(4,1,3)
p2 = plot(t,100*v,'-r',t,100*zv,'--m');
set(p2, 'LineSmoothing','on');
vline(t(locs),':k');
hline(0,':k');
title('Velocity','FontSize', 13)
% xlim([t(1) t(1)+3])
% xlabel('Elapsed Time (s)','FontSize', 10)
ylabel('Velocity (cm/s)'   ,'FontSize', 12)
set(gca,'fontsize',12)
% legend('Raw Velocity', 'Zeroed Velocity')

%Plot ZCV example for ***191.csv
if strcmp(filename,'sample_data.csv')
    hold on
    plot(t([107 126]),zv([107 126]),'vk','MarkerFace', 'c',...
        'LineSmoothing','on')
    vline(t([107 126]),'-.g')
    hold on
    area(t(107:126),100*zv(107:126),'FaceColor',colors('carrot orange'));
    zcv = -trapz(t(107:126),zv(107:126));
    fprintf('ZCV calculated CD:\t\t%0.3f\tcm\n',     100*zcv)
    fprintf('Window-integrated CD:\t%0.3f\tcm\n',    100*CD(5))
    fprintf('Percent Difference:\t\t%0.2g%%\n\n',...
            100*abs(CD(5)-zcv)/CD(5))
end

subplot(4,1,4)
p3 = plot(t,100*s,'-b',t,100*zs,'--b');
set(p3, 'LineSmoothing','on');
hold on
for i = 1:length(locs2)
   plot([t(locs2(i)) t(locs2(i))], 100*[-pks2(i) -pks2(i)+CD(i)],'-g',...
       'LineWidth',2,...
       'LineSmoothing','on')
end
plot([t(locs2(5))+.01 t(locs2(5))+.01],...
    100*[-pks2(5)-zcv+CD(5) -pks2(5)+CD(5)],...
    'Color',colors('deep carrot orange'),...
    'LineWidth',2,...
    'LineSmoothing','on')
vline(t(locs),':k');
hline(0,':k');
title('Displacement','FontSize', 13)
% xlim([t(1) t(1)+3])
ylim([-6 2])
xlabel('Elapsed Time (s)','FontSize', 12)
ylabel('Displacment (cm)'   ,'FontSize', 12)
set(gca,'fontsize',12)
% legend('Raw Displacement', 'Zeroed Displacement')