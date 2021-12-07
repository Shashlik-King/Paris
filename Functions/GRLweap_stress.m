%Created by MMOL, COWI 12.02.2012
%Routine to extract stresses from GRLWEAP files. The complete GWO-file is
%imported which makes it possible to extend it to comprehent other data
%than just stresses. At present the model is filled to piles with 100
%segments. Piles with less less segments can be imported after small
%adjustments.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%input: Name of the GWO-file to be analysed
%       Number of pile segments
%
%
%output:
%   GRL_stress{driving depth}(segm no, mxTForce,mxCForce,...
%                   mxTStrss,    mxCStrss,    max V,     max D,      maxEt)
%
%                   output_dbl contain all information from the stress table
%                   in the GWO-file in the format shown above
%
%                   The analysed drivig depths are included as row 2 in GRL_stress for easy data exchange
%
%   GRL_stress is saved as a mat-file under the name 'filename.mat'
%   
%Change log:
% 2013-02-15    MMOL    Derivation of depth changed due to problems at
%                       depths with pile run
%               MMOL    Enabled batch run of files 
% 2013-02-15    MMOL    Clear variables between each file
%               MMOL    Derive blow counts
% 
% 2013-04-22    MMOL    Use arbitrar number of pile segments (max 100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [GRL_stress  mxstress]=GRLweap_stress(f,n_segm,p_point,pile_segm)

    searchterm1='No mxTForce' ;                                  %The word that is used to identify the stress data tables
    searchterm2='PILE PROFILE:' ;                                %The word that is used to identify the analysed depths
    searchterm3='MN' ;
    
    if n_segm<=49                          %selects number of tables in the file for each depth. Further work is needed to make completely generic
        k_max=1;
    elseif n_segm>49 && n_segm<=99
        k_max=2;
    elseif n_segm>99
        k_max=3;
    end



    m=1;            %line number in depth_str
    k=1;            %determine which of the 3 tables are being imported
    j=1;            %j line number in output
    for i=1:size(f{1},1)
       if strncmp(searchterm1,f{1,1}(i),11) 
            if k==1                                     %line number in input
                if strncmp(searchterm3,f{1,1}(i+1),2)
                MN=1000;    
                else
                MN=1;    
                end
    
                table_end1=min(50,n_segm+1);
                output_str{j}=(f{1}(i+2:i+table_end1));        
                if k_max==1
                    k=1;
                else
                    k=k+1;
                end
                j=j+1;
            elseif k==2
                table_end2=min(51,n_segm-48);
                output_str{j}=(f{1}(i+2:i+table_end2)); 
                if k_max==2
                    k=1;
                else
                    k=k+1;                                       
                end
                j=j+1;
            elseif k==3
                output_str{j}=(f{1}(i+2));         %Maximum 100 pile segments
                k=1;
                j=j+1;
            end
       end

       if strncmp(searchterm2,f{1,1}(i),11)
              depth_str(m)=(f{1}(i-3));                     %Derive the analysed depths
              m=m+1;
       end
       
    end

    for i=1:size(output_str,2)/k_max                %Assembles tables in one row
        if k_max==1
            sort_data(1:min(49,n_segm),i)=output_str{1,i}; 
        elseif k_max==2
            sort_data(1:min(49,n_segm),i)=output_str{1,i*2-1}; 
            sort_data(50:min(99,n_segm),i)=output_str{1,i*2};
        elseif k_max==3
            sort_data(1:min(49,n_segm),i)=output_str{1,i*3-2}; 
            sort_data(50:min(99,n_segm),i)=output_str{1,i*3-1};
            sort_data(100,i)=output_str{1,i*3};
        end
    end

        
    for i=1:size(sort_data,2)                       %convert string to double (text to number)
        for j=1:size(sort_data,1)
               output_dbl{i}(j,1)=textscan(sort_data{j,i},'%f'); %Rows=pile segment, Columns=driving depth
               GRL_out{i}{j,1}(1,1:8)=output_dbl{i}{j,1}(1:8,1);
        end
    end

    for i=1:size(output_dbl,2)                      %sort data in the format GRL_stress{analysed depth}(pile segment,variable in table)
        GRL_stress{i}=cell2mat(GRL_out{1,i});       %variables in table are as follows (segm no, mxTForce,mxCForce,mxTStrss,    mxCStrss,    max V,     max D,      maxEt)
    end

    for i=1:size(depth_str,2)
        depth_dbl(i)=textscan(depth_str{i},'%*s %*s %f');   %depth_dbl is the analysed driving depths (i.e. corresponds to each stress matrix)
        GRL_stress{2,i}=depth_dbl{i}(1);                    %depth_dbl is included as row 2 in GRL_stress for easy data exchange      
    end
%     test=size(depth_dbl,2)
    
    for i=1:size(p_point,1)     %Loop to derive stresses for each point of interest at all driving depths
        for j=1:n_segm
            if i>1
                A=pi/4*(p_point(i,3)^2-(p_point(i,3)-2*(p_point(i,2)))^2);
            else
                A=(pi/4*(p_point(i,3)^2-(p_point(i,3)-2*(p_point(i,2)))^2));
            end
            if p_point(i,1)<1
                for n=1:size(depth_dbl,2)
                    mxtension(n,i)=GRL_stress{1,n}(j,2)/A;    %mod from j-1
                    mxcompression(n,i)=GRL_stress{1,n}(j,3)/A;    % mod from j-1
                end
                break
           
            elseif p_point(i,1)<pile_segm(j,1)
                for n=1:size(depth_dbl,2)
                    mxtension(n,i)=GRL_stress{1,n}(j-1,2)/A;
                    mxcompression(n,i)=GRL_stress{1,n}(j-1,3)/A;
                end
                break
            elseif p_point(i,1)==pile_segm(j,1)
                for n=1:size(depth_dbl,2)
                    mxtension(n,i)=GRL_stress{1,n}(j,2)/A;
                    mxcompression(n,i)=GRL_stress{1,n}(j,3)/A;
                end
                break
            end
        end
    end
    
    mxstress={MN*mxtension MN*mxcompression};

end
