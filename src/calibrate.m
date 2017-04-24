function [OFFSET] = calibrate(port)
%calibrate Calculates appropriate z -acceration offset
%   [OFFSET] = extract(N,port) retrieves the raw IMU accel. offset in gs 
%   given a port identifier ('COM4')
%   ---
%   Authour: Chris Williams | Last Updated: April 24, 2017
%   McMaster University 2017

%Open serial communications
imu = serial(port,'BaudRate',115200);
fopen(imu);

N=100;
mvmnt = true;
count = 1;
y = zeros(N,4);
fprintf('Calibrating IMU on %s...\n', port)


while mvmnt
    %Poll sensor until no motion
    for i=1:N
        y(i,:) = eval( [ '[', fscanf(imu), ']' ] );
    end
    A = y(:,4);
    
    if range(A)<0.2
        mvmnt = false;
        OFFSET = mean(A);
    else
        if count == 1
            fprintf('Motion detected, recalibrating')
        else
            fprintf('.')
        end
    end
    
    %Timeout after 5 attempts at calibrating
    if count == 5;
        fclose(imu);
        fprintf('\n')
        error('Calibration timed out after 5 attempts. Try again on still surface')
    end
    count = count + 1;
end
%Close serial communications
fclose(imu);

fprintf('\nCalibration complete\n---\n\n')
% beep;
end
