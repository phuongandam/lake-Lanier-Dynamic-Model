function [Y]=runPredAbdSC14_weekly_v2(tstart,tend,str1)
    %% run prediction of the 14 group abundance over time
    %% tstart: the time to start the simulation in day, should be relative to
    %% the day 8/1/2010 (counted as day 26)
    %% tend: the end of the time period for the simulation
    %% str1: name of the output file
    %% the last day with data is 10/15/2015 as day 1927
    %% if want to predict to the future, the script will assume similar chemical condition,
    %% the script will only run for 5 years in the future
    %% which can be changed by alter the chem vector (same time frame as the abd observed
    %% The initial abundance of the SCs can be modified by modifying the x0 vector
    %% remember to put in % value (not more than 100 or less than 0)
    %% the pH converting to the value used in the table by (pH*(-0.0175)+6.9992)/-52.3704,
    %% the water temperature (degree C) should be convert by degreeC/22.0335
    %% the phosphate concentration (mg/L) should be scaled to fold change with the mean value is 0.871
    
    load('matForEstAbdOf14SCs_lakeLanier_v2.mat'); % x0, chem, Ttime, Bgsum,Parm
    chemComb=[1,2,3]; %temp, pH, sulfate 
    daynum=7;    
    modUse=1:10; %% the parameter sets use for prediction
    afac=length(modUse);
    if tstart < 0
        tstart=1;
    elseif tstart > 365*6
        tstart = 365*6;        
    end
    if tend <= tstart
        tend = tstart+365;
    end
    
    if tend > size (chem,1) %% predict to the future, comment out if supplying the chem data
         tmore=tend-365*6; 
         if tmore <= 365*6
            chem2=[chem;chem(1:tmore,:)];
            chem=chem2;
         else
            chem2=[chem;chem];
            chem=chem2; 
            tmore=365*6;
            tend=365*6+tmore; %%% only run prediction for 6 yrs to future
         end
    end
   chem=chem(tstart:tend,:);   
   x1=mod(tstart,365)+1;
   x0=Bgsum(x1,2:end)';

    binday=1:daynum:size(chem,1);
    chem=chem(binday,:);
    Y=zeros(size(chem,1),afac*14);
    filesave=str1;
    for ic=1:afac
        mod1=modUse(ic);
        R1=daynum*Parm(mod1,:);
        arow=size(R1,2)/14;
        r1=reshape(R1,arow,14);
        b=r1(1:14,:)'; %% need to be like this
        g=r1(15:end,:)';    
        chem2=chem(:,chemComb);
        Tspan=1:size(chem2,1);
        chem2=[Tspan' chem2];
        warning('off');
        [t,y]=ode23tb(@myAbdPred,Tspan,x0,[],b,g,chem2); 
        x1=find(y<0);
        y(x1)=0; %% control for the abd not negative
        Y(1:length(t),14*(ic-1)+1:14*(ic-1)+14)=y;        
    end
    figure(2);
    hold on;
    c1=[0.7,0.7,0.7];
    for ic=1:14
        h1=subplot(2,7,ic);
        hold on;
        bin1=ic:14:size(Y,2);
        temp=Y(:,bin1);
        tempstd=std(temp');
        x1=mod(tstart,365);        
        plot(binday+tstart-1,median(temp'),'r','LineWidth',2);
        plot(binday+tstart-1,median(temp')+tempstd,'Color',c1,'LineWidth',1);
        plot(binday+tstart-1,median(temp')-tempstd,'Color',c1,'LineWidth',1);
        xlim([tstart,tend]);
        xlabel(['SC-',num2str(ic)]);        
        if (ic ==1) | (ic ==8)
            ylabel(['Abd (%)']);
            %legend('Median');
        end
        set(h1,'FontSize',12);
    end
    day1=tstart:daynum:tend;
    Y=[day1' Y];
    writeout(Y,filesave);
end
function dxdt = myAbdPred( t,x,b,g,chem )
%% t:time vector in stepwise
%% x: abundance of species, in column
%% b: coefficient vector, the effect of all j spieces on i species in one row
%% chem is the coefficient vector for the condition, for each spieces in one row, each condition in one column

[crow,ccol]=size(chem);
s=[];
for ic=2:ccol
    s1=spline(chem(:,1),chem(:,ic),t);
    s=[s s1];
end

dxdt=b*x.*x + g*s'.*x;

end

function [ output_args ] = writeout(arrA, fileout )

 fid=fopen(fileout,'a');
 [m,n]= size(arrA);
 bin=1:m;
 for im=1:m
     
     for inc=1:n
        fprintf(fid,'%d\t',arrA(im,inc)); 
     end
     fprintf(fid,'\n');
 end
 fclose(fid);

end