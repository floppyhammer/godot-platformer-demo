extends MarginContainer

var current_no = 0 # Currently shown item.
var total_no = 0 # Total items count.
var items = []

onready var select_btn = $VBoxC/HBoxC/VBoxC/Select
onready var portrait = $VBoxC/HBoxC/VBoxC/Portrait
onready var name_label = $VBoxC/HBoxC/VBoxC/NameLabel
onready var desc_label = $VBoxC/DescriptionLabel
onready var no_label = $VBoxC/HBoxC2/NoLabel
onready var last_btn = $VBoxC/HBoxC2/Last
onready var next_btn = $VBoxC/HBoxC2/Next
