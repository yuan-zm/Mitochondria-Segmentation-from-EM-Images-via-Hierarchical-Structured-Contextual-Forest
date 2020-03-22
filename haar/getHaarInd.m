function [haar] = getHaarInd(ps)
%rand('seed',1)
fN = {'h3d.mat','h5d.mat'};%,'h5.mat'
for tt =1:size(fN,2)    
    options.rect_param = importdata(fN{tt});
    options.F = haar_featlist(ps,ps,ps,options.rect_param);
    % teacher' haar 1
    haar.center{tt} = ceil(size(options.F,2)/2); 
    haar.LbpInd{tt} =  randperm(size(options.F,2),10);
    % teacher' haar 2  random points - center
    haar.randPoints{tt} = randperm(size(options.F,2),ceil(size(options.F,2)*0.6)); 
    % teacher' haar 2  random points - random points
    haar.ind1{tt} = randperm(size(options.F,2),ceil(size(options.F,2)*0.8));
    haar.ind2{tt} = randperm(size(options.F,2),ceil(size(options.F,2)*0.8));
    %haar.ind3 = randperm(size(options.F,2),ceil(size(options.F,2)*0.5));   
end
