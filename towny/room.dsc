# +----------------------
# |
# | TOWNROOMS
# |
# | Rooms in Towny towns.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/09/22
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#
# - Notables
# [TownName]_Rooms_[RoomName]
# - Flags
# [TownName]_Rooms - Rooms of a Town.
# [TownName]_Rooms_[RoomName] - MapTag with the data [name,price,isSellable,tax] of the room
# [TownName]_Rooms_[RoomName]_Players - Information about the players in the room.
# [TownName]_Rooms_Tax - The default tax of the rooms in a town.
# [TownName]_Rooms_Limit - The limit of players per room in a town.
# - Commands
# /townrooms create [room_name] - Selected with ctool.
# /townrooms delete [room_name]
# /townrooms tax (room_name) [amount]
# /townrooms set [room_name] [username]
# /townrooms kick [room_name] [username]
# /townrooms price [room_name] [amount]
# /townrooms toggle [room_name] - If the room can be sellable. [Default: false]
# /townrooms info [room_name] - List all the players living in that room.
# /townrooms list - List all the rooms in a town.
# /townrooms list - List all the rooms in a town.
# ---
# () = optional
# [] = required
# --

Command_AdminTownRoom:
    type: command
    debug: false
    name: atownrooms
    description: Minecraft Towny Rooms [Admin] system.
    usage: /atownrooms
    tab complete:
        - choose <context.args.size>:
            - case 0:
                - determine <list[list|tax|create|delete|set|kick|info|toggle|price|limit]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[list|tax|create|delete|set|kick|info|toggle|price|limit].filter[starts_with[<context.args.first>]]>
    permission: townroom.all
    aliases:
        - atrooms
    script:
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define town <context.args.get[1]>
        - if <town[<[town]>]||null> == null:
            - narrate "<red> ERROR: <white>The name of the Town is invalid."
            - stop
        - define action <context.args.get[2]>
        - define args_used:1
        - inject TownRoom_Task_Script

Command_TownRoom:
    type: command
    debug: false
    name: townrooms
    description: Minecraft Towny Rooms system.
    usage: /townrooms
    tab complete:
        - if <player.has_town>:
            - define rooms <empty>
            - if <server.has_flag[<player.town.name>_rooms]>:
                - define rooms <server.flag[<player.town.name>_rooms].parse[after[<player.town.name>_rooms_]]>
            - choose <context.args.size>:
                - case 0:
                    - determine <list[list|tax|create|delete|set|kick|info|toggle|price|limit]>
                - case 1:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - determine <list[list|tax|create|delete|set|kick|info|toggle|price|limit].filter[starts_with[<context.args.first>]]>
                    - else:
                        - if <context.args.get[1]> == list:
                            - determine 0
                        - if <context.args.get[1]> == tax:
                            - determine <list[0].include[<[rooms]>]>
                        - if <context.args.get[1].contains_any[delete|set|kick|info|toggle|price|limit]>:
                            - determine <[rooms]>
                - case 2:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - if <context.args.get[1]> == list:
                            - determine 0
                        - if <context.args.get[1]> == tax:
                            - determine <list[0].include[<[rooms]>]>
                        - if <context.args.get[1].contains_any[delete|set|kick|info|toggle|price|limit]>:
                            - determine <[rooms]>
                    - else:
                        - determine <server.online_players.parse[name]>
    permission: townroom.town
    aliases:
        - trooms
    script:
        - if <context.args.size> < 1:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define action <context.args.get[1]>
        - define town <player.town.name||null>
        - if <[town]> == null:
            - narrate "<red> ERROR: <white>You don't belong to a Town."
            - stop
        - define args_used:0
        - inject TownRoom_Task_Script

