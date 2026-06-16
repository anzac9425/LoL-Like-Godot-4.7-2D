extends Control

const RUNE_RESOURCE_ROOT := "res://src/resources/runes"
const SLOT_KEYSTONE := "keystone"
const SLOT_PRIMARY_1 := "primary_1"
const SLOT_PRIMARY_2 := "primary_2"
const SLOT_PRIMARY_3 := "primary_3"
const SLOT_SECONDARY := "secondary"
const SLOT_SHARD_1 := "shard_1"
const SLOT_SHARD_2 := "shard_2"
const SLOT_SHARD_3 := "shard_3"

@export_dir var rune_resource_root: String = RUNE_RESOURCE_ROOT
@export var icon_size := Vector2(48.0, 48.0)
@export var disabled_alpha := 0.35

var runes_by_tree: Dictionary = {}
var selected_primary_tree := ""
var selected_secondary_tree := ""
var selected_runes: Dictionary = {}

@onready var primary_title: Label = %PrimaryTreeLabel
@onready var secondary_title: Label = %SecondaryTreeLabel
@onready var shard_title: Label = %ShardLabel
@onready var primary_sections: VBoxContainer = %PrimarySections
@onready var secondary_sections: VBoxContainer = %SecondarySections
@onready var shard_sections: VBoxContainer = %ShardSections


func _ready() -> void:
	_load_runes()
	_initialize_tree_selection()
	_rebuild_page()


func get_selected_runes() -> Dictionary:
	return selected_runes.duplicate()


func _load_runes() -> void:
	runes_by_tree.clear()
	for rune in _load_rune_resources(rune_resource_root):
		var tree := _get_rune_tree(rune)
		if tree.is_empty():
			continue
		if not runes_by_tree.has(tree):
			runes_by_tree[tree] = []
		runes_by_tree[tree].append(rune)


func _load_rune_resources(path: String) -> Array[RuneData]:
	var found: Array[RuneData] = []
	var directory := DirAccess.open(path)
	if directory == null:
		return found

	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		var child_path := path.path_join(file_name)
		if directory.current_is_dir():
			if not file_name.begins_with("."):
				found.append_array(_load_rune_resources(child_path))
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var resource := load(child_path)
			if resource is RuneData:
				found.append(resource)
		file_name = directory.get_next()
	directory.list_dir_end()
	return found


func _initialize_tree_selection() -> void:
	var rune_trees := runes_by_tree.keys()
	rune_trees.sort()
	selected_primary_tree = _first_non_shard_tree(rune_trees)
	selected_secondary_tree = _first_different_non_shard_tree(rune_trees, selected_primary_tree)
	selected_runes.clear()


func _first_non_shard_tree(trees: Array) -> String:
	for tree in trees:
		if String(tree) != RuneData.TREE_SHARDS:
			return String(tree)
	return ""


func _first_different_non_shard_tree(trees: Array, primary_tree: String) -> String:
	for tree in trees:
		var tree_name := String(tree)
		if tree_name != RuneData.TREE_SHARDS and tree_name != primary_tree:
			return tree_name
	return ""


func _rebuild_page() -> void:
	primary_title.text = "Primary: %s" % _display_name(selected_primary_tree)
	secondary_title.text = "Secondary: %s" % _display_name(selected_secondary_tree)
	shard_title.text = "Shards"
	_rebuild_primary_column()
	_rebuild_secondary_column()
	_rebuild_shard_column()


func _rebuild_primary_column() -> void:
	_clear_children(primary_sections)
	_add_section(primary_sections, "Keystone", _runes_for_slot(selected_primary_tree, RuneData.SLOT_KEYSTONE), SLOT_KEYSTONE, 1)
	_add_section(primary_sections, "Row 1", _runes_for_slot(selected_primary_tree, RuneData.SLOT_ROW_1), SLOT_PRIMARY_1, 1)
	_add_section(primary_sections, "Row 2", _runes_for_slot(selected_primary_tree, RuneData.SLOT_ROW_2), SLOT_PRIMARY_2, 1)
	_add_section(primary_sections, "Row 3", _runes_for_slot(selected_primary_tree, RuneData.SLOT_ROW_3), SLOT_PRIMARY_3, 1)


func _rebuild_secondary_column() -> void:
	_clear_children(secondary_sections)
	_add_tree_picker(secondary_sections)
	_add_section(secondary_sections, "Selection 1", _secondary_runes(), SLOT_SECONDARY, 2)
	_add_section(secondary_sections, "Selection 2", _secondary_runes(), SLOT_SECONDARY, 2)


