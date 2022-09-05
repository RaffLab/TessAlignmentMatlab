classdef normalisedEmbryoData < handle
    properties
        T
        X
        Xstd
        Xsem
        Xmax
        XinitMax
        Xmin
        XinitMin
        N
        Xmat
        Tmat
        Xcell
        Tcell
        successfulInit
        eventTimingsCell %cell that is key, raw, normalised, redimentionalised
        nOfEVTs
    end
    methods
        %constructor
        function obj = normalisedEmbryoData(lb, ub,iterations,averageType,frameLength,basePath)
            %check that all the arguments have been intialised otherwise
            %we're doing nothing 
            if (nargin == 6) && (validateEmbryoDataInput(obj, lb, ub, iterations))
                %obj.eventTimingsCell = {}; %just initalise this 
                obj.N = length(iterations);
                % precondition X and T cells
                obj.Xcell = cell(obj.N, 1);
                obj.Tcell = cell(obj.N, 3); %time vector, lb, ub
                
                for i = 1:obj.N
                
                    % compute the average centriole reponse for each of the  embryos
                    [X,T,obj.XinitMin,obj.XinitMax] = averageCentrioleData(strcat(basePath,num2str(iterations(i)),".csv"),averageType,0,frameLength);
                
                    % collate the reponses into the appropriate cells
                    obj.Xcell{i} = obj.XinitMin + X*(obj.XinitMax - obj.XinitMin);
                    obj.Tcell{i,1} = T;
                    obj.Tcell{i,2} = lb(i);
                    obj.Tcell{i,3} = ub(i);
                end
                %compute responses averaged over the embryos, note: lets use 500
                %interpolation points just based on the length of a full cycle assuming
                %10sec frames plus a bit extra space
                [obj.X, T, obj.Xmin, obj.Xmax, obj.Xstd, obj.Xsem, obj.Xmat, obj.Tmat] = averageEmbryoData(obj.Xcell,lb,ub,obj.Tcell, 500);
                
                % to realign times to base 0 
                obj.T = T - T(1);
                obj.successfulInit = true;

            else
                obj.successfulInit = false;
            end
        end
        
        %function to validate embryo input, checks lengths and pairing
        function isTrue = validateEmbryoDataInput(obj, lowerBounds, upperBounds, iterationArray)
            isTrue = true;
            try
                for i = 1:length(iterationArray) %gross 1-indexing, lets hope its end inclusive lol
                    if upperBounds(i) < lowerBounds(i)
                        isTrue = false;
                        disp(strcat("Error: upperBound below lowerBound @ pos ", num2str(i)))
                        break %no point checking the rest
                    end
                end
            catch
                %so if we run over a limit then we've got a problem, ie
                %they're not aligned
                disp("Error: mismatch between bounds and iterations")
                disp(strcat("lb count: ", num2str(length(lowerBounds))))
                disp(strcat("ub count: ", num2str(length(upperBounds))))
                disp(strcat("iterations count: ", num2str(length(iterationArray))))
                isTrue = false;
            end
        end

        %function to validate that the object has eventTimings
        function isTrue = validateEventTimingsExist(obj)
            if size(validateEmbryoDataInput) ~= 0
                isTrue = true;
            else
                isTrue = false;
            end
        end

        %function to add event Timings to the data
        %this keeps a cell of absolute and normalised times which is
        %transposed in relation to the T/Xcells 
        %we also transpose the data (to column vectors from row vectors) to make it easier to use later...
        %cell that is key, raw, normalised, redimentionalised
        function appendEventTimes(obj, additionalTimings)


            %check validation
            if obj.validateEventTimings(additionalTimings) == false
                exit
            end

            %first lets work out how much stuff we've got to add
            additionalTimingsSize = size(additionalTimings);
            obj.nOfEVTs = additionalTimingsSize;

            %preallocate additonal timing arrays
            for i = 1:additionalTimingsSize(1)
                additionalTimings{i,3} = zeros(obj.N,1);
                additionalTimings{i,4} = zeros(obj.N,1);
            end


            %loop through the embryos 
            for i = 1:obj.N
                %grab inital bounds for the embyro
                orignalLb = obj.Tcell{i,2};
                orignalUb = obj.Tcell{i,3};
                originalCycleLength = orignalUb - orignalLb;
                %redimentionalisedLb = min(obj.Tmat(:,i));
                redimentionalisedLb = min(obj.T);
                redimentionalisedUb = max(obj.T);
                %redimentionalisedUb = max(obj.Tmat(:,i));
                redimentionalisedCycleLength = redimentionalisedUb-redimentionalisedLb;
                
                %handle the normalisation/redimentionalising according to
                %existing tracks
                for j = 1:additionalTimingsSize(1)
                    %disp(strcat("i: ", num2str(i)))
                    %disp(strcat("j: ",num2str(j)))
                    %normalise to proportion of cycle length
                    %disp(additionalTimings{j,2}(i))
                    additionalTimings{j,3}(i) = (additionalTimings{j,2}(i)-orignalLb)/originalCycleLength;
                    %disp(additionalTimings{j,3}(i))
                    %redimentionalise to T
                    additionalTimings{j,4}(i) = (additionalTimings{j,3}(i)*redimentionalisedCycleLength)+redimentionalisedLb;
                    %disp(additionalTimings{j,4}(i))
                end
            end
            %disp(mean(additionalTimings{1,4}))
            %append onto the existing raw timings
            %currently appends, rather replaces? Tess wtf -Tess
            %I guess this is more accurately "set"
            obj.eventTimingsCell = additionalTimings;
        end

        %function to validate event timings; essentially we're gonna check
        %2 things: 
        % 1 - are they within ub/lb
        % 2 - are there more/less than the number of embryos 

        function isValid = validateEventTimings(obj, EVTCell)
            %for speed lets first check we have the right number of entries
            %in each
            nOfEVTs = size(EVTCell,1); % number of timing positions ie. NEB, Meta/ana etc
            isValid = true; % will turn false if we find something sus.
            for i = 1:nOfEVTs %loop through checking each have the correct number of embryos
                currTimepoints = length(EVTCell{i,2});
                if currTimepoints ~= obj.N % if we have the wrong number of embryos
                    disp(strcat("Error: EventTimings timepoint number mismatch in ",EVTCell{i,1}))
                    disp(strcat("Expected timepoints: ",num2str(obj.N)))
                    disp(strcat("Provided timepoints: ",num2str(obj.N)))
                    isValid = false;
                end
            end 

            %so that's the number sorted out; lets now provide a warning if
            %they are out of range.
            for i = 1:nOfEVTs
                for j = 1:obj.N
                      %loop through all of the points checking they're
                      %within the bounds
                      currTimeVal = EVTCell{i,2}(j);
                      if or(currTimeVal > obj.Tcell{j,3},currTimeVal< obj.Tcell{j,2})
                          disp("Warning: EventTimings timepoint outside of lower/upperbounds")
                          disp(strcat("Anomalous timepoint: "),EVTCell{i,1}," embryo:",num2str(j))
                      end

                end
            end

            

                

            
        end

        %function to get a cell made up of the listed cell keys
        function EVTSubcell = getEVTSubcell(obj, eventsToAnnotate)
            indxs = [];
            for i = 1:length(eventsToAnnotate)
                currIndxs = find(strcmp([obj.eventTimingsCell{:,1}],eventsToAnnotate(i)));
                if isempty(currIndxs)
                    %then we've not found anything
                    disp(strcat("Error: Event missing from data object - ", eventsToAnnotate(i)));
                else
                    indxs = [indxs currIndxs]; 
                    %can't easily preallocate as may be 1 to many, 
                    %and will be faster to do cleanup at the end probs
                end
            end

            %so now we have an array of indexes we're interested in
            %lets quickly clean it incase someone refered to the same one
            %twice <- cos I'm nice like that <3
            indxs = unique(indxs);
            nOfIndexs = length(indxs);

            %so now we just need to construct the new cell
            EVTSubcell = cell(nOfIndexs,4); %preallocate
            for i = 1:nOfIndexs
                %loop through the indexes we want to construct the new cell
                EVTSubcell{i,1} = obj.eventTimingsCell{indxs(i),1};
                EVTSubcell{i,2} = obj.eventTimingsCell{indxs(i),2};
                EVTSubcell{i,3} = obj.eventTimingsCell{indxs(i),3};
                EVTSubcell{i,4} = obj.eventTimingsCell{indxs(i),4};
            end
        end
        
    end
