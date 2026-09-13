module interact

import term
import math

const zero = 48
const one = 49
const two = 50
const three = 51
const four = 52
const five = 53
const six = 54
const seven = 55
const eight = 56
const nine = 57

const up = $if windows { 14680136 } $else { 4283163 }
const left = $if windows { 14680139 } $else { 4479771 }
const right = $if windows { 14680141 } $else { 4414235 }
const down = $if windows { 14680144 } $else { 4348699 }
const enter = $if windows { 13 } $else { 10 }
const space = 32

pub fn clear(n int) {
	for _ in 0 .. n {
		term.clear_previous_line()
	}
}

struct Choice[T] {
	text  string
	value T
}

pub fn run_choice_list[T](description string, choices []Choice[T], selected int) T {
	lines_count := 1 + choices.len
	again := fn [lines_count, description, choices] [T](selected int) T {
		clear(lines_count)
		return run_choice_list(description, choices, selected)
	}

	print('${description}\n')
	for i, choice in choices {
		if i == selected {
			print('${choice.text}\t\x1b[90m[\x1b[m${i}\x1b[90m]\x1b[m\x1b[96m<-\x1b[m\n')
		} else {
			print('${choice.text}\t[${i}]\n')
		}
	}

	key := term.key_pressed(blocking: true)
	return match key {
		zero...nine {
			// number: (48...57) - 48
			number := int(key - zero)
			if (selected * 10) + number < choices.len {
				// Press again for 1 - 12 - 123
				return again((selected * 10) + number)
			}
			return again(math.min(number, choices.len - 1))
		}
		up { again(math.max(selected - 1, 0)) }
		left { again(math.max(selected - 1, 0)) }
		right { again(math.min(selected + 1, choices.len - 1)) }
		down { again(math.min(selected + 1, choices.len - 1)) }
		enter {
			clear(lines_count)
			choices[selected].value
		}
		space {
			clear(lines_count)
			choices[selected].value
		}
		else { again(selected) }
	}
}

pub fn generate_choices[T](choices_map map[string]T) []Choice[T] {
	mut choices := []Choice[T]{}
	for key, value in choices_map {
		choices << Choice[T]{
			text: key
			value: value
		}
	}
	return choices
}
