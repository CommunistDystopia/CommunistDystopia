# +----------------------
# |
# | M A C H I N E [ M A N A G E R ]
# |
# | After you craft a machine you become the manager.
# | Use this to take full advantage of the machines.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/machines
#

Command_Manager:
    type: command
    debug: false
    name: manager
    description: Minecraft machine manager system.
    usage: /manager
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.has_flag[manager]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[trust|upgrade]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[trust|upgrade].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <context.args.get[1].contains[trust]>:
                        - determine <server.online_players.parse[name]>
                    - if <context.args.get[1].contains[upgrade]>:
                        - determine <list[Emerald_Extractor|Emerald_Washer]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1].contains[trust]>:
                        - determine <server.online_players>
                    - if <context.args.get[1].contains[upgrade]>:
                        - determine <list[Emerald_Extractor|Emerald_Washer]>
    script:
        - if !<player.is_op||<context.server>> && !<player.has_flag[manager]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate "<yellow>-<red> To toggle the trust of a player <white>/manager trust <yellow>username"
            - narrate "<yellow>-<red> To buy a machine upgrade: <white>/manager upgrade <yellow>machine_name"
            - stop
        - define action <context.args.get[1]>
        - define target <context.args.get[2]>
        - if <[action]> == trust:
            - define username <server.match_offline_player[<[target]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<player.has_flag[trusted_players]>:
                - flag player trusted_players:|:<[username].uuid>
                - narrate "<green>You successfully trusted <blue><[username].name>"
                - stop
            - if <player.flag[trusted_players].contains_all_case_sensitive_text[<[username].uuid>]>:
                - flag player trusted_players:<-:<[username].uuid>
                - narrate "<green>You successfully <red>untrusted <blue><[username].name>"
                - stop
            - flag player trusted_players:|:<[username].uuid>
            - narrate "<green>You successfully trusted <blue><[username].name>"
            - stop
        - if <[action]> == upgrade:
            - if <script[<[target]>]||null> == null || <script[<[target]>_shop]||null> == null:
                - narrate "<red> ERROR: Invalid machine name or the machine doesn't have upgrades. <white>Maybe you forgot to add an underscore instead of spaces?"
                - stop
            - inventory open d:<[target]>_shop