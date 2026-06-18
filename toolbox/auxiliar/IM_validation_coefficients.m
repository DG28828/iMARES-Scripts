function stats = IM_validation_coefficients(refData, modData, options)
%IM_validation_coefficients Computes validation statistics between reference and model data.
%
%   stats = IM_validation_coefficients(refData, modData) computes common
%   validation coefficients between reference observations and modeled or
%   estimated data. Missing and non-finite values are removed pairwise.
%
%   stats = IM_validation_coefficients(refData, modData, options) allows
%   additional options to be specified.
%
%   INPUTS
%   ------
%   refData : numeric array
%       Reference or observed data.
%
%   modData : numeric array
%       Modeled, estimated or predicted data. Must have the same number of
%       elements as refData.
%
%   OPTIONS
%   -------
%   options.NumPredictors : positive integer
%       Number of predictors or estimated parameters used for adjusted R².
%       Default is 1.
%
%   OUTPUT
%   ------
%   stats : struct
%       Structure containing the following fields:
%
%       stats.NOBS
%           Number of valid paired observations.
%
%       stats.R2
%           Coefficient of determination based on residual sum of squares:
%           R2 = 1 - SSE/SST.
%
%       stats.R2A
%           Adjusted R² using options.NumPredictors.
%
%       stats.RMSE
%           Root mean square error.
%
%       stats.BIAS
%           Mean bias, defined as mean(modData - refData).
%
%       stats.CORR
%           Pearson correlation coefficient.
%
%       stats.CORR2
%           Squared Pearson correlation coefficient.
%
%       stats.SI
%           Scatter Index, defined as RMSE / mean(refData).
%
%       stats.SI_centered
%           Centered Scatter Index using demeaned modeled and reference data.
%
%       stats.NRMSE
%           Normalized RMSE using the root mean square of refData.
%
%       stats.DIF2
%           Sum of squared differences.
%
%       stats.SUMREF
%           Sum of reference data.
%
%       stats.DR
%           Refined Willmott index of agreement.
%
%       stats.validMask
%           Logical mask indicating valid paired data in the original arrays.
%
%   EXAMPLE
%   -------
%   ref = rand(100,1);
%   mod = ref + 0.1*randn(100,1);
%   stats = validation_coefficients(ref, mod);
%
%   See also CORRCOEF, MEAN, VAR.

%% Input argument handling
arguments
    refData {mustBeNumeric}
    modData {mustBeNumeric}
    options.NumPredictors (1,1) double {mustBeInteger, mustBeNonnegative} = 1
end

%% Initial checks

% Ensure compatible number of elements
if numel(refData) ~= numel(modData)
    error('refData and modData must have the same number of elements.');
end

% Convert to column vectors
ref = refData(:);
mod = modData(:);

% Pairwise valid data
validMask = isfinite(ref) & isfinite(mod);
ref = ref(validMask);
mod = mod(validMask);

%% Initialization of variables

% Number of observations
n = numel(ref);
p = options.NumPredictors;

% Initialize output structure
stats = struct();

stats.NOBS = n;
stats.R2 = NaN;
stats.R2A = NaN;
stats.RMSE = NaN;
stats.BIAS = NaN;
stats.CORR = NaN;
stats.CORR2 = NaN;
stats.SI = NaN;
stats.SI_centered = NaN;
stats.NRMSE = NaN;
stats.DIF2 = NaN;
stats.SUMREF = NaN;
stats.DR = NaN;
stats.validMask = reshape(validMask, size(refData));

% Return NaNs if there are no valid observations
if n == 0
    warning('No valid paired observations were found.');
    return
end

%% Statistics

% Differences
err = mod - ref;

% Basic statistics
stats.DIF2 = sum(err.^2);
stats.SUMREF = sum(ref);
stats.RMSE = sqrt(mean(err.^2));
stats.BIAS = mean(err);

% R2 based on residual sum of squares
SSE = sum((ref - mod).^2);
SST = sum((ref - mean(ref)).^2);

if SST > 0
    stats.R2 = 1 - SSE/SST;
else
    stats.R2 = NaN;
end

% Adjusted R2
% Only defined when n > p + 1
if n > p + 1 && isfinite(stats.R2)
    stats.R2A = 1 - (1 - stats.R2)*(n - 1)/(n - p - 1);
else
    stats.R2A = NaN;
end

% Correlation coefficient
if n >= 2 && std(ref) > 0 && std(mod) > 0
    C = corrcoef(ref, mod);
    stats.CORR = C(1,2);
    stats.CORR2 = stats.CORR^2;
else
    stats.CORR = NaN;
    stats.CORR2 = NaN;
end

% Scatter Index
meanRef = mean(ref);

if meanRef ~= 0
    stats.SI = stats.RMSE / meanRef;
else
    stats.SI = NaN;
end

% Centered Scatter Index
denSI = sum(ref.^2);
if denSI > 0
    stats.SI_centered = sqrt(sum(((mod - mean(mod)) - (ref - mean(ref))).^2) / denSI );
else
    stats.SI_centered = NaN;
end

% Normalized RMSE using RMS of reference data
rmsRef = sqrt(mean(ref.^2));
if rmsRef > 0
    stats.NRMSE = stats.RMSE / rmsRef;
else
    stats.NRMSE = NaN;
end

% Refined Willmott Index of Agreement
obsMean = mean(ref);
term1 = sum(abs(mod - ref));
term2 = 2 * sum(abs(ref - obsMean));

if term2 == 0 && term1 == 0
    stats.DR = 1;
elseif term2 == 0
    stats.DR = NaN;
elseif term1 <= term2
    stats.DR = 1 - term1/term2;
else
    stats.DR = term2/term1 - 1;
end

end