extends Control

onready var _viewport = get_node("/root")

var _isDragging = false
var _dragTexture = null
var _item = null

signal onItemDragStarted
signal onItemDragEnded

func getItem():
	return _item

func spawnItem(itemTemplate):
	_item = itemTemplate.instance()
	_item.rect_min_size = rect_min_size
	_item.rect_size = rect_size	
	add_child(_item)
	pass

func _process(delta):
	if(_isDragging and _dragTexture != null):
		if(Input.is_action_pressed("ui_select")):
			var mousePos = _viewport.get_mouse_position()
			var textureSize = _dragTexture.get_size()
			_dragTexture.rect_global_position = Vector2(mousePos.x - textureSize.x/2, mousePos.y - textureSize.y/2)
		else:
			emit_signal("onItemDragEnded", _item)			
			_isDragging = false
			_item.set_visible(true)
			_dragTexture.queue_free()			
	pass

func _on_Control_gui_input(event):
	if(event is InputEventMouseButton and event.pressed and _item != null):
		_onItemPressed()
	pass

func _onItemPressed():	
	_isDragging = true
	_dragTexture = TextureRect.new()
	_item.set_visible(false)
	
	emit_signal("onItemDragStarted", self)
	_dragTexture.set_texture(_item.get_texture())
	_dragTexture.set_expand(true)
	_dragTexture.set_size(_item.get_size())
	_viewport.add_child(_dragTexture)
	pass
