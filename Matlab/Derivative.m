function [ EcgD ] = Derivative( Ecg, fs )
% This function calculates the derivative of a signal

% Make sure u is a horizontal vector
u = Ecg(:)';

dx = 1/fs;
EcgD = [2*(u(2)-u(1)) u(3:end)-u(1:end-2) 2*(u(end)-u(end-1))]/dx/2;

end

