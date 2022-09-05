classdef normalisedSoraData < handle
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
        %lb = lowerbound
        %ub = upperbound
        %itt = numbers to itterate through the files to load
        %averageType = method used to generate the "average" track
        %frameLength = time between frames can be scalar or vector per itt
        %basepath = base file path
        function obj = normalisedSoraData(lb, ub,itt, frameLength, basePath)
            if nargin==5 && validateSoraDataInput(obj, lb, ub, itt, frameLength)
                %check everything is initalised
                obj.N = length(itt);
                %organise data parameters
                obj.Xcell = cell(obj.N,1);
                obj.Tcell = cell(obj.N,3); %time vec, lb, ub
                
                if length(frameLength) ~= 1
                    individualFL = true;
                else
                    individualFL = false;
                end

                for i = 1:obj.N
                    if individualFL %vary depending on if the frameLength data is individual or assigned across all
                        [currDataVector, currTimeVector] = importSoraData(obj, strcat(basePath,num2str(itt(i)),".csv"),frameLength(i));
                    else
                        [currDataVector, currTimeVector] = importSoraData(obj, strcat(basePath,num2str(itt(i)),".csv"),frameLength);
                    end

                    %put data into cells
                    obj.Xcell{i} = currDataVector;
                    obj.Tcell{i,1} = currTimeVector;
                    obj.Tcell{i,2} = lb(i);
                    obj.Tcell{i,3} = ub(i);
                end
                
                %so now we've got all the data tracks imported and
                %formatted into the cells so the data is nice to use :3
                %now to smush them together!!

                [obj.X, T, obj.Xmin, obj.Xmax, obj.Xstd, obj.Xsem, obj.Xmat, obj.Tmat] = averageSoraData(obj, obj.Xcell, lb, ub, obj.Tcell, 500);

                %realign time to 0
                obj.T = T-T(1);
                obj.successfulInit = true;
            
            else
                obj.successfulInit = false;
            end
        end

        %function to interpolate the data and average it so it all lines up
        %pretty much entirely yoinked from Zach's stuff, my god its clean
        %<3
        function [X,T,Xmin,Xmax,Xstd,Xsem,Xmat,Tmat] = averageSoraData(obj, Xcell, lb, ub, Tcell, numpts)
            N = length(Xcell); %number of embryos we be averaging


            %preconditioning for interpolated values
            Tmat = zeros(numpts,N);
            Xmat = zeros(numpts,N); 

            for i = 1:N

                IndxMin = find(Tcell{i,1}>=lb(i),1,'first'); %find the lower bound index
                IndxMax = find(Tcell{i,1}<=ub(i),1,'last'); %find the upper bound index

                tmpT = Tcell{i,1}(IndxMin:IndxMax); %grab the time values in range
                tmpX = Xcell{i}(IndxMin:IndxMax); %grab the data values in range

                %interpolate to give fit the number of points we wanted 
                Tmat(:,i) = interp1(linspace(1,numpts,length(tmpT)),tmpT,1:numpts);
                Xmat(:,i) = interp1(linspace(1,numpts,length(tmpX)),tmpX,1:numpts);
            end

            T = linspace(mean(lb),mean(ub),numpts); %average time vector 
            X = mean(Xmat,2); %mean data vector
            
            Xmin = min(X); %min of mean vector
            Xmax = max(X); %max of mean vector

            Xstd = std((Xmat - min(Xmat))./(max(Xmat)-min(Xmat)),0,2);
            Xsem = Xstd./sqrt(sum(~isnan(Xmat),2));

        end


        %function to import data and convert it to standardised seconds
        function [inputData, timeVector] = importSoraData(obj, importPath, frameLength)
            inputData = readmatrix(importPath);
            inputData = inputData(:,4); % grab the 4th column ie, the ratio

            timeVector = frameLength*(1:length(inputData))-frameLength'; %setup the vector of time points, subtracting frame length cos frame 0
        end
        
        %function to validate data input, look to see if things are the
        %wrong length
        function isTrue = validateSoraDataInput(obj, lb, ub, itt, frameLength)
            isTrue = true;
            %test lb/ub time points
            try
                for i = 1:length(itt) %loop checking no lb higher than ubs
                    if ub(i) < lb(i)
                        isTrue = false;
                        disp(strcat("Error: upperBound below lowerBound @ pos ", num2str(i)))
                        break
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
                return
            end

            %optionally test itt
            frameLengthLength = length(frameLength);
            if  (frameLengthLength ~= 1) && (frameLengthLength ~= length(itt)) %if we've got an array of framelengths cos they vary within the dataset
                disp("Error: Individual frame lengths specified, however mismatch between itt and frameLengths")
                isTrue = false;
                return
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
            %append onto the existing raw timings: note I don't think this
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