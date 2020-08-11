# +----------------------
# |
# | SOLDIER STAGES
# |
# | [College] Soldier Exam
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/10
# @denizen-build REL-1714
# @dependency devnodachi/college
#

Soldier_Stages_Task:
    type: task
    debug: false
    definitions: username
    script:
        - define stage 1
        - if <[username].has_flag[college_current_stage]>:
            - define stage <[username].flag[college_current_stage]>
        - else:
            - flag <[username]> college_current_stage:1
        - if <[stage]> > 1 && <location[soldier_stage_<[stage]>_spawn]||null> == null:
            - narrate " <red>ERROR: Spawn is not set for the <yellow>STAGE <[stage]><red> [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - if <[stage]> > 1 && <cuboid[soldier_stage_<[stage]>_player_zone]||null> == null:
            - narrate " <red>ERROR: Anti-teleport Zone is not set for the <yellow>STAGE <[stage]><red> [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - choose <[stage]>:
            - case 1:
                - if <server.has_flag[college_stage_1_players]>:
                    - if <server.flag[college_stage_1_players].parse[uuid].find[<[username].uuid>]> == -1:
                        - flag server college_stage_1_players:|:<[username]>
                - else:
                    - flag server college_stage_1_players:|:<[username]>
                - teleport <[username]> <location[college_stage_1_spawn]>
                - if !<[username].is_op>:
                    - inventory clear d:<[username].inventory>
                - narrate "<white> Welcome to the first stage of the university, future member of the <red>Peoples Army" targets:<[username]>
                - wait 1s
                - narrate "<white> Your written exam will start in <red>5 seconds..."
                - wait 5s
                - execute as_server "writtenexam soldier <[username].name>" silent
            - case 2:
                - run Soldier_Stage_2_Task def:<[username]>
            - case 3:
                - run Soldier_Stage_3_Task def:<[username]>
            - case 4:
                - run Soldier_Stage_4_Task def:<[username]>

Soldier_Stages_Script:
    type: world
    debug: false
    events:
        on projectile hits block in:soldier_stage_2_shooting_zone:
            - if <server.has_flag[soldier_stage_2_players]>:
                - if <context.shooter||null> != null && <server.flag[soldier_stage_2_players].parse[uuid].filter[contains_all_case_sensitive_text[<context.shooter.uuid>]].size> == 1:
                    - if <context.location.material.name.contains_all_text[<script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block]>]>:
                        - flag <context.shooter> soldier_stage_2_points_left:--
                        - define points_left_text "<green> POINTS LEFT: <yellow><player.flag[soldier_stage_2_points_left]>"
                        - sidebar set_line score:1 values:<[points_left_text]>
        on player exits soldier_stage_*_player_zone:
            - if !<player.is_op>:
                - inventory clear d:<player.inventory>
            - if <context.area.note_name.contains_all_text[soldier_stage_2_player_zone]>:
                - flag <player> soldier_stage_2_points_left:!
                - flag server soldier_stage_2_players:!
            - if <context.area.note_name.contains_all_text[soldier_stage_3_player_zone]>:
                - if <server.has_flag[soldier_stage_3_players]> && <server.flag[soldier_stage_3_players].parse[uuid].find[<player.uuid>]> != -1:
                    - adjust <player> collidable:true
                    - flag server soldier_stage_3_players:<-:<player>
                    - narrate "<red> FAILED: <white>Try again the exam. Keep trying"
                    - teleport <player> <location[soldier_college_spawn]>
            - if <context.area.note_name.contains_all_text[soldier_stage_4_player_zone]>:
                - flag server soldier_stage_4_players:!
        on player dies by:NPC:
            - if <server.has_flag[soldier_stage_4_players]>:
                - flag server soldier_stage_4_players:!
                - if !<player.is_op>:
                    - determine <list[]> passively
                - determine "<player.name> was killed by a Raider in the Soldier test"
        on player enters soldier_stage_*_parkour_zone:
            - if <server.has_flag[soldier_stage_3_players]> && <server.flag[soldier_stage_3_players].parse[uuid].find[<player.uuid>]> == 1:
                - flag server soldier_stage_3_players:<-:<player>
                - if <player.has_flag[college_current_stage]>:
                    - adjust <player> collidable:true
                    - flag <player> college_current_stage:++
                    - narrate "<red> Comrade<green>. Congratulations for passing the third stage"
                    - teleport <player> <location[soldier_college_spawn]>
                    - narrate "<white> Go to the <red>SIGN<white>, <red>RIGHT CLICK IT <white>to start the <red>LAST STAGE"

