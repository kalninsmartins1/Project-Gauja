extends Node

# Animation consts
const ANIM_IDLE_ID = 0
const ANIM_WALK_ID = 1
const ANIM_ATTACK_ID = 2
const ANIM_TRANSITION_NODE = "transition"
const MAX_ITEMS = 258

enum Skill { NONE, FIRE_BALL, POTION_HP, POTION_MP }
enum ItemType { NONE, POTION, WEAPON, HELMET, ARMOR, GLOVES, BOOTS }