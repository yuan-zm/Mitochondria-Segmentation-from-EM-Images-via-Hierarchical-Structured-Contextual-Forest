function printSample(sl,varargin)
% this function is to print how many pos & neg samples
% sl: sample lable
% varargin{1}: image feature number
% varargin{2}: probability image feature number
if(nargin == 2),ftN = varargin{1}; ftpN= 0; 
else ,ftN = varargin{1}; ftpN= varargin{2}; end

posSN = size(find(sl == 1),1);negSN = size(find(sl == 2),1);
fprintf(' %d pos samples and %d neg samples! \n',posSN,negSN);

fprintf('this model has %d samples, %d pic ft and %d pro ft! \n',...
    posSN+negSN,ftN,ftpN);
