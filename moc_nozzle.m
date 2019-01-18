% Method of Characteristics for Minimum Length Supersonic Nozzle
% Created by Jason Chen, Project Caelus
% Thomas Jefferson High School for Science and Technology
% Developed on December 31st, 2018

% This program generates a minimum-length supersonic diverging nozzle 
% contour using the Method of Characteristics. Equations and methods are 
% derived from the von Karman Institute's 'Aerothermodynamics of High 
% Speed Flows, Lecture 5'. References in any comments throughout this code
% to equations or pages are based on the lecture's slideshow.

clc; close all; clear all;
%% Inputs
F = input('Desired thrust: ');
P0 = input('Chamber pressure (Pa): ');
ALT = input('Altitude (m): ');
T0 = input('Combustion chamber temperature (K): ');
M = input('Gas molecular mass (kg/mol): ');
k = input('Ratio of specific heats (cp/cv): ');
n = input('Number of characteristics (>2) emanating from throat: ');
%% Exit Pressure
if (ALT >= 25000)  % Upper Stratosphere
    T = -131.21 + 0.00299 * ALT;
    P3 = (2.488 * ((T + 273.1) / 216.6)^(-11.388))/1000;
elseif (11000 < ALT) && (ALT < 25000)  % Lower Stratosphere
    T = -56.46;
    P3 = (22.65 * exp(1.73 - 0.000157 * ALT))/1000;
else % Troposphere
    T = 15.04 - 0.00649 * ALT;
    P3 = (101.29 * ((T + 273.1) / 288.08)^(5.256))/1000;
end
%% Isentropic Flow Relations
PR = P3/P0; % Pressure ratio
TR = PR^((k-1)/k); % Temperature ratio
R = (8314.3/M); % Gas constant
CTt = (2*k*R*T0)/(k-1); % Critical throat temperature (disputed equation?)
CTp = ((2/(k+1))^(k/(k-1)))*P0; % Critical throat pressure
CTv = sqrt((2*k*R*T0)/(k+1)); % Critical throat velocity
v2 = sqrt((CTt)*(1-TR)); % Exit velocity
mdot = F/v2; % Mass flow rate
T2 = T0*TR; % Exit temperature
a2 = sqrt(k*R*T2); % Exit speed of sound
Mnum2 = v2/a2; % Exit Mach number
At = (mdot*(sqrt(k*R*T0))) / (k*P0*(sqrt(((2/(k+1)) ^ ((k+1)/(k-1)))))); % Throat area
Rt = sqrt(At / pi)*1000; % Throat radius in mm
%% Calculate Incident Expansion Waves
theta_max = rad2deg((1/2)*PMfunct(Mnum2, k)); % Maximum wall angle
theta_0 = theta_max/n; % First expansion fan is delta theta, i.e theta interval

[v,KL,KR,theta,Kangle] = solveK(theta_max,theta_0,n);
%% Plot Incident Expansion Waves
x1 = 0;
y1 = Rt;
for i=1:n
    % Equation of the KR line from nozzle throat = Kangle(i)*x + Rt
    y = [Rt 0];
    x = [0, (-Rt)/Kangle(i)];
    plot(x,y,'color','blue')
    xlabel('CENTERLINE')
    ylabel('RADIUS (MM)')
    ylim([0 Rt*2])
    hold on;
end
hold off;
%% Characteristic Parameter Solver
% v = Prandtl-Meyer angle
% KL = Left-running characteristic constant
% KR = Right-running characteristic constant
% theta = Flow angle relative to horizontal
% Kangle = Angle of characteristic relative to horizontal
function [v,KL,KR,theta,Kangle] = solveK(theta_max,theta_0,n)

dtheta = (theta_max - theta_0)/(n-1);
theta = zeros(1,n);
v = zeros(1,n);
KL = zeros(1,n);
KR = zeros(1,n);
Kangle = zeros(1,n);

for i=1:n
    theta(i)=theta_0+(i-1)*dtheta;
    v(i)=theta(i);
    KL(i)=theta(i)-v(i);
    KR(i)=theta(i)+v(i);
    Kangle(i) = tan(deg2rad(theta(i))-asin(1/invPMfunct(deg2rad(v(i)))));
end
end
%% Prandtl-Meyer Function
% Input is the local Mach number, dimensionless
% Returns the Prandtl-Meyer angle, in radians
function PMangle = PMfunct(gamma, mach)
sect1 = (gamma+1)/(gamma-1);
sect2 = (mach^2)-1;
PMangle = sqrt(sect1)*atan(sqrt(sect1*sect2)) - atan(sqrt(sect2));
end
%% Inverse Prandtl-Meyer Function
% Input is the Prandtl-Meyer angle, in radians
% Returns the local Mach number, dimensionless
function mach = invPMfunct(v)
A = 1.3604;
B = 0.0962;
C = -0.5127;
D = -0.6722;
E = -0.3278;
v_0 = (pi/2)*(sqrt(6)-1);
y = (v/v_0)^(2/3);
mach = (1 + A*y + B*(y^2) + C*(y^3))/(1 + D*y + E*(y^2));
end
