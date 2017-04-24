function [T,A] = extract(N, port)
%extract Polls sensor connected to COM4 for time/acceleration data
%   [T,A] = extract(N) extracts time in seconds (T) and z-acc. (m/s/s)
%   ---
%   Authour: Chris Williams | Last Updated: April 10, 2017
%   McMaster University 2017

%Open serial communications
imu = serial(port,'BaudRate',115200);
fopen(imu);
 
% L = length(eval( [ '[', fscanf(imu), ']' ] ));
% if length(L)  > 4
%     fprintf(imu,'m');
%     fprintf(imu,'g');
% end

%Poll sensor
y = zeros(N,4);
fprintf('Polling IMU on %s...\n', port)
for i=1:N
        y(i,:) = eval( [ '[', fscanf(imu), ']' ] );
end

%Scale data
T = y(:,1);
T = (T-T(1))/1000;

A = y(:,4);
A = (A - mean(A))*9.80665;

%Close serial communications
fclose(instrfind);

fprintf('Data capture complete\n')
% beep;
end
