extends Node

# Animation consts
const ANIM_IDLE_ID = 0
const ANIM_WALK_ID = 1
const ANIM_ATTACK_ID = 2
const ANIM_TRANSITION_NODE = "transition"
const MAX_ITEMS = 258
const MAX_PARTY_COUNT = 3
const VECTOR3_UP = Vector3(0, 1, 0)
const TIME_BETWEEN_CLICKS = 0.5
const MAX_BATTLE_SPEED = 50

enum Skill { NONE, FIRE_BALL, POTION_HP, POTION_MP }
enum ItemType { NONE, POTION, WEAPON, HELMET, ARMOR, GLOVES, BOOTS }
enum PartyType { NONE, PLAYER, ENEMY }
