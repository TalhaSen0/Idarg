class_name CollisionLayers
extends RefCounted

const WORLD: int = 1 << 0
const PLAYER_SWORD: int = 1 << 1
const OPPONENT_SWORD: int = 1 << 2
const BODY: int = 1 << 3
const HURTBOX: int = 1 << 4

const PLAYER_SWORD_MASK: int = WORLD | OPPONENT_SWORD | BODY
const OPPONENT_SWORD_MASK: int = WORLD | PLAYER_SWORD | BODY
const DAMAGE_QUERY_MASK: int = HURTBOX

const WORLD_MASK: int = PLAYER_SWORD | OPPONENT_SWORD | BODY
const BODY_MASK: int = WORLD | PLAYER_SWORD | OPPONENT_SWORD
