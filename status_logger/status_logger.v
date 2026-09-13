module status_logger

import interact
import term

const red = '\x1b[31m'
const green = '\x1b[32m'
const yellow = '\x1b[33m'
const blue = '\x1b[34m'

pub struct Logger {
mut:
	previous_lines int
}

pub fn new() Logger {
	return Logger{}
}

@[params]
pub struct StatusLoggerParams {
pub:
	message   ?string
	overwrite ?bool
}

// StatusLogger.info()
// Prints a white title and optional message to the terminal.
// By default will not overwrite the last status.
pub fn (mut logger Logger) info(title string, p StatusLoggerParams) {
	status := if p.message != none { '${title}\n${p.message}' } else { title }
	should_overwrite := if p.overwrite == none { false } else { p.overwrite }
	overwrite_lines := if should_overwrite == true { logger.previous_lines } else { 0 }
	print_status(status, overwrite_lines: overwrite_lines)
	logger.previous_lines = status.split_into_lines().len
}

// StatusLogger.set()
// Prints a blue title and optional message to the terminal.
// Will overwrite the last status by default.
pub fn (mut logger Logger) set(title string, p StatusLoggerParams) {
	status := if p.message != none { '${title}\n${p.message}' } else { title }
	should_overwrite := if p.overwrite == none { true } else { p.overwrite }
	overwrite_lines := if should_overwrite == true { logger.previous_lines } else { 0 }
	print_status(status, ansi_color: blue, overwrite_lines: overwrite_lines)
	logger.previous_lines = status.split_into_lines().len
}

// StatusLogger.ok()
// Prints a green title and optional message to the terminal.
// Will overwrite the last status by default.
pub fn (mut logger Logger) ok(title string, p StatusLoggerParams) {
	status := if p.message != none { '${title}\n${p.message}' } else { title }
	should_overwrite := if p.overwrite == none { true } else { p.overwrite }
	overwrite_lines := if should_overwrite == true { logger.previous_lines } else { 0 }
	print_status(status, ansi_color: green, overwrite_lines: overwrite_lines)
	logger.previous_lines = status.split_into_lines().len
}

// StatusLogger.warn()
// Prints a yellow title and optional message to the terminal.
// Will overwrite the last status by default.
pub fn (mut logger Logger) warn(title string, p StatusLoggerParams) {
	status := if p.message != none { '${title}\n${p.message}' } else { title }
	should_overwrite := if p.overwrite == none { true } else { p.overwrite }
	overwrite_lines := if should_overwrite == true { logger.previous_lines } else { 0 }
	print_status(status, ansi_color: yellow, overwrite_lines: overwrite_lines)
	logger.previous_lines = status.split_into_lines().len
}

// StatusLogger.error()
// Prints a red title and optional message to the terminal.
// Will overwrite the last status by default.
pub fn (mut logger Logger) error(title string, p StatusLoggerParams) {
	status := if p.message != none { '${title}\n${p.message}' } else { title }
	should_overwrite := if p.overwrite == none { true } else { p.overwrite }
	overwrite_lines := if should_overwrite == true { logger.previous_lines } else { 0 }
	print_status(status, ansi_color: red, overwrite_lines: overwrite_lines)
	logger.previous_lines = status.split_into_lines().len
}

@[params]
struct PrintStatusParams {
	ansi_color      string
	overwrite_lines int
}

fn print_status(status string, p PrintStatusParams) {
	width, _ := term.get_terminal_size()
	if p.overwrite_lines > 0 {
		interact.clear(p.overwrite_lines + 1)
	}
	if status != '' { println('${p.ansi_color}${status}\x1b[m') }
	println('${p.ansi_color}${'-':(width / 2)r}\x1b[m')
}
