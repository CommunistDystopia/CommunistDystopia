List_Task_Script:
    type: task
    debug: false
    definitions: jail_name|member|list_page
    script:
        - if <[list_page].is_integer>:
            - define jail_member <server.flag[<[jail_name]>_<[member]>s]||null>
            - if <[jail_member]> == null || <[jail_member].is_empty>:
                - if <[jail_name].starts_with[jail_]>:
                    - narrate "<blue> <[jail_name].after[jail_]> <green>have <blue>0 <green><[member].to_lowercase>s."
                - else:
                    - narrate "<blue> <[jail_name]> <green>have <blue>0 <green><[member].to_lowercase>s."
                - stop
            - if <[jail_name].starts_with[jail_]>:
                - narrate "<blue> <[jail_name].after[jail_]> <green>have <blue><[jail_member].size> <green><[member].to_lowercase>s."
            - else:
                - narrate "<blue> <[jail_name]> <green>have <blue><[jail_member].size> <green><[member].to_lowercase>s."
            - if <[jail_member].size> > 10:
                - if <[list_page]> > <[jail_member].size.div[10]>:
                    - narrate "<red> ERROR! Page number invalid."
                    - stop
                - narrate "<green> Page [<[list_page]>/<[jail_member].size.div[10].truncate>]"
                - flag player <[member]>_num_min:<[list_page].mul[10]>
                - flag player <[member]>_num_max:<[list_page].add[1].mul[10]>
                - if <[list_page]> != 0 && <player.flag[<[member]>_num_max].div[<[jail_member].size>]> != 1:
                    - flag player <[member]>_num_max:<[jail_member].size>
                - if <[list_page]> > 0:
                    - flag player <[member]>_num_min:++
                - foreach <[jail_member].get[<player.flag[<[member]>_num_min]>].to[<player.flag[<[member]>_num_max]>]> as:member_for:
                    - if <[loop_index]> == 10:
                        - if <[member_for].name||null> != null:
                            - narrate "<green> <[member]> <[loop_index]>: <blue><[member_for].name>"
                        - else:
                            - narrate "<green> <[member]> <[loop_index]>: <blue><[member_for]>"
                        - foreach stop
                    - if <[member_for].has_attribute[name]>:
                        - narrate "<green> <[member]> <[loop_index]>: <blue><[member_for].name>"
                    - else:
                        - narrate "<green> <[member]> <[loop_index]>: <blue><[member_for].after[jail_]>"
                - flag player <[member]>_num_min:!
                - flag player <[member]>_num_max:!
            - if <[jail_member].size> <= 10:
                - foreach <[jail_member]> as:member_for:
                    - if <[member_for].name||null> != null:
                        - narrate "<green> <[member]> <[loop_index]>: <blue><[member_for].name>"
                    - else:
                        - narrate "<green> <[member]> <[loop_index]>: <blue><[member_for].after[jail_]>"
            - stop