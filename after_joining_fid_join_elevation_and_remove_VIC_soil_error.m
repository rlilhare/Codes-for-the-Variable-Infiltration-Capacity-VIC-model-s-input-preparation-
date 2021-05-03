% clc;
% clear all;
% soil=xlsread('Soil_nelson_0.10_final.xlsx');
% fid=importdata('lon_lat_fid.txt');
% out2=[];
% new1=[];
% 
% for i=1:size(soil,1)
%     disp(i)
%     b=find(soil(i,2)==fid(:,2) & soil(i,3)==fid(:,1));
%     out(i,1)=1;
%     out(i,2)=fid(b,3);
%     out(i,3)=soil(i,2);
%     out(i,4)=soil(i,3);
%     out(i,5:53)=soil(i,4:52);
% end
% dlmwrite(['Z:\Phd_Work\VIC_input_pre_10Km\Soil\soil_forcing_data_entire_Nelson.txt'],out,' ');
% 
% LNRB_FID=importdata('soil_forcing_data_LNRB_buff_org_for_ref_of_run_grid_dont_change_this_file_itisbuffer.txt'); %only for LNRB FID 
% 
% for j=1:size(LNRB_FID,1)
%     disp(j)
%     c=find(LNRB_FID(j,3)==soil(:,2) & LNRB_FID(j,4)==soil(:,3));
%     anna(j,1)=numel(c); %to store the missing grids in new LNRB file
%     if numel(c)==0;
%         out1(j,1)=1;
%         out1(j,2)=LNRB_FID(j,2); %joining fid here
%         out1(j,3)=LNRB_FID(j,3);
%         out1(j,4)=LNRB_FID(j,4);
%         out1(j,5:21)=LNRB_FID(j,5:21);
%         out1(j,22)=LNRB_FID(j,22);  %for elevation colomn, because we can't resample elevation, this elevation is from SRTM DEM
%         out1(j,23:53)=LNRB_FID(j,23:53);
%     else
%         
%         out1(j,1)=1;
%         out1(j,2)=LNRB_FID(j,2); %joining fid here
%         out1(j,3)=soil(c,2);
%         out1(j,4)=soil(c,3);
%         out1(j,5:21)=soil(c,4:20);
%         out1(j,22)=LNRB_FID(j,22);  %for elevation colomn, because we can't resample elevation, this elevation is from SRTM DEM
%         out1(j,23:53)=soil(c,22:52);
%     end
% end

clc;
clear all;

out1=csvread('soil_NRB_0.05_final_table.csv');

%to remove the error comes during run of the VIC model related to soil file
%In the soil parameter file, Wpwp_FRACT MUST be >= resid_moist / (1.0 - bulk_density/soil_density).

for k=1:size(out1,1)
    new(k,1)=out1(k,50)/(1-out1(k,34)/out1(k,37));
    new1(k,1)=out1(k,44)-new(k,1);
    new1(k,2)=out1(k,45)-new(k,1);
    new1(k,3)=out1(k,46)-new(k,1);
    if new1(k,1)>=0 & new1(k,2)>=0 & new1(k,3)>=0
        out2(k,:)=out1(k,:);
    else
        out2(k,1:43)=out1(k,1:43);
        out2(k,44)=new(k,1)+0.00001;%out1(k,44)-new1(k,1); %for making value positive since VIC takes 6 decimal places
        out2(k,45)=new(k,1)+0.00001;%out1(k,45)-new1(k,2);
        out2(k,46)=new(k,1)+0.00001;%out1(k,46)-new1(k,3);
        out2(k,47:end)=out1(k,47:end);
    end
end
    
dlmwrite(['soil_NRB_5km_final.txt'],out2,'delimiter','\t');%,'precision','%.6f'); %this is the final data, don't need to do anything