TownRoom_Task_Script:
    type: task
    debug: false
    script:
        - if <[action]> == list:
            - if !<server.has_flag[<[town]>_Rooms]>:
                - narrate "<white> The town <yellow><[town]> <white>have <red>0 rooms"
                - stop
            - if <server.flag[<[town]>_Rooms].size> < 10:
                - run List_Task_Script def:server|<[town]>_Rooms|Room|0|false|server|<[town]>_Rooms
            - else:
                - if <context.args.size> < <[args_used].add[2]>:
                    - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                    - stop
                - define list_page <context.args.get[<[args_used].add[2]>]>
                - run List_Task_Script def:server|<[town]>_Rooms|Room|<[list_page]>|false|server|<[town]>_Rooms
            - stop
        - if <context.args.size> < <[args_used].add[2]>:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define target <context.args.get[<[args_used].add[2]>]>
        - if <[action]> == tax:
            - if <context.args.size> == <[args_used].add[2]> && <[target].is_decimal>:
                - flag server <[town]>_Rooms_Tax:<[target]>
                - narrate "<green> The new <yellow>Tax <green>for the rooms in <yellow><[town]> <green>will be <yellow>$<[target]>"
                - stop
            - if <context.args.size> == <[args_used].add[3]>:
                - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                    - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                    - stop
                - define tax <context.args.get[<[args_used].add[3]>]>
                - if !<[tax].is_decimal>:
                    - narrate "<red> ERROR: <white>The tax should be a number."
                    - stop
                - flag server <[town]>_Rooms_<[target]>:<server.flag[<[town]>_Rooms_<[target]>].as_map.with[tax].as[<[tax]>]>
                - narrate "<green> The new <yellow>Tax <green>for the room <yellow><[target]> <green>in <yellow><[town]> <green>will be <yellow>$<[tax]>"
                - stop
        - if <[action]> == limit:
            - if !<[target].is_integer>:
                - narrate "<red> ERROR: <white>The limit should be a integer number."
                - stop
            - if <[target]> < 1:
                - narrate "<red> ERROR: <white>The limit should be at least 1."
                - stop
            - flag server <[town]>_Rooms_Limit:<[target]>
            - narrate "<green> The new <yellow>Limit <green>of players per room <green>in <yellow><[town]> <green>will be <yellow><[target]>"
            - stop
        - if <[action]> == create:
            - if <context.args.size> < <[args_used].add[2]>:
                - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                - stop
            - if !<server.has_flag[<[town]>_Rooms_Tax]>:
                - flag server <[town]>_Rooms_Tax:0
                - narrate "<green> The tax of the rooms is set to <yellow>0<green>. To change it do <yellow>/townrooms tax [number]"
                - narrate "<white> The tax is configured the first time you (try to) create a room by default"
            - if !<server.has_flag[<[town]>_Rooms_Limit]>:
                - flag server <[town]>_Rooms_Limit:1
                - narrate "<green> The limit of players per room is set to <yellow>1<green>. To change it do <yellow>/townrooms limit [number]"
                - narrate "<white> The limit of players is configured the first time you (try to) create a room by default"
            - if <[target].contains_any[_|prison|jail|region|room|null]>:
                - narrate "<red> ERROR: <white>Invalid room name. To avoid conflicts with other plugins don't use that name."
                - stop
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> != null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>already exist for the town <yellow><[town]>"
                - stop
            - if !<player.has_flag[ctool_selection]>:
                - narrate "<red> ERROR: <white>You don't have any area selected for the room"
                - stop
            - if !<player.flag[ctool_selection].as_cuboid.has_town>:
                - narrate "<red> ERROR: <white>The area selected doesn't contain the town <[town]>"
                - stop
            - else:
                - if <player.flag[ctool_selection].as_cuboid.list_towns.parse[name].filter[contains_all_text[<[town]>]].size> != 1:
                    - narrate "<red> ERROR: <white>You are selecting multiple towns. Please pick an area within the town <[town]> for the room"
                    - stop
                - else:
                    - if !<player.flag[ctool_selection].as_cuboid.min.has_town> || !<player.flag[ctool_selection].as_cuboid.max.has_town>:
                        - narrate "<red> ERROR: <white>The area selected should contain only the town <[town]>"
                        - stop
            - note <player.flag[ctool_selection]> as:<[town]>_Rooms_<[target]>
            - inject cuboid_tool_status_task
            - flag <player> ctool_selection:!
            - flag server <[town]>_Rooms:|:<[town]>_Rooms_<[target]>
            - if <context.args.size> == <[args_used].add[3]>:
                - define room_template <context.args.get[3]>
                - if <cuboid[<[town]>_Rooms_<[room_template]>]||null> == null:
                    - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]> <white>to be used as a template."
                    - stop
                - flag server <[town]>_Rooms_<[target]>:<server.flag[<[town]>_Rooms_<[room_template]>]>
                - flag server <[town]>_Rooms_<[target]>:<server.flag[<[town]>_Rooms_<[target]>].as_map.with[name].as[<[target]>]>
                - narrate "<green> Room <yellow><[target]> <green>setup correctly for the town <yellow><[town]> <green>with the template of the room <yellow><[room_template]>"
            - else:
                - flag server <[town]>_Rooms_<[target]>:<map[name/<[target]>|price/0|isSellable/false|tax/0]>
                - narrate "<green> Room <yellow><[target]> <green>setup correctly for the town <yellow><[town]>"
            - stop
        - if <[action]> == price:
            - if <context.args.size> < <[args_used].add[3]>:
                - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                - stop
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                - stop
            - define price <context.args.get[<[args_used].add[3]>]>
            - if !<[price].is_decimal>:
                - narrate "<red> ERROR: <white>The price should be a number."
                - stop
            - flag server <[town]>_Rooms_<[target]>:<server.flag[<[town]>_Rooms_<[target]>].as_map.with[price].as[<[price]>]>
            - narrate "<green> The new <yellow>Price <green>for the room <yellow><[target]> <green>in <yellow><[town]> <green>will be <yellow>$<[amount]>"
            - stop
        - if <[action]> == toggle:
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                - stop
            - if <server.flag[<[town]>_Rooms_<[target]>].as_map.get[isSellable]>:
                - flag server <[town]>_Rooms_<[target]>:<server.flag[<[town]>_Rooms_<[target]>].as_map.with[isSellable].as[false]>
                - narrate "<green> The room <yellow><[target]> <green>in town <yellow><[town]> <green>changed to <red>not be sellable"
            - else:
                - flag server <[town]>_Rooms_<[target]>:<server.flag[<[town]>_Rooms_<[target]>].as_map.with[isSellable].as[true]>
                - narrate "<green> The room <yellow><[target]> <green>in town <yellow><[town]> <green>changed to <yellow>be sellable"
            - stop
        - if <[action]> == delete:
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                - stop
            - note remove as:<[town]>_Rooms_<[target]>
            - flag server <[town]>_Rooms:<-:<[town]>_Rooms_<[target]>
            - flag server <[town]>_Rooms_<[target]>:!
            - if <server.has_flag[<[town]>_Rooms_<[target]>_Players]>:
                - foreach <server.flag[<[town]>_Rooms_<[target]>_Players]> as:roommate:
                    - if <[roommate].as_player.is_online>:
                        - narrate "<green> The room <yellow><[target]> <green>has been <red>deleted <green>correctly in the town <yellow><[town]>" targets:<[roommate].as_player>
                - flag server <[town]>_Rooms_<[target]>_Players:!
            - narrate "<green> The room <yellow><[target]> <green>has been <red>deleted <green>correctly in the town <yellow><[town]>"
            - stop
        - if <[action].contains_any[set|kick]> && <context.args.size> == <[args_used].add[3]>:
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                - stop
            - define username <server.match_offline_player[<context.args.get[<[args_used].add[3]>]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username."
                - stop
            - if <[action]> == set:
                - if <server.has_flag[<[town]>_Rooms_<[target]>_Players]>:
                    - if <server.flag[<[town]>_Rooms_<[target]>_Players].contains[<[username]>]>:
                        - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>already has the player <yellow><[username].name>"
                        - stop
                    - if <server.flag[<[town]>_Rooms_<[target]>_Players].size.add[1]> > <server.flag[<[town]>_Rooms_Limit]>:
                        - narrate "<red> ERROR: <white> The limit of players per room in the town is <yellow><server.flag[<[town]>_Rooms_Limit]><white>. The room is at that limit."
                        - stop
                    - flag server <[town]>_Rooms_<[target]>_Players:|:<[username]>
                - else:
                    - flag server <[town]>_Rooms_<[target]>_Players:|:<[username]>
                - narrate "<green> The player <yellow><[username].name> <green>was added to the room <yellow><[target]> <green>in the town <yellow><[town]>"
                - if <[username].is_online>:
                    - narrate "<green> You were added to the room <yellow><[target]> <green>in the town <yellow><[town]>" targets:<[username]>
            - else:
                - if !<server.has_flag[<[town]>_Rooms_<[target]>_Players]>:
                    - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't have any players"
                    - stop
                - flag server <[town]>_Rooms_<[target]>_Players:<-:<[username]>
                - narrate "<green> The player <yellow><[username].name> <green>was <red>removed <green>from the room <yellow><[target]> <green>in the town <yellow><[town]>"
                - if <[username].is_online>:
                    - narrate "<white> You were kicked from the room <yellow><[target]> <white>in the town <yellow><[town]>" targets:<[username]>
            - stop
        - if <[action]> == info:
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                - stop
            - if <server.flag[<[town]>_Rooms_<[target]>_Players].size> < 10:
                - run List_Task_Script def:server|<[town]>_Rooms_<[target]>_Players|Roommate|0|true|Room
            - else:
                - if <context.args.size> < <[args_used].add[3]>:
                    - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                    - stop
                - define list_page <context.args.get[<[args_used].add[3]>]>
                - run List_Task_Script def:server|<[town]>_Rooms_<[target]>_Players|Roommate|<[list_page]>|true|Room
            - stop
        - narrate "<red>ERROR: <white>ERROR: Syntax error. Follow the command syntax."

TownRoom_Script:
    type: world
    debug: false
    events:
        on player breaks block in:*_Rooms_* bukkit_priority:HIGHEST ignorecancelled:true:
            - if <player.has_town>:
                - foreach <context.location.cuboids.parse[note_name].filter[starts_with[<player.town.name>_]]> as:room:
                    - if <server.has_flag[<[room]>_Players]> && <server.flag[<[room]>_Players].contains[<player>]>:
                        - determine cancelled:false
        after player places block in:*_Rooms_* bukkit_priority:HIGHEST ignorecancelled:true:
            - if <player.has_town>:
                - foreach <context.location.cuboids.parse[note_name].filter[starts_with[<player.town.name>_]]> as:room:
                    - if <server.has_flag[<[room]>_Players]> && <server.flag[<[room]>_Players].contains[<player>]>:
                        - inventory adjust slot:<player.held_item_slot> quantity:<player.inventory.slot[<player.held_item_slot>].quantity.sub[1]>
                        - modifyblock <context.location> <context.material.name>
                        - stop
        on system time hourly every:24:
            - foreach <towny.list_towns> as:town:
                - if <server.has_flag[<[town].name>_rooms]> && <server.has_flag[<[town].name>_rooms_tax]>:
                    - define tax <server.flag[<[town].name>_rooms_tax]>
                    - foreach <server.flag[<[town].name>_rooms]> as:room:
                        - if <server.has_flag[<[room]>]> && <server.has_flag[<[room]>_Players]>:
                            - foreach <server.flag[<[room]>_Players]> as:roommate:
                                - if <server.flag[<[room]>].as_map.get[Tax]> > 0:
                                    - define tax <server.flag[<[room]>].as_map.get[Tax]>
                                - if <[roommate].as_player.money> < <[tax]>:
                                    - flag server <[room]>_Players:<-:<[roommate]>
                                    - if <[roommate].is_online>:
                                        - narrate "<red> [Somalia] <white>You were kicked out of your room in <yellow><[town].name> <white>because you don't have enough money to pay the tax." targets:<[roommate].as_player>
                                - else:
                                    - money take quantity:<[tax]> players:<[roommate].as_player>
                                    - if <[roommate].is_online>:
                                        - narrate "<red> [Somalia] <white>You have paid your taxes for your room in <yellow><[town].name><white>. Glory to Somalia!" targets:<[roommate].as_player>

####################
## Room Shop
####################

Command_RoomShop:
    type: command
    debug: false
    name: roomshop
    description: Minecraft Town Room Shop.
    usage: /roomshop
    script:
        - if !<player.has_town>:
            - narrate "<red> ERROR: <white>You don't have a Town to buy a room. Please join a Town."
        - run Inventory_RoomShop_Open_Task def:1

Inventory_RoomShop:
    type: inventory
    debug: false
    inventory: chest
    title: Room Shop
    size: 27
    slots:
        - [] [] [] [] [] [] [] [] []
        - [] [] [] [] [] [] [] [] []
        - [] [] [] [] [] [] [] [] []

Inventory_RoomShop_Open_Task:
    type: task
    definitions: page
    debug: false
    script:
        - flag player RoomShop_Page:<[page]>
        - define sellable_rooms <list[]>
        - define town <player.town.name>
        - if !<server.has_flag[<[town]>_Rooms]> || !<server.has_flag[<[town]>_Rooms_Tax]>:
            - narrate "<red> ERROR: <white>The server doesn't have rooms set."
            - stop
        - define tax <server.flag[<[town]>_Rooms_Tax]>
        - define limit <server.flag[<[town]>_Rooms_Limit]>
        - foreach <server.flag[<[town]>_Rooms]> as:room:
            - if <server.flag[<[room]>].as_map.get[isSellable]>:
                - define name <server.flag[<[room]>].as_map.get[name]>
                - define price <server.flag[<[room]>].as_map.get[price]>
                - define roommates None
                - if <server.has_flag[<[room]>_Players]>:
                    - if <server.flag[<[room]>_Players].size.add[1]> > <[limit]>:
                        - foreach next
                    - define roommates "<server.flag[<[room]>_Players].parse[name].separated_by[ ]>"
                - if <server.flag[<[room]>].as_map.get[tax]> > 0:
                    - define tax <server.flag[<[room]>].as_map.get[tax]>
                - define room_item <item[paper].with[display_name=<[name]>;lore=<white>Price:<&sp><green>$<[price]>|<white>Roommates:<&sp><[roommates]>|<white>Tax:<&sp><red>$<[tax]>]>
                - define sellable_rooms <[sellable_rooms].include[<[room_item]>]>
        - if <[sellable_rooms].is_empty>:
            - narrate "<red> [<player.town.name>] <white>No rooms are sellable or all the rooms are full."
            - stop
        - define inv <inventory[Inventory_RoomShop]>
        - inventory set d:<[inv]> o:<[sellable_rooms].get[<[page].sub[1].mul[18].max[1]>].to[<[page].mul[18]>]>
        - if <[page]> > 1:
            - inventory set d:<[inv]> o:RoomShop_arrow_left slot:19
        - if <[sellable_rooms].size> > <[page].mul[18]>:
            - inventory set d:<[inv]> o:RoomShop_arrow_right slot:27
        - inventory open d:<[inv]>

RoomShop_Script:
    type: world
    debug: false
    events:
        on player clicks in Inventory_RoomShop priority:1:
            - ratelimit <player> 1s
            - determine passively cancelled
            - if <player.has_town> && <context.item.material.name> == paper:
                    - define rooms_limit <server.flag[<player.town.name>_Rooms_Limit]>
                    - define room_flag_base <player.town.name>_Rooms_<context.item.display>
                    - define room_data <server.flag[<[room_flag_base]>].as_map>
                    - define room_players <list[]>
                    - if <server.has_flag[<[room_flag_base]>_Players]>:
                        - define room_players <server.flag[<[room_flag_base]>_Players]>
                    - if <[room_players].contains[<player>]>:
                        - narrate "<red> ERROR: <white>You already live there."
                        - stop
                    - else:
                        - if <[room_players].size.add[1]> > <[rooms_limit]>:
                            - narrate "<red> ERROR: <white>The room is at the player limit. Please choose another room."
                            - stop
                        - if <player.money> >= <[room_data].get[price]>:
                            - money take quantity:<[room_data].get[price]>
                            - flag server <[room_flag_base]>_Players:|:<player>
                            - narrate "<green> You bought the permit to live in the room <yellow><[room_data].get[name]> <green>in <yellow><player.town.name>"
                            - run Inventory_RoomShop_Open_Task def:<player.flag[RoomShop_Page]>
        on player drags in Inventory_RoomShop priority:1:
            - determine cancelled
        on player clicks RoomShop_arrow_left in Inventory_RoomShop:
            - determine passively cancelled
            - run Inventory_RoomShop_Open_Task def:<player.flag[RoomShop_Page].sub[1]>
        on player clicks RoomShop_arrow_right in Inventory_RoomShop:
            - determine passively cancelled
            - run Inventory_RoomShop_Open_Task def:<player.flag[RoomShop_Page].add[1]>

RoomShop_arrow_left:
    type: item
    debug: false
    material: player_head
    display name: Previous Page
    mechanisms:
        skull_skin: 6d9cb85a-2b76-4e1f-bccc-941978fd4de0|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYTE4NWM5N2RiYjgzNTNkZTY1MjY5OGQyNGI2NDMyN2I3OTNhM2YzMmE5OGJlNjdiNzE5ZmJlZGFiMzVlIn19fQ==

RoomShop_arrow_right:
    type: item
    debug: false
    material: player_head
    display name: Next Page
    mechanisms:
        skull_skin: 3cd9b7a3-c8bc-4a05-8cb9-0b6d4673bca9|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMzFjMGVkZWRkNzExNWZjMWIyM2Q1MWNlOTY2MzU4YjI3MTk1ZGFmMjZlYmI2ZTQ1YTY2YzM0YzY5YzM0MDkxIn19fQ
