Hard_Fishing_Script:
    type: world
    debug: false
    events:
        on player fishes while caught_entity:
            - inventory adjust slot:<player.held_item_slot> durability:<player.inventory.slot[<player.held_item_slot>].durability.add[1]>
            - determine cancelled
        on player fishes while caught_fish:
            - define chance_to_fish <util.random.int[1].to[40]>
            - if <[chance_to_fish]> > 1.0:
                - inventory adjust slot:<player.held_item_slot> durability:<player.inventory.slot[<player.held_item_slot>].durability.add[1]>
                - narrate "<red> Failed to catch the fish! Try again"
                - determine cancelled
                - stop
        on COD||SALMON||TROPICAL_FISH||PUFFERFISH spawns:
            - define chance_to_spawn <util.random.int[1].to[100]>
            - if <[chance_to_spawn]> > 50.0:
                - determine cancelled
                - stop