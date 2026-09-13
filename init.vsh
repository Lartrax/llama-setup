#!/usr/bin/env -S v

import status_logger
import tasks
import term

term.clear()

logger := status_logger.new()

task := tasks.new_handler(&logger)

if !is_file('.env') {
	task.create_default_env()
}

os, arch, runner := task.get_system_info()

llama_file, cuda_file := task.find_latest_llama_release(os, arch, runner) or { panic(err) }

task.install_llama(llama_file) or { panic(err) }

if os == .windows && (runner == .cuda12 || runner == .cuda13) {
	task.install_cuda_dlls(cuda_file) or { panic(err) }
}

if os == .macos {
	task.remove_macos_quarantine() or { panic(err) }
}

println('Done!\n')
println('\x1b[97mNext steps:\n')
println('Install a model:\x1b[m')

ram := if runner == .cpu { 'ram' } else { 'vram' }

println('\tmake install-low\t\x1b[90mmin 2 GB ${ram} available\x1b[m')
println('\tmake install-high\t\x1b[90mmin 4 GB ${ram} available\x1b[m')
println('With aria2c:')
println('\tmake install-low-fast')
println('\tmake install-high-fast\n')
println('\x1b[97mStart a server:\x1b[m')
println('\tmake start-ui\t\t\x1b[90mhttp://localhost:8080\x1b[m')
println('\tmake start\t\t\x1b[90mhttp://localhost:8080/v1\x1b[m\n')
println('\x1b[97mModify environment:\t\t\x1b[90m.env\x1b[m')
println('\tGet or set API key')
println('\tChange context size\t\x1b[90m0 for full context, 8k-64k for 2-6 GB ${ram}\x1b[m')
