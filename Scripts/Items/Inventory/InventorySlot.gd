extends TextureRect

func setTemplate(itemTemplate):
	var item = itemTemplate.instance()	
	set_texture(item.get_texture())
	pass

