extends CanvasModulate

export (float) var day_duration = 60.0  # Actual time of a day (in seconds)
export (float) var starting_day = 1
export (float) var starting_hour = 10  # 24 hours time (0-23)

export var color_dawn = Color(0.86, 0.70, 0.70, 1.0)
export var color_day = Color(1.0, 1.0, 1.0, 1.0)
export var color_dusk = Color(0.59, 0.66, 0.78, 1.0)
export var color_night = Color(0.07, 0.09, 0.38, 1.0)

export (float) var state_dawn_start_hour = 5
export (float) var state_day_start_hour = 7
export (float) var state_dusk_start_hour = 16
export (float) var state_night_start_hour = 18

# Transition time in game hours
export (float) var state_transition_duration = 1

# Actual transition time
var transition_duration

export (bool) var debug_mode = false

var current_day
var current_time  # Seconds in a day
var current_hour
var time4display = ''

var cycle
enum cycle_state { NIGHT, DAWN, DAY, DUSK }

#var state_labels = {"NIGHT": "夜晚", "DAWN": "黎明", "DAY": "白天", "DUSK": "黄昏"}
var state_labels = {"NIGHT": "Night", "DAWN": "Dawn", "DAY": "Day", "DUSK": "Dusk"}

var current_state = ''

func _ready():
	current_day = starting_day
	current_time = (day_duration / 24) * starting_hour
	current_hour = current_time / (day_duration / 24)
	
	transition_duration = (day_duration / 24) * state_transition_duration
	
	if current_hour >= state_night_start_hour or current_hour < state_dawn_start_hour:
		cycle = cycle_state.NIGHT
		color = color_night
	elif current_hour >= state_dawn_start_hour and current_hour < state_day_start_hour:
		cycle = cycle_state.DAWN
		color = color_dawn
	elif current_hour >= state_day_start_hour and current_hour < state_dusk_start_hour:
		cycle = cycle_state.DAY
		color = color_day
	elif current_hour >= state_dusk_start_hour and current_hour < state_night_start_hour:
		cycle = cycle_state.DUSK
		color = color_dusk

func _process(delta):
	day_cycle(delta)

func day_cycle(delta):
	current_time += delta
	
	current_hour = current_time / (day_duration / 24)
	
	if current_time >= day_duration:
		current_time = 0
		current_hour = 0
		current_day += 1

	if current_hour >= state_night_start_hour or current_hour < state_dawn_start_hour:
		cycle_test(cycle_state.NIGHT)
	elif current_hour >= state_dawn_start_hour and current_hour < state_day_start_hour:
		cycle_test(cycle_state.DAWN)
	elif current_hour >= state_day_start_hour and current_hour < state_dusk_start_hour:
		cycle_test(cycle_state.DAY)
	elif current_hour >= state_dusk_start_hour and current_hour < state_night_start_hour:
		cycle_test(cycle_state.DUSK)
	
	var minute = str(int(current_time / day_duration * 24 * 60) % 60)
	time4display = 'Day ' + str(current_day) + ' ' + str(int(current_hour)) + ':' + minute
	
	current_state = state_labels[str(cycle_state.keys()[cycle])]

func cycle_test(new_cycle):
	if cycle != new_cycle:
		cycle = new_cycle
		
		if cycle == cycle_state.NIGHT:
			$Tween.interpolate_property(self, "color", color_dusk, color_night, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
		
		if cycle == cycle_state.DAWN:
			$Tween.interpolate_property(self, "color", color_night, color_dawn, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
		
		if cycle == cycle_state.DAY:
			$Tween.interpolate_property(self, "color", color_dawn, color_day, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
		
		if cycle == cycle_state.DUSK:
			$Tween.interpolate_property(self, "color", color_day, color_dusk, transition_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.start()
