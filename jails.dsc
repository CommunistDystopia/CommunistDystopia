# /jail Usage
# /jail create <jailname> x1 y1 z1 x2 y2 z2 - Adds a jail (works like WorldEdit coordinates)
# /jail delete <jailname> - Removes a jail

Command_Jail:
    type: command
    name: jail
    description: Minecraft Jail system.
    usage: /jail
    script:
        - if !<player.is_op||<context.server>> || <player.groups.find[supremewarden]> == -1:
            - narrate "<red>You do not have permission for that command."
            - stop
        - define action <context.args.get[1]>
        - define name <context.args.get[2]>
        - define jail_name "jail_<[name]>"
        - if <[jail_name].ends_with[_spawn]>:
            - narrate "<red> ERROR: Invalid jail name. Please don't use _spawn in your jail name."
            - stop
        - if <[action]> == create:
            - if <context.args.size> < 8:
                - narrate "<red> ERROR: Not enough arguments."
                - narrate  "<red> To create a jail: /jail create <yellow>jailname x1 y1 z1 x2 y2 z2"
                - stop
            - define x1 <context.args.get[3]>
            - define y1 <context.args.get[4]>
            - define z1 <context.args.get[5]>
            - define x2 <context.args.get[6]>
            - define y2 <context.args.get[7]>
            - define z2 <context.args.get[8]>
            - if <location[<[x1]>,<[y1]>,<[z1]>,world]||null> == null && <location[<[x2]>,<[y2]>,<[z2]>,world]||null> == null:
                - narrate "<red> ERROR: The location of the jail is invalid."
                - stop
            - if <cuboid[<[jail_name]>]||null> != null:
                - narrate "<red> ERROR: The name is used by other jail."
                - stop
            - define jail <cuboid[<location[<[x1]>,<[y1]>,<[z1]>,world]>|<location[<[x2]>,<[y2]>,<[z2]>,world]>]>
            - define jails <server.list_notables[cuboids].parse[notable_name].filter[starts_with[jail]]>
            - foreach <[jails]> as:other_jail:
                - if <[jail].intersects[<cuboid[<[other_jail]>]>]>:
                    - narrate "<red> ERROR: Your jail conflicts with other jail. Try to change the location of your jail."
                    - stop
            - note <[jail]> as:<[jail_name]>
            - narrate "<green> Jail <blue><[name]> <green>created!"
            - stop
        - if <[action]> == delete:
            - if <cuboid[<[jail_name]>]||null> == null:
                - narrate "<red> ERROR: Jail <[name]> doesn't exist."
                - stop
            - note remove as:<[jail_name]>
            - note remove as:<[jail_name]>_spawn
            - narrate "<green> Jail <blue><[name]> <red>deleted!"
            - stop
        - narrate "<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate  "<red> To create a jail: /jail create <yellow>jailname x1 y1 z1 x2 y2 z2"
        - narrate  "<red> To delete a jail: /jail delete <yellow>jailname"