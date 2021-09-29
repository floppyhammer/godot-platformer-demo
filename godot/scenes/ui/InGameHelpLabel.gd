extends Label


var tips = {
	"stick_is_full": "竹签已经满了！\n寻找和签上第一个食物一样的食物来消除它！",
	"continuous_elimitation": "相同的一列可以同时消除哦\n而且分数加倍！",
	"ticktock": "抓紧时间！",
}


# Called when the node enters the scene tree for the first time.
func _ready():
	activate("continuous_elimitation")


func activate(which_tip):
	if not tips.has(which_tip): return
	text = tips[which_tip]
	$AnimationPlayer.play("appear")
