extends "res://Scripts/NPC/Quests/Quest.gd"

enum EnemyType { NONE, CHICKEN }
export(EnemyType) var _destroyType

func getDestroyType():
	return _destroyType

func getQuestType():
	return GameConsts.QuestType.DESTROY
