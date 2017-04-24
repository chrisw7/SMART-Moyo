clf;%clc;

%Set ouptut options
opt.debug = true;
opt.simple = true;

pause(1)
[rate, depth, t, a] = train(1, 3, opt);
rate
depth