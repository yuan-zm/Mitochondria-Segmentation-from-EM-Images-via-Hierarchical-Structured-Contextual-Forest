function ft = standFt(patch)
superData = reshape(patch,[],size(patch,4))';

centerInd = ceil(size(superData,2)/2);
centerIntensity = superData(:,centerInd);
meanData = mean(superData,2);
stdData = std(superData,0,2);
%sumData = sum(superData,2);
medianData = median(superData,2);
Kurtosis = kurtosis(superData,[],2);
Skewness = skewness(superData,[],2);
ft = [centerIntensity,meanData ,stdData,Kurtosis,Skewness,medianData ];
end