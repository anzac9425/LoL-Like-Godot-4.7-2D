extends Resource
class_name RuneData

const TREE_SHARDS := "shards"
const SLOT_KEYSTONE := "keystone"
const SLOT_ROW_1 := "row_1"
const SLOT_ROW_2 := "row_2"
const SLOT_ROW_3 := "row_3"
const SLOT_SHARD_1 := "shard_1"
const SLOT_SHARD_2 := "shard_2"
const SLOT_SHARD_3 := "shard_3"

@export var rune_name: String
@export var tree: String
@export_enum("keystone", "row_1", "row_2", "row_3", "shard_1", "shard_2", "shard_3") var slot: String = SLOT_ROW_1
@export var icon: Texture2D
@export var statistics: Statistics
@export var rune_logic: Script
