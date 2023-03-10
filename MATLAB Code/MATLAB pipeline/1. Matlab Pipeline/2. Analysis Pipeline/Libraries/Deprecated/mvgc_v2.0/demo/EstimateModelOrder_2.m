
function [pf,ssmo] = EstimateModelOrder_2(data)

% define some variables
ntrials   = size(data.signals,3); % number of trials
nobs      = size(data.signals,2); % number of observations per trial
fs        = data.srate;           % sample rate (Hz) is actually since we're looking at half second epochs

% Actual VAR model generation parameters
nvars     = size(data.signals,1);      % number of variables

% SS model order estimation
ssmosel   = 'SVC';  % SS model order selection ('ACT', 'SVC', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)

% MVGC (frequency domain)
fres      = [];     % spectral MVGC frequency resolution (empty for automatic calculation)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if ~exist('seed',   'var'), seed     = 0;    end % random seed (0 for unseeded)
%if ~exist('svconly','var'), svconly  = true; end % only compute SVC for SS model order selection (faster)
if ~exist('plotm',  'var'), plotm    = 0;    end % plot mode (figure number offset, or Gnuplot terminal string)

% Remove temporal mean and normalise by temporal variance.
% Not strictly necessary, but may help numerical stability
% if data has very large or very small values.

X = demean(data.signals,true);

%% VAR model order estimation

% Calculate and plot VAR model order estimation criteria up to specified maximum model order.
ssmoact   = 100; % up to 100 orders

% VAR model order estimation
% AIC should be used in cases where a false negative is misleading while
% BIC should be used in cases where a false positive is misleading
% AIC has a high chance of over estimating order, which can be seen with
% baby groot 9-13-18 since it is so high while bic is so low. the field
% uses BIC https://www.methodology.psu.edu/resources/AIC-vs-BIC/

varmosel  = 'BIC';  % VAR model order selection ('ACT', 'AIC', 'BIC', 'HQC', 'LRT', or supplied numerical value)
varmomax  = nvars*ssmoact; % maximum model order for VAR model order selection

ptic('\n*** tsdata_to_varmo... ');
%if isnumeric(plotm), plotm = plotm+1; end
[varmoaic,varmobic,varmohqc,varmolrt] = tsdata_to_varmo(X,varmomax,'LWR',[],[],[]);
ptoc;

% Select and report VAR model order.
varmo = moselect(sprintf('VAR model order selection (max = %d)',varmomax),varmosel,'AIC',varmoaic,'BIC',varmobic,'HQC',varmohqc,'LRT',varmolrt);
assert(varmo > 0,'selected zero model order! GCs will all be zero!');
if varmo >= varmomax, fprintf(2,'*** WARNING: selected VAR maximum model order (may have been set too low)\n'); end

%% SS model order estimation

pf = 2*varmo; % Bauer recommends 2 x VAR AIC model order

ptic('\n*** tsdata_to_sssvc... ');
%if isnumeric(plotm), plotm = plotm+1; end
[ssmosvc,ssmomax] = tsdata_to_sssvc(X,pf,[],[]);
ptoc;

% Select and report SS model order.
ssmo = moselect(sprintf('SS model order selection (max = %d)',ssmomax),ssmosel,'BIC',ssmoact,'SVC',ssmosvc);

% Interface
assert(ssmo > 0,'selected zero model order! GCs will all be zero!');
if ssmo >= ssmomax, fprintf(2,'*** WARNING: selected SS maximum model order (may have been set too low)\n'); end

