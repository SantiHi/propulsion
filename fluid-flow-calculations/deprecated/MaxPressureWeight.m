%% Max Pressurant Weight Calculation
% Calculates maximum pressurant weight requirement given parameters
% Ankit Khandelwal, 05 October, 2019

vCF = 0.035315;
iGLC = 8.314;
mfr = input("Mass Flow Rate(kg/sec): "); %0.4567
mm = input("Molar Mass of Propellant (grams/mole): "); %60.0948
gC = input("Gas Constant of Pressurant (ft*lb/lb*�R): "); %55.165
mP = input("Max Pressure (pa): "); %5000000
Z = input("Compressibility Factor = Z: "); %1
mTR = input("Mean Temperature (�R): "); %536.67
pW = getPressureWeight(mfr, mm, gC, mP, Z, mTR, iGLC, vCF);
disp("Pressurant Weight: " + poundToKilogram(pW));

function pressureWeight = getPressureWeight(massFlowRate, molarMass, gasConstant, maxPressure, ZConstant, meanTempRankine, idealGasLawConstant, volumeConversionFactor)
    propellantExpelled = massFlowRate * 10;
    molesPropellant = (propellantExpelled*1000)/molarMass;
    volPropellant = (molesPropellant*idealGasLawConstant*rankineToKelvin(meanTempRankine)*volumeConversionFactor)/(maxPressure/1000);
    
    pressureForEqn = maxPressure/47.880259;
    
    pressureWeight = (pressureForEqn*volPropellant*ZConstant)/(gasConstant*meanTempRankine);
end

function kelvinTemp = rankineToKelvin(rankineTemp)
    kelvinTemp = rankineTemp * (5/9);
end

function lbToKg = poundToKilogram(lb)
    lbToKg = lb /  2.2046;
end
    