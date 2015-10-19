function [ new_labels ] = prepare_ground_labels( labels )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
new_labels=cell(0);
%对同类的标签进行归纳
for i=1:length(labels)
    cur_label=labels{i,1};
    cur_label=lower(cur_label);
    for j=1:length(cur_label)
        label_str=cur_label{j};
        if(length(strfind(label_str,'mr'))~=0)
          label_str='verse';
        elseif(length(strfind(label_str,'verse'))~=0)
          label_str='verse';
        elseif(length(strfind(label_str,'ver_se'))~=0)
          label_str='verse';
        
        %instrument
        elseif(length(strfind(label_str,'verses'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'verseas'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'versehs'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'versebs'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'solo'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'long_connector'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'short_connector'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'instrumental'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'refrains'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'guitars'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'break'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'bridgebs'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'bridges'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'bridgeas'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'closing'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'close'))~=0)
          label_str='instrument';
        elseif(length(strfind(label_str,'interlude'))~=0)
          label_str='instrument';
        
        %refrain
        elseif(length(strfind(label_str,'refrain'))~=0)
          label_str='refrain';
        
        %bridge
        elseif(length(strfind(label_str,'bridge'))~=0)
          label_str='bridge';
        
        %intro
        elseif(length(strfind(label_str,'intro'))~=0)
          label_str='intro';
        
        %outro
        elseif(length(strfind(label_str,'outro'))~=0)
          label_str='outro';
        
        %silence
        elseif(length(strfind(label_str,'si'))~=0)
          label_str='silence';
        
        %impro
        elseif(length(strfind(label_str,'impro'))~=0)
          label_str='verse';
        end
              
        cur_label{j}=label_str;
    end
    new_labels{i,1}=cur_label;
end

for i=1:length(new_labels)
    cur_new_label=[];
    cur_label=new_labels{i,1};
    for j=1:length(cur_label)
        label_str=cur_label{j};
        if(length(strfind(label_str,'silence'))~=0)
          label=1;
        elseif(length(strfind(label_str,'intro'))~=0)
          label=2;
        elseif(length(strfind(label_str,'ver_se'))~=0)
          label=3;
        elseif(length(strfind(label_str,'bridge'))~=0)
          label=4;
        elseif(length(strfind(label_str,'instrument'))~=0)
          label=5;
        elseif(length(strfind(label_str,'refrain'))~=0)
          label=6;
        elseif(length(strfind(label_str,'outro'))~=0)
          label=7;
        end
        cur_new_label(end+1)=label;
    end
    new_labels{i,1}=cur_new_label;
end
end

