# +----------------------
# |
# | W O R K E R
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/15
# @denizen-build REL-1714
#

Worker_Script:
    type: world
    debug: false
    events:
        on system time minutely:
            - foreach <server.online_players> as:server_player:
                - if <[server_player].in_group[worker]>:
                    - flag <[server_player]> worker_timer:+:1
                    - if <[server_player].flag[worker_timer]> >= 20:
                        - flag <[server_player]> worker_timer:0
                        - money give quantity:10 players:<[server_player]>
                        - narrate "<white> You got paid <green>[10$] <white>for working <yellow>20 minutes" targets:<[server_player]>
        on player quits:
            - if <player.has_flag[worker_timer]>:
                - flag <player> worker_timer:!