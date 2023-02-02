function [detrended_signal] = polyDetrend(Sample)

%This function detrends continuously sampled data by fitting a low order
%polynomial to, and then subtracting it from, the original signal.

%Inputs - Sample (continuously sampled data in samples x trials format)

%%

for i = 1:size(Sample,2);
    [p,s,mu] = polyfit((1:numel(Sample(:,i)))',Sample(:,i),6);
    f_y(:,i) = polyval(p,(1:numel(Sample(:,i)))',[],mu);
    
    detrended_signal(:,i) = Sample(:,i) - f_y(:,i);
end


end