func _rebuild_shard_column() -> void:
	_clear_children(shard_sections)
	_add_section(shard_sections, "Offense", _runes_for_slot(RuneData.TREE_SHARDS, RuneData.SLOT_SHARD_1), SLOT_SHARD_1, 1)
	_add_section(shard_sections, "Flex", _runes_for_slot(RuneData.TREE_SHARDS, RuneData.SLOT_SHARD_2), SLOT_SHARD_2, 1)
	_add_section(shard_sections, "Defense", _runes_for_slot(RuneData.TREE_SHARDS, RuneData.SLOT_SHARD_3), SLOT_SHARD_3, 1)


func _add_tree_picker(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(row)
	var trees := runes_by_tree.keys()
	trees.sort()
	for tree in trees:
		var tree_name := String(tree)
		if tree_name == RuneData.TREE_SHARDS or tree_name == selected_primary_tree:
			continue
		var button := Button.new()
		button.text = _display_name(tree_name)
		button.toggle_mode = true
		button.button_pressed = tree_name == selected_secondary_tree
		button.pressed.connect(_on_secondary_tree_pressed.bind(tree_name))
		row.add_child(button)


func _add_section(parent: VBoxContainer, title: String, runes: Array, slot_key: String, max_selected: int) -> void:
	var label := Label.new()
	label.text = title
	parent.add_child(label)

	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(grid)

	for rune in runes:
		grid.add_child(_create_rune_control(rune, slot_key, max_selected))


func _create_rune_control(rune: RuneData, slot_key: String, max_selected: int) -> BaseButton:
	var button: BaseButton
	if rune.icon != null:
		var texture_button := TextureButton.new()
		texture_button.texture_normal = rune.icon
		texture_button.custom_minimum_size = icon_size
		texture_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button = texture_button
	else:
		var text_button := Button.new()
		text_button.text = rune.rune_name if not rune.rune_name.is_empty() else resource_path_to_name(rune.resource_path)
		text_button.custom_minimum_size = Vector2(140.0, 36.0)
		button = text_button

	button.toggle_mode = true
	button.tooltip_text = rune.rune_name
	button.button_pressed = _is_rune_selected(slot_key, rune)
	button.disabled = not _can_select_rune(slot_key, rune, max_selected)
	button.modulate.a = disabled_alpha if button.disabled else 1.0
	button.pressed.connect(_on_rune_pressed.bind(slot_key, rune, max_selected))
	return button


func _runes_for_slot(tree: String, slot: String) -> Array:
	var result := []
	for rune in runes_by_tree.get(tree, []):
		if rune.slot == slot:
			result.append(rune)
	return result


func _secondary_runes() -> Array:
	var result := []
	for rune in runes_by_tree.get(selected_secondary_tree, []):
		if rune.slot != RuneData.SLOT_KEYSTONE:
			result.append(rune)
	return result


func _on_secondary_tree_pressed(tree: String) -> void:
	selected_secondary_tree = tree
	selected_runes.erase(SLOT_SECONDARY)
	_rebuild_page()


func _on_rune_pressed(slot_key: String, rune: RuneData, max_selected: int) -> void:
	var slot_selection: Array = selected_runes.get(slot_key, [])
	if slot_selection.has(rune):
		slot_selection.erase(rune)
	else:
		if slot_selection.size() >= max_selected:
			slot_selection.pop_front()
		slot_selection.append(rune)
	selected_runes[slot_key] = slot_selection
	_rebuild_page()


func _can_select_rune(slot_key: String, rune: RuneData, max_selected: int) -> bool:
	if slot_key == SLOT_SECONDARY and _secondary_slot_already_selected(rune):
		return false
	var slot_selection: Array = selected_runes.get(slot_key, [])
	return slot_selection.has(rune) or slot_selection.size() < max_selected


func _secondary_slot_already_selected(rune: RuneData) -> bool:
	var slot_selection: Array = selected_runes.get(SLOT_SECONDARY, [])
	for selected: RuneData in slot_selection:
		if selected != rune and selected.slot == rune.slot:
			return true
	return false


func _is_rune_selected(slot_key: String, rune: RuneData) -> bool:
	return selected_runes.get(slot_key, []).has(rune)


func _get_rune_tree(rune: RuneData) -> String:
	return rune.tree


func _display_name(value: String) -> String:
	if value.is_empty():
		return "None"
	return value.capitalize()


func resource_path_to_name(path: String) -> String:
	if path.is_empty():
		return "Unnamed Rune"
	return path.get_file().get_basename().capitalize()


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
