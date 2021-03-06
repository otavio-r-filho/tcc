function start_mapping()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Author: Otavio Goncalvez Vicente Ribeiro Filho                        %
%   Objective: 2D Mapping With Laser Sensoring                            %
%   Salvador - Brazil, November 1 2016                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp('Initiating V-Rep connection...');
    vrep=remApi('remoteApi');
    vrep.simxFinish(-1);
    id = vrep.simxStart('127.0.0.1', 19997, true, true, 2000, 5);
    timestep = .05;
    ping = vrep.simxGetPingTime(id);
    avg_comp_time = 0;
    comp_cicles = 0;
    map = [];

    if id < 0,
        disp('Ocorreu uma falhar na tentativa de conex?o com o V-REP.');
        vrep.delete();
        return;
    end

    fprintf('Connection %d with V-Rep stablished\n', id);
    disp('Starting simulation...');
    
    tic
    res = vrep.simxStartSimulation(id, vrep.simx_opmode_oneshot);
    
    handles = initialize_environment(vrep, id);
    [startPos startOri] = get_location(vrep, id, handles.hokJoint);
    
    while true
        tic;
        
        [pos ori] = get_location(vrep, id, handles.hokJoint);
        pts = hokuyo_scan(vrep, id, handles, pos, ori);
        map = build_map(map, pts, 0.1, 0.013, deg2rad(3), 0.102, 0.013);
        
        clf reset;
        subplot(211)
        plot(pts(:,1), pts(:,2), '.r', pos(1), pos(2), 'ob');
        axis([-3.5 3.5 -7 7]);
        axis equal;
        drawnow;
        
        if(~isempty(map))
            subplot(212);
            hold on;
            dimsMap = size(map); 
            if(length(dimsMap) == 3)
                for i=1:dimsMap(3)
                    plot(map(:,1,i), map(:,2,i), 'g');
                end
            else
                plot(map(:,1), map(:,2), 'g');                
            end
            plot(pos(1), pos(2), 'ob');
            axis([-3.5 3.5 -7 7]);
            axis equal;
        end
        drawnow;
        hold off;
        
        %ping = vrep.simxGetPingTime(id);
        elapsed = toc;
        avg_comp_time = avg_comp_time + elapsed;
        comp_cicles = comp_cicles+1;
        avg_comp_time = avg_comp_time/comp_cicles;
        fprintf('Avarege computation time: %f\n', avg_comp_time);
        pause(3);
        %pause(max(timestep-elapsed, 0.01));
        %pause(abs((timestep-elapsed) + (ping/2)));
    end
end