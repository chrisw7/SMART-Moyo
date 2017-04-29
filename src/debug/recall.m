function []=recall(FILENAME)
%recall Load previously saved data from file (../data/) and reprocess
%   [~]=recall(dataname) returns debug output (plot, console) for given
%   filename
%   ---
%   Authour: Chris Williams | Last Updated: April 25, 2017
%   McMaster University 2017
clf;

%Load .mat from data folder
load(['../data/' FILENAME])

%Reprocess
opt.debug = true;
opt.simple = false;

process(t,a,opt);
end