%% Preprocessing
clc;

%% Parameters
pressurant = "Nitrogen (N2)";
pipeDiameter = 0.5;                 % in
volumetricFlowRate = 0.75;          % L/sec
tankVolume = 12;                    % L                 (Actual Volume + Extra Pipe Space)
actualTankVolume = 11.2;            % L
specificGravity = 1;                % 
solenoidCV = 2.8;                   % Range: 2-4        1/2": 2.8, 3/4": 2.8
checkCV = 1.2;                      % Range: 1-3        1/2": 1.2, 3/4": 1.5
ballValveCV = 20;                   % Range: 10-25
cavitatingVenturiPercent = 1.3;     % Range: 1.15-1.30  (15-30%)
chamberPressure = 2;                % mPa               
burnTime = 8;                       % sec
ratioOfSpecificHeats = 1.4;         % cp/cv             Property of Pressurant (N2)

%% Calculations
fluidVelocity = 15.850372483753 * (0.408 * volumetricFlowRate)/(pipeDiameter^2);
chamberPressure = chamberPressure * 145.037737797;
checkValvePressureDrop = pressDrop(specificGravity, volumetricFlowRate, checkCV);       % Calculate check valve pressure drop
preCheckValvePressure = chamberPressure + checkValvePressureDrop;                       % Add pressure drop across check valve
preVenturiPressure = cavitatingVenturiPercent .* preCheckValvePressure;                 % Calculate needed inlet venturi pressure
ballValvePressureDrop = pressDrop(specificGravity, volumetricFlowRate, ballValveCV);    % Calculate ball valve pressure drop
preBallValvePressure = preVenturiPressure + ballValvePressureDrop;                      % Add pressure drop across ball valve
finalTankPressure = preBallValvePressure;
chamberPressure = chamberPressure / 145.037737797;
finalTankPressure = finalTankPressure / 145.037737797;

volumeNitrogen = tankVolume - (burnTime * massFlowRate);
proportionNitrogen = volumeNitrogen/tankVolume;
initialTankPressure = finalTankPressure/((proportionNitrogen)^1.4);


%% Output Display
formatSpecInputs = "INPUTS\n-----\nChamber Pressure: %.2f mPa\nBurn Time: %.2f sec\nPipe Diameter: %.2f in\nVolumetric Flow Rate %.2f L/sec\nTank Volume %.2f L (%.2f L + Extra Pipe Space)\nSolenoid Valve Flow Coefficient %.2f\nCheck Valve Flow Coefficient %.2f\nBall Valve Flow Coefficient %.2f\nCavitating Venturi Pressure Needs: %.2f\n\n";
formatSpecPressurantInputs = "PRESSURANT INPUTS\n-----------------\nName: %s\nSpecific Gravity: %.2f\nRatio of Specific Heats: %.2f\n\n";
formatSpecOutputs = "OUTPUTS\n-------\nFluid Velocity: %.2f ft/sec\nMinimum (Final) Tank Pressure: %.2f mPa\nInitial Tank Pressure: %.2f mPa\n";

fprintf(formatSpecInputs, chamberPressure, burnTime, pipeDiameter, volumetricFlowRate, tankVolume, actualTankVolume, solenoidCV, checkCV, ballValveCV, cavitatingVenturiPercent);
fprintf(formatSpecPressurantInputs, pressurant, specificGravity, ratioOfSpecificHeats);
fprintf(formatSpecOutputs, fluidVelocity, finalTankPressure, initialTankPressure);
%% Functions
function pressureDrop = pressDrop(specificGravity, volumetricFlowRate, flowCoefficient)
    pressureDrop =  specificGravity * (volumetricFlowRate / flowCoefficient)^2;
end
