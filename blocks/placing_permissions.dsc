# +----------------------
# |
# | PLACING PERMISSIONS
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
#

Placing_Permissions_Script:
    type: world
    debug: false
    events:
        on player right clicks block with:lava_bucket:
            - if !<player.has_permission[place.lava]>:
                - determine cancelled
        on player right clicks block with:item_frame:
            - if !<player.has_permission[place.item_frame]>:
                - determine cancelled
        on player right clicks block with:water_bucket:
            - if !<player.has_permission[place.water]>:
                - determine cancelled