clear all;
output_data={};
%specify input and output folders 
Input_directory=cd;
output_directory=cd;
cd(Input_directory)

%open_output file and write heading line
outputfile=fopen("results.txt","w");
fprintf(outputfile,"%s\n",['"Dhin" "Dain" "Bwin" "Erosion" "deltacrest"']);
fclose(outputfile);


%Screen input_folder and read folder names, 
cd(Input_directory)
directory=dir;
sizedir=size(directory);
count=1;
for h=1:sizedir(1,1)
  if directory(h,1).isdir==1 && directory(h,1).name(1,1)~='.'
    subfolders{count}= directory(h,1).name;
    count=count+1;
  end
end

sizesubfolder=size(subfolders);

%determine storm impact for each simulation 
for j =1:sizesubfolder(1,2)
  cd(Input_directory)
  cd(subfolders{j})
  % Read dimensions
        
  fid=fopen('dims.dat','r');
  nt=fread(fid,[1],'double');
  nx=fread(fid,[1],'double');
  fclose(fid);
  
  %Read grid coordinates
  
  fixy=fopen('xy.dat','r');
  x=fread(fixy,[nx+1,1],'double');
  fclose(fixy);
  
  % Open outputs
  
  fizb=fopen('zb.dat','r');
  fizs=fopen('zs.dat','r');
  
  first=1;
  for i=1:nt;
      zb=fread(fid,[nx+1,1],'double');
      zs=fread(fizs,[nx+1,1],'double');
      if i>0&&mod(i,1)==0
          if first
              zb0 = zb;
              first=0;
          end
      end
  end
  
  %%Find initial positions of shore, crest and toe
  MSL=-0.13;
  heel=2.5;
  toe=[0,0,0];
  crest0=max(zb0);
  crestposlist=find(zb0==crest0);
  crestwidth=x(crestposlist(end))-x(crestposlist(1));
  shorelist=find(zb0> - MSL);
  delt_crest_shore=x(crestposlist(1))-x(shorelist(1));
  height_crest_shore=crest0 - MSL;
  for i=shorelist(1):crestposlist(1);
    offset=height_crest_shore/delt_crest_shore*(x(i)-x(shorelist(1)))-zb0(i);
    if offset > toe (1)
      toe(1)=offset;
      toe(2)=zb0(i);
      toe(3)=x(i);
    end
  end
  
  %%Find final positions of shore, crest and toe
  toe_final=[0,0,0];
  crest_final=max(zb);
  crestposlist_f=find(zb==crest_final);
  crestwidth_final=x(crestposlist_f(end))-x(crestposlist_f(1));
  shorelist_f=find(zb> - MSL);
  delt_crest_shore_final=x(crestposlist_f(1))-x(shorelist_f(1));
  height_crest_shore_final=crest_final - MSL;
  for i=shorelist_f(1):crestposlist_f(1);
    offset=height_crest_shore_final/delt_crest_shore_final*(x(i)-x(shorelist_f(1)))-zb(i);
    if offset > toe_final (1)
      toe_final(1)=offset;
      toe_final(2)=zb(i);
      toe_final(3)=x(i);
    end
  end  
  
  %% Calculate initial representative area 
  area_in=crestwidth*(crest0-toe(2))+1.5*((crest0-heel)^2)+((heel-toe(2))*((crest0-heel)*3))+0.5*(crest0-toe(2))*(x(crestposlist(1))-toe(3));
  
  %% Calculate final representative area (above initial dune toe) 
  area_fin=crestwidth_final*(crest_final-toe(2))+1.5*((crest_final-heel)^2)+((heel-toe(2))*((crest_final-heel)*3))+0.5*(crest_final-toe(2))*(x(crestposlist_f(1))-toe(3));
  id=['"' num2str(j) '"'];
  %% Write the feature input and changes to output file
  if crest_final < 3
    cd(Input_directory);
    outputfile=fopen("results.txt","a");
    output_data={id, crest0, area_in, toe(3)-x(shorelist(1)), 0, 0};
    fprintf(outputfile," %s %f %f %f %f %f\n",output_data'{:});
  else
	%Calculate changes in area and height
    erosion_dune=area_in-area_fin;
    deltaheight=crest0-crest_final;
    cd(Input_directory);
    outputfile=fopen("results.txt","a");
    output_data={id, crest0, area_in, toe(3)-x(shorelist(1)), erosion_dune, deltaheight};
    fprintf(outputfile," %s %f %f %f %f %f\n",output_data'{:});
   end
    fclose(outputfile);
  fclose('all');
end

