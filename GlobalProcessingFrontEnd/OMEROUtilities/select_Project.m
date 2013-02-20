        function ret = select_Project(session,prompt)
            ret = [];
                        % one needs to choose Project where to store new data
                        proxy = session.getContainerService();
                        %Set the options
                        param = omero.sys.ParametersI();
                        param.noLeaves();
                        userId = session.getAdminService().getEventContext().userId; %id of the user.
                        param.exp(omero.rtypes.rlong(userId));
                        projectsList = proxy.loadContainerHierarchy('omero.model.Project', [], param);
                        % populate the list of strings "str"                                    
                        z=0;
                        str = char(256,256);
                        for j = 0:projectsList.size()-1,
                            p = projectsList.get(j);
                            pName = char(java.lang.String(p.getName().getValue()));
                                 z = z + 1;
                                 str(z,1:length(pName)) = pName;
                        end
                        str = str(1:projectsList.size(),:);
                        % request
                        [s,v] = listdlg('PromptString',prompt,...
                                        'SelectionMode','single',...
                                        'ListSize',[300 300],...                                        
                                        'ListString',str);                        
                        if(v) % here it is
                            ret = projectsList.get(s-1);
                        else
                            return;
                        end;                                            
        end