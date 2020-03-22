function [sampleInd,eachInd]=  getTrainData(opts,labIm,varargin)

if(nargin <= 2),errorIds = []; negRatio = opts.negRatio;
else ,errorIds = varargin{1};  negRatio = opts.negRatio2; end
if(nargin == 4),traInd = varargin{2};else , traInd = [];  end
% posSpNum = ceil(opts.posNum/size(traInd,2));
% negSpNum = ceil(opts.negNum/size(traInd,2));

[m, n, numPic] = size(labIm);
shrink = opts.stride;pdSz = opts.padSize;
importRange = opts.boundary;
B=false(m,n);
B(shrink:shrink:end,shrink:shrink:end)=1;
B([1:pdSz end-pdSz:end],:)=0;
B(:,[1:pdSz end-pdSz:end])=0;
eachInd = cell(numPic,1);
sampleInd = [];ePNum = 0;eNNum = 0;
for i = 1:numPic %numPic
    tpLabIm = labIm(:,:,i);
    if(ismember(i,traInd))
        M =tpLabIm;
       % M(bwdist(M)<importRange)=1;

        posInd =  find(M.*B);
        if(~isempty(errorIds))
            eind = errorIds{i}; epind = find(tpLabIm(eind) == 1);
            ePNum = size(epind,1);
        end
       % posn = min(size(posInd,1),posSpNum-ePNum);
        posInd1 = posInd(randperm(size(posInd,1),round(size(posInd,1)*0.9)));
        negInd1 = find(~M.*B);
        
        numNegNum = min(round((size(posInd,1)+ePNum) * negRatio),size(negInd1,1));
        if(~isempty(errorIds))
            eind = errorIds{i}; enind = find(tpLabIm(eind) == 0);
            eNNum = size(enind,1);
        end
       % numNegNum = negSpNum - eNNum;
        negInd = randperm(size(negInd1,1),min(size(negInd1,1),numNegNum));
        allInd = [posInd1;negInd1(negInd)];
        if(~isempty(errorIds))
           % allInd2 = ;
            allInd = unique([allInd;errorIds{i}]);
        end
        eachInd{i} = allInd; 
    else
        if(~isempty(errorIds)),eachInd{i} = errorIds{i};end
    end
    
%     ftInd = allInd + m * n * (i-1) * ones(size(allInd));
%     sampleInd = [sampleInd;ftInd]; %#ok<AGROW>
    %labTr = cat(1,labTr,tpLabIm(allInd));
end
