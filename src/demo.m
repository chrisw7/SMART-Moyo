%Simple demonstration of functionality (analyzes recording of length L)
%---
L = 3;              % cycle length
opt.debug  = true;  % enable debug output
opt.simple = false; % enable 'binary' output

%Begin training
[rate, depth, t, a] = train(L, opt);