####################
## STAGE 2 - SCRIPTS
## SHOOTING ZONE
####################

Soldier_Stage_2_Task:
    type: task
    debug: false
    definitions: username
    script:
        - if <cuboid[soldier_stage_2_shooting_zone]||null> == null:
            - narrate " <red>ERROR: The stage 2 Shooting Zone is not set [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - define time_remaining <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[timer]||null>
        - define points_left <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[points]||null>
        - define target_block <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block]||null>
        - define background_block <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[background_block]||null>
        - if <[time_remaining]> == null || <[points_left]> == null || <[target_block]> == null || <[background_block]> == null:
            - narrate " <red>ERROR: The stage 2 config file has been corrupted! [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - if <server.has_flag[soldier_stage_2_players]>:
            - narrate "It seems that someone is currently doing that stage. Try again later" targets:<[username]>
            - stop
        - else:
            - flag server soldier_stage_2_players:|:<[username]>
        - teleport <[username]> <location[soldier_stage_2_spawn]>
        - if !<[username].is_op>:
            - inventory clear d:<[username].inventory>
        - give <crackshot.weapon[Desert_Eagle_CSP]> to:<[username].inventory>
        - narrate "<white> Welcome to the second stage of the university, future member of the <red>Peoples Army" targets:<[username]>
        - define space " "
        - narrate "<white> To <green>PASS <white>this stage you need to <red>SHOOT <white>the <yellow><script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block].to_titlecase.replace[_].with[<[space]>]> <white>to lower the <green>POINTS <white>in the right side" targets:<[username]>
        - narrate "<white> When you hit the block, the <green>POINTS <white>will decrease by 1." targets:<[username]>
        - narrate "<white> If you <red>FAIL<white>, you will start again in this stage when you try again the exam." targets:<[username]>
        - wait 5s
        - flag <[username]> soldier_stage_2_points_left:<[points_left]>
        - repeat <[time_remaining]>:
            - if !<[username].has_flag[soldier_stage_2_points_left]>:
                - repeat stop
            - define current_time <[value].sub[1]>
            - define time_remaining_text "<green> TIME REMAINING: <white><[time_remaining].sub[<[current_time]>]>"
            - define points_left_text "<green> POINTS: <yellow><[username].flag[soldier_stage_2_points_left]>"
            - sidebar set "title:<white>== <yellow>STAGE 2: <white>Soldier Exam" values:<[time_remaining_text]>|<[points_left_text]> players:<[username]>
            - modifyblock <cuboid[soldier_stage_2_shooting_zone]> <[background_block]>|<[target_block]> 80|20
            - if <[username].flag[soldier_stage_2_points_left]> <= 0:
                - repeat stop
            - wait 1s
        - sidebar remove players:<[username]>
        - if !<[username].is_op>:
            - inventory clear d:<[username].inventory>
        - modifyblock <cuboid[soldier_stage_2_shooting_zone]> <[background_block]>
        - flag server soldier_stage_2_players:!
        - if !<[username].has_flag[soldier_stage_2_points_left]> || <[username].flag[soldier_stage_2_points_left]> > 0:
            - flag <[username]> soldier_stage_2_points_left:!
            - teleport <[username]> <location[soldier_college_spawn]>
            - narrate "<red> FAILED: <white>Try again the exam. Keep trying" targets:<[username]>
            - stop
        - if <[username].has_flag[college_current_stage]>:
            - flag <[username]> college_current_stage:++
        - flag <[username]> soldier_stage_2_points_left:!
        - narrate "<red> Comrade<green>. Congratulations for passing the second stage" targets:<[username]>
        - teleport <[username]> <location[soldier_college_spawn]>
        - narrate "<white> Go to the <red>SIGN<white>, <red>RIGHT CLICK IT <white>to start the <red>NEXT STAGE" targets:<[username]>

####################
## STAGE 3 - SCRIPTS
## PARKOUR
####################

