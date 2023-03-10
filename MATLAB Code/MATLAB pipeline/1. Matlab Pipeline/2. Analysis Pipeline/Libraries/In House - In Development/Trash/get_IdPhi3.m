%% IdPhi
%

function [IdPhi] = get_IdPhi3(x_pos,y_pos,ts_pos,smooth_data)

% try smoothing - moving seems to be smoothest
if smooth_data == 1
    x_pos = smooth(x_pos,'moving');
    y_pos = smooth(y_pos,'moving');
end

% get the derivative of x, y, and t
dx = gradient(x_pos);
dy = gradient(y_pos);
dt = gradient(ts_pos');

% get arctangent of the derivatives (Phi)
phi = atan2(dy./dt,dx./dt);

% unwrap orientation to prevent circular transitions
phi_unwrap = unwrap(phi);

% derivative of phi
dPhi = gradient(phi_unwrap);

% divide by dt
dPhiXdt = dPhi./dt;

% absolute value
absPhi = abs(dPhiXdt);

% multiply time
Phi_final = absPhi.*dt;

% Chad Guisti said sum is rectangular estimate of the integral, 
% while trapz is trapezoidal. Both are effective, trapz may be more 
% accurate, but in the presence of noise, it is hard to say which is 
% truley the best.
IdPhi = trapz(Phi_final); 
%IdPhi = sum(Phi_final);

% to control for any effects of IdPhi being influenced by different sized
% datasets, we can normalize by the number of observations?

end


