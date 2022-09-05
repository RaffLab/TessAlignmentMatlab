function generateProcessingGraphs(graphName,processedData)


figure('Name',graphName)
subplot(2,3,1)
hold on
for i = 1:processedData.N
    plot(processedData.Tcell{i,1},processedData.Xcell{i})
end

subplot(2,3,2)
hold on
for i = 1:processedData.N
    plot(processedData.Tmat(:,i),processedData.Xmat(:,i))
end

subplot(2,3,3)
hold on
for i = 1:processedData.N
    plot(processedData.T/max(processedData.T),processedData.Xmat(:,i))
end

subplot(2,3,4)
hold on
for i = 1:processedData.N
    plot(processedData.T/max(processedData.T),(processedData.Xmat(:,i) ...
        - min(processedData.Xmat(:,i)))/(max(processedData.Xmat(:,i)) - min(processedData.Xmat(:,i))))
end

subplot(2,3,5)
plot(processedData.T/max(processedData.T),processedData.X)

subplot(2,3,6)
plot(processedData.T,processedData.Xmin + processedData.X*(processedData.Xmax - processedData.Xmin))