Soldier_Stage_3_Task:
    type: task
    debug: false
    definitions: username
    script:
        - define parkour_zone <cuboid[soldier_stage_3_parkour_zone]||null>
        - if <[parkour_zone]> == null:
            - narrate " <red>ERROR: The stage 3 Parkour Zone is not set [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - teleport <[username]> <location[soldier_stage_3_spawn]>
        - adjust <[username]> collidable:false
        - if <server.has_flag[soldier_stage_3_players]>:
            - if <server.flag[soldier_stage_3_players].parse[uuid].find[<[username].uuid>]> == -1:
                - flag server soldier_stage_3_players:|:<[username]>
        - else:
            - flag server soldier_stage_3_players:|:<[username]>
        - narrate "<white> Welcome to the third stage of the university, future member of the <red>Peoples Army" targets:<[username]>
        - narrate "<white> To <green>PASS <white>you need to complete the <yellow>PARKOUR" targets:<[username]>
        - narrate "<white> If you <red>LEAVE<white>, you will start again in this stage when you try again the exam." targets:<[username]>

####################
## STAGE 4 - SCRIPTS
## ARENA
####################

Soldier_Stage_4_Task:
    type: task
    debug: false
    definitions: username
    script:
        - define npc_amount <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[npc_amount]||null>
        - define npc_weapon <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[npc_weapon]||null>
        - define spawn_distance <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[spawn_distance]||null>
        - define player_weapon <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[player_weapon]||null>
        - define time_remaining <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[timer]||null>
        - if <[npc_amount]> == null || <[npc_weapon]> == null || <[spawn_distance]> == null || <[player_weapon]> == null || <[time_remaining]> == null:
            - narrate " <red>ERROR: The stage 4 config file has been corrupted! [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - if <server.has_flag[soldier_stage_4_players]>:
            - narrate "It seems that someone is currently doing that stage. Try again later" targets:<[username]>
            - stop
        - else:
            - flag server soldier_stage_4_players:|:<[username]>
        - if !<server.has_flag[soldier_stage_4_npcs]>:
            - repeat <[npc_amount]>:
                - create player Raider save:raider
                - wait 1T
                - equip <entry[raider].created_npc> hand:<[npc_weapon]>
                - wait 1T
                - adjust <entry[raider].created_npc> speed:<util.random.decimal[1.2].to[1.4]>
                - wait 1T
                - trait npc:<entry[raider].created_npc> state:true sentinel
                - execute as_server "sentinel addtarget player --id <entry[raider].created_npc.id>" silent
                - execute as_server "sentinel respawntime 0 --id <entry[raider].created_npc.id>" silent
                - execute as_server "sentinel safeshot true --id <entry[raider].created_npc.id>" silent
                - execute as_server "sentinel addignore npc --id <entry[raider].created_npc.id>" silent
                - flag server soldier_stage_4_npcs:|:<entry[raider].created_npc.as_npc>
            - wait 1s
        - if !<[username].is_op>:
            - inventory clear d:<[username].inventory>
        - teleport <[username]> <location[soldier_stage_4_spawn]>
        - narrate "<white> Welcome to the fourth stage of the university, future member of the <red>Peoples Army" targets:<[username]>
        - narrate "<white> To <green>PASS <white>you need to survive against the <red>RAIDERS <white>for a given time" targets:<[username]>
        - narrate "<white> If you <red>FAIL<white>, you will start again in this stage when you try again the exam." targets:<[username]>
        - wait 3s
        - give <[player_weapon]> to:<[username].inventory>
        - foreach <server.flag[soldier_stage_4_npcs]> as:npc:
            - define spawn_tries:3
            - while !<[npc].is_spawned> && <[spawn_tries]> > 0:
                - random:
                    - if <[username].location.add[<[spawn_distance]>,0,0].material.name> == AIR && <[username].location.add[<[spawn_distance]>,0,0].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<[username].location.add[<[spawn_distance]>,0,0]>
                    - if <[username].location.sub[<[spawn_distance]>,0,0].material.name> == AIR && <[username].location.sub[<[spawn_distance]>,0,0].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<[username].location.sub[<[spawn_distance]>,0,0]>
                    - if <[username].location.add[0,0,<[spawn_distance]>].material.name> == AIR && <[username].location.add[0,0,<[spawn_distance]>].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<[username].location.add[0,0,<[spawn_distance]>]>
                    - if <[username].location.sub[0,0,<[spawn_distance]>].material.name> == AIR && <[username].location.sub[0,0,<[spawn_distance]>].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<[username].location.sub[0,0,<[spawn_distance]>]>
                    - if <[username].location.add[<[spawn_distance]>,0,<[spawn_distance]>].material.name> == AIR && <[username].location.add[<[spawn_distance]>,0,<[spawn_distance]>].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<[username].location.add[<[spawn_distance]>,0,<[spawn_distance]>]>
                    - if <[username].location.sub[<[spawn_distance]>,0,<[spawn_distance]>].material.name> == AIR && <[username].location.sub[<[spawn_distance]>,0,<[spawn_distance]>].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<[username].location.sub[<[spawn_distance]>,0,<[spawn_distance]>]>
                - wait 1T
                - adjust <[NPC]> skin_blob:eyJ0aW1lc3RhbXAiOjE1ODU2MDUyODM5NjAsInByb2ZpbGVJZCI6IjkxZmUxOTY4N2M5MDQ2NTZhYTFmYzA1OTg2ZGQzZmU3IiwicHJvZmlsZU5hbWUiOiJoaGphYnJpcyIsInNpZ25hdHVyZVJlcXVpcmVkIjp0cnVlLCJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGM2NWQ4OTdlNWRkNzdiZjgxYTNjZjhkZTllMWQxMmRlYTI1NmU4MWE5ZjcxMTBhYmNhMzU2NjkyYTE3MDNhYSJ9fX0=;XJotIjWxKr+So/pSF3wOmWext7giPtdhh2IoJVOoy4lLE3w88MwM+JWUBnsDQud2EAjX2P9NFOtGb/7Mat22w0nqoMezQlR5CmN3857MWz/JeMV7N+JvZWya9HsyWv6Wermo+4wl+XK6R8cqoeHC+mIIceKLyz4pytb4biklFPoII6MLbPuQKCSWrxKQ/3oByZokHqRv7ArxOysUVlJurpOsYT7vfJUATgHn9c23f/A3Gh2O5QJ9fYZ5/6ybqJAEocOEZbnZ+vTGNqMVztwYN+7fx1cAbfLl0SYXoG2oX12aJWWw4mXt5U1nsTw7+M5ZqTjo5zBMhpztIS5ds76alD1oWu0ni6kbKmVsm7Pv1U8Fg1Bptp1fVZq2T9d/+Dx+uZy7Gp/oX4HFtn3g9NraPdPkyKPgVsn23BL9scUek2iLrRZC5OamTVtszUHfkSDfCwr9r0bipNkfBE+FidooaT6qbiOXGrztp6CIUP457qVg/3BWxVYdn9tOX3C9lt2mvpADVKuCDrvoVDfOSx811V0MECpYejaXzCDy0xy/iSASpgz0V6CAmfSIXtvTWo8xwX6VGLDSHfT3pdjUOju3sKvg0VuQtk/gEadn9quMgw4FS/hiJ4wHkzNR2cdOwWFYVzcxHsWsOO9GIHTZCkCDNsGvkCX0mrxZ3Rokw54WzO4=;http://textures.minecraft.net/texture/8c65d897e5dd77bf81a3cf8de9e1d12dea256e81a9f7110abca356692a1703aa
                - wait 1T
            - attack <[npc]> target:<[username]>
        - repeat <[time_remaining]>:
            - define current_time <[value].sub[1]>
            - define time_remaining_text "<green> TIME REMAINING: <white><[time_remaining].sub[<[current_time]>]>"
            - sidebar set "title:<white>== <yellow>STAGE 4: <white>Soldier Exam" values:<[time_remaining_text]> players:<[username]>
            - if !<server.has_flag[soldier_stage_4_players]>:
                - repeat stop
            - wait 1s
        - sidebar remove players:<[username]>
        - despawn <server.flag[soldier_stage_4_npcs]>
        - if !<server.has_flag[soldier_stage_4_players]>:
            - teleport <[username]> <location[soldier_college_spawn]>
            - narrate "<red> FAILED: <white>Try again the exam. Keep trying" targets:<[username]>
            - stop
        - flag server soldier_stage_4_players:!
        - if <[username].has_flag[college_current_stage]>:
            - flag <[username]> college_current_stage:!
        - teleport <[username]> <location[soldier_college_spawn]>
        - run Soldier_College_Reward_Task def:<[username]>

####################
## STAGE 4 - SCRIPTS
## ARENA
####################

Soldier_College_Reward_Task:
    type: task
    debug: false
    definitions: username
    script:
        - execute as_server "lp user <[username].name> parent add <[username].flag[college_current_exam]>"
        - teleport <[username]> <location[<[username].flag[college_current_exam]>_college_spawn]>
        - narrate "<green> ! -> CONGRATULATIONS! <white>You're a <yellow><[username].flag[college_current_exam].to_titlecase>" targets:<[username]>
        - narrate "<green> ! -> <white>It's time to <red>work <white>and get some <green>money" targets:<[username]>
        - flag <[username]> college_current_exam:!