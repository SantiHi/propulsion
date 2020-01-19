%% Preprocessing
clc;

%% Fluid Velocity Calculation Parameters
pipeDiameter = [0.375, 0.5, 0.75, 1];
volumetricFlowRate = linspace(0.5, 1, 11);
numPoints = length(volumetricFlowRate) * length(pipeDiameter);
specificGravity = 1;

x = zeros(1, numPoints); y = zeros(1, numPoints); fluidVelocity = zeros(1, numPoints);

%% Fluid Velocity 3D Plot
index = 1;
for D=1:length(pipeDiameter)
    for Q=1:length(volumetricFlowRate)
        x(index) = pipeDiameter(D);
        y(index) = volumetricFlowRate(Q);
        fluidVelocity(index) = velocity(pipeDiameter(D), volumetricFlowRate(Q) .* 15.850372483753);
        index = index + 1;
    end
end
scatter3(x, y, fluidVelocity);
xlabel('Pipe Diameter (in)');
ylabel('Volumetric Flowrate (L/sec)');
zlabel('Fluid Velocity (ft/sec)');
title('Fluid Velocity as Function of D and Q');
hold on;
for i = 1:length(pipeDiameter)
    start = (i-1)*length(volumetricFlowRate) + 1;
    finish = start + length(volumetricFlowRate) - 1;
    plot3(x(start:finish), y(start:finish), fluidVelocity(start:finish));
    hold on;
end
hold off;

%% Pressure Calculation Parameters
solenoidCV = 2.8;               % Range: 2-4 1/2": 2.8, 3/4": 2.8
checkCV = 1.2;                  % Range: 1-3 1/2": 1.2, 3/4": 1.5
ballValveCV = 20;               % Range: 10-25
cavitatingVenturiPercent = 1.3; % Range: 1.15-1.30 (15-30%)
chamberPressure = linspace(1.5, 3, 16);

%% Tank Pressure -> Chamber Pressure Calculations and Display
minTankPressure = zeros(1, length(chamberPressure));
for P=1:length(chamberPressure)
    chPress = chamberPressure(P);                                           % Get chamber pressure
    endPressure = chPress .* 145.037737797;                                 % Converted chamber pressure to psi
    checkValvePressureDrop = pressDrop(specificGravity, 0.75, checkCV);     % Calculate check valve pressure drop
    preCheckValvePressure = endPressure + checkValvePressureDrop;           % Add pressure drop across check valve
    preVenturiPressure = cavitatingVenturiPercent .* preCheckValvePressure; % Calculate needed inlet venturi pressure
    ballValvePressureDrop = pressDrop(specificGravity, 0.75, ballValveCV);  % Calculate ball valve pressure drop
    preBallValvePressure = preVenturiPressure + ballValvePressureDrop;      % Add pressure drop across ball valve
    disp("Chamber Pressure: " + endPressure + " psi (" + chPress + " mpa)    |   Minimum Tank Pressure: " + preBallValvePressure + " psi (" + preBallValvePressure / 145.037737797 + "mpa)|");
    minTankPressure(P) = preBallValvePressure;
end

%% Initial Tank Pressure (Isentropic Expansion) Visualization
percentWater = linspace(0.3, 0.75, 10);
initialPressure = zeros(1, length(percentWater) .* length(chamberPressure));
x2 = zeros(1, length(percentWater) .* length(chamberPressure));
y2 = zeros(1, length(percentWater) .* length(chamberPressure));
i = 1;
for P = 1:length(chamberPressure)
    for W = 1:length(percentWater)
        x2(i) = chamberPressure(P) .* 145.037737797;
        y2(i) = percentWater(W);
        initialPressure(i) = minTankPressure(P) / ((1 - percentWater(W))^1.4);
        i = i + 1;
    end
end
scatter3(x2, y2, initialPressure);
xlabel('Chamber Pressure (psi)');
ylabel('Percent Water in Tank (%)');
zlabel('Initial Tank Pressure (psi)');
title('Inital Tank Pressure as a Function of Chamber Pressure and % Water');
hold on;
for i = 1:length(chamberPressure)
    start = (i-1)*length(percentWater) + 1;
    finish = start + length(percentWater) - 1;
    plot3(x2(start:finish), y2(start:finish), initialPressure(start:finish));
    hold on;
end
%% Functions
function fluidVelocity = velocity(pipeDiameter, volumetricFlowRate)
    fluidVelocity = (0.408 * volumetricFlowRate)/(pipeDiameter^2);
end

function pressureDrop = pressDrop(specificGravity, volumetricFlowRate, flowCoefficient)
    pressureDrop = specificGravity * (volumetricFlowRate / flowCoefficient)^2;
end