end

function [X,T,Xmin,Xmax,Xstd,Xsem,Xmat,Tmat] = averageEmbryoData(Xcell,lb,ub,Tcell,numpts)

% averageEmbryoData computes the average response curve across multple
% embryos by normalising the data with respect to both amplitude and time
% between specified lower and upper bounds for each embryo.
%
% Inputs: Xcell - a cell of length N (number of embryos) where each element
%                 of the cell array is a vector containing the response
%                 curve of centrioles in a single embryo
%            lb - a vector of length N where each element is the initial
%                 starting point of the data to consider for the
%                 corresponding embryo (Default zeros)
%            ub - a vector of length N where each element is the final
%                 point of the data to consider for the corresponding
%                 embryo (Default maximum)
%         Tcell - a cell of length N where each element of the cell array 
%                 is a vector of the timepoints measured for the 
%                 corresponding embryo (Default 30s intervals starting from
%                 zero)
%        numpts - the number of interpolation points (Default 100)
%
% Outputs: X - the normalised, average response
%          T - the averaged time vector
%       Xmin - the average of the minimum values of the response curves
%       Xmax - the average of the maximum values of the response curves
%       Xstd - a vector of the (normalised) standard deviations
%       Xmat - a (numpts x N) matrix of the interpolated and bounded
%              responses of each individual embryo
%       Tmat - a (numpts x N) matrix of the bounded time vectors for each
%              embryo
%
% To plot the dimensional mean, use                (Xmin + X*(Xmax - Xmin))
% To plot the dimensional std, use         Xmin + (X +- Xstd)*(Xmax - Xmin)


N = length(Xcell); % Number of embryos to average over

if nargin < 5
    
    numpts = 100; % Default value if numpts not specified
    
    if nargin < 4
        
        Tcell = cell(N,1); % If Tcell not specified then create a default cell
        
        for i = 1:N
            
            Tcell{i} = 0:30:30*(length(Xcell{i}) - 1);
            
        end
        
        if nargin < 3
            
            ub = cellfun(@length,Xcell); % Default upper bound is the maximum value
            
            if nargin < 2
                
                lb = zeros(N,1); % Defulat lower bound is zero
                
            end
            
        end
        
    end
    
end

Tmat = zeros(numpts,N); % Precondition empty matrix for interpolated T values
Xmat = zeros(numpts,N); % Precondition empty matrix for interpolated X values

for i = 1:N
    
    IndxMin = find(Tcell{i,1}>=lb(i),1,'first'); % Find lower bound index
    IndxMax = find(Tcell{i,1}<=ub(i),1,'last'); % Find upper bound index
    
    tmpT = Tcell{i,1}(IndxMin:IndxMax); % Vector of T values in range
    tmpX = Xcell{i}(IndxMin:IndxMax); % Vector of X values in range
    
    % Interpolate vectors to return numpts values and append to the
    % preconditioned matrices
    Tmat(:,i) = interp1(linspace(1,numpts,length(tmpT)),tmpT,1:numpts);
    Xmat(:,i) = interp1(linspace(1,numpts,length(tmpX)),tmpX,1:numpts);
    
end

T = linspace(mean(lb),mean(ub),numpts); % Average time vector [this is the 
                                        % same as sum(Tmat,2)/N]

X    = mean(Xmat,2); % Compute mean vector

Xmin = min(X); % Compute minimum of the averaged vector
Xmax = max(X); % Compute maximum of the averaged vector

X    = (X - Xmin)/(Xmax - Xmin); % Normalise the mean vector

Xstd = std((Xmat - min(Xmat))./(max(Xmat)-min(Xmat)),0,2);
Xsem = Xstd./sqrt(sum(~isnan(Xmat),2));

end

function [X,T,Xmin,Xmax] = averageCentrioleData(filepath,averagetype,t0,tdiff)

% averageCentrioleData computes the average response curve of centrioles
% within a single embryo
%
% Inputs: filepath - the filepath of the data. It is assumed that the first
%                    column is simply the frame number in increasing
%                    integer values. If this is not the case, adjust line
%                    24 of the code accordingly
%         t0       - the initial time (Default 0)
%         tdiff    - time between frame (Default 30)
%
% Outputs: X    - vector of the averaged response. This vector is
%                 normalised to 0 and 1
%          T    - vector of timepoints
%          Xmin - minimum value of the averaged response before normalising
%          Xmax - maximum value of the averaged response before normalising
%
% To recover the non-normalised response, use (Xmin + X*(Xmax - Xmin)).


if nargin<4
    
    tdiff = 30;
    
    if nargin < 3
        
        t0 = 0;
        
    end
    
end

M = readmatrix(filepath); % Load data into matrix
M = M(:,2:end);           % Remove the 'frame' column from the matrix
I = sum(1 - isnan(M),2);  % Total the number of non-zero entries each frame



switch averagetype
    case 'mean'
        M(isnan(M)) = 0;    % Set NaN entries to zero
        V = sum(M,2)./I;    % Compute average amplitude each frame, weighted by the 
                            % number of visible centrioles
    case 'median'
        V = median(M,2,"omitnan"); % Calculate the median amplitude

    case 'meanPercentile95'
        V = percentileMean(M,5,I); %Calculate the mean ignoring the top and bottom 5 percentiles
end


T    = t0 - tdiff + tdiff*(1:length(V)); % Create time vector
Xmax = max(V); % Maximum amplitude
Xmin = min(V); % Minimum amplitude
X    = (V - Xmin)/(Xmax-Xmin); % Normalised vector
end

%function to calculate the mean excluding a set percentile
%eg. percentile=5 -> mean(p0.05-p0.95)
function meanVector = percentileMean(dataMatrix,percentile,nonNanElements)
    

    meanVector = zeros(length(nonNanElements));
    for i=1:length(meanVector)
        %extract curr data
        currFrameData = dataMatrix(i,:);
        %Calculate limits
        upperLimit = prctile(currFrameData,100-percentile);
        lowerLimit = prctile(currFrameData,percentile);

        currFrameData(isnan(currFrameData)) = 0; %set Nan entries to 0, we do now to avoid fucking up the percentiles

        %eliminate edge percentile dudes
        currNOfData = nonNanElements(i);
        for j=1:length(currFrameData)
            if currFrameData(j) > upperLimit | currFrameData < lowerLimit
                currFrameData(j) = 0;
                currNOfData = currNOfData-1;
            end
        end

        meanVector(i) = sum(currFrameData)/currNOfData;
    end
end

