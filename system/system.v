module system

import interact

pub enum OS {
	unknown
	linux
	windows
	macos
}

pub fn gather_system_os() OS {
	mut os := $if windows { OS.windows } $else $if linux { .linux } $else $if macos { .macos } $else { .unknown }
	if os == .unknown {
		questionnaire := interact.generate_choices({
			'linux':   OS.linux
			'windows': .windows
			'macos':   .macos
		})
		os = interact.run_choice_list('Choose OS:', questionnaire, 0)
	}
	return os
}

pub enum Arch {
	unknown
	x64
	arm64
}

pub fn gather_system_arch() Arch {
	mut arch := $if amd64 { Arch.x64 } $else $if arm64 || aarch64 { .arm64 } $else { .unknown }
	if arch == .unknown {
		questionnaire := interact.generate_choices({
			'x64':   Arch.x64
			'arm64': .arm64
		})
		arch = interact.run_choice_list('Choose arch:', questionnaire, 0)
	}
	return arch
}

pub enum Runner {
	unknown
	cpu
	cuda
	cuda12
	cuda13
	rocm
	vulkan
}

pub fn gather_system_runner(os OS) Runner {
	mut runner := if os == .macos { Runner.cpu } else { .unknown }
	{
		questionnaire := interact.generate_choices({
			'cpu':    Runner.cpu
			'cuda':   .cuda
			'rocm':   .rocm
			'vulkan': .vulkan
		})
		runner = interact.run_choice_list('Choose runner:', questionnaire, 0)
	}
	if runner == .cuda {
		if os == .linux {
			runner = .vulkan
		} else {
			questionnaire := interact.generate_choices({
				'cuda12 (Maxwell and up)': Runner.cuda12
				'cuda13 (Turing and up)':  .cuda13
			})
			runner = interact.run_choice_list('Choose cuda version:', questionnaire, 0)
		}
	}
	return runner
}
