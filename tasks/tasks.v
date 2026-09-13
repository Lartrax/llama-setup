module tasks

import convert
import download_manager
import file_manager
import github
import interact
import status_logger
import system
import rand

@[heap]
pub struct TaskHandler {
	logger &status_logger.Logger
}

pub fn new_handler(logger &status_logger.Logger) TaskHandler {
	return TaskHandler{
		logger: logger
	}
}

pub fn (h TaskHandler) create_default_env() {
	h.logger.info('Creating default environment')
	mut file := create('.env') or {
		msg := 'failed to create default env: ${err}'
		h.logger.warn('Creating default environment (warn)', message: msg)
		return
	}
	defer {
		file.close()
	}
	buffer := 'API_KEY=${rand.hex(64)}\nCONTEXT_SIZE=0\nSPLIT_COUNT=16'.bytes()
	byte_count := file.write(buffer) or {
		msg := 'failed to write buffer to default env: ${err}'
		h.logger.warn('Creating default environment (warn)', message: msg)
		return
	}
	if byte_count < buffer.len {
		msg := 'did not finish writing env buffer ${byte_count} out of ${buffer.len} bytes written'
		h.logger.warn('Creating default environment (warn)', message: msg)
		return
	}
	h.logger.ok('Creating default environment (done)')
}

pub fn (h TaskHandler) get_system_info() (system.OS, system.Arch, system.Runner) {
	h.logger.info(' - - ')
	os := system.gather_system_os()
	h.logger.info('${os} - -', overwrite: true)
	arch := system.gather_system_arch()
	h.logger.info('${os} - ${arch} -', overwrite: true)
	runner := system.gather_system_runner(os)
	h.logger.set('${os} - ${arch} - ${runner}')
	return os, arch, runner
}

pub fn (h TaskHandler) find_latest_llama_release(os system.OS, arch system.Arch, runner system.Runner) !(convert.FileSpec, convert.FileSpec) {
	h.logger.info('Finding compatible release from GitHub')

	release := github.get_latest_release('ggml-org', 'llama.cpp') or {
		msg := 'failed to get latest release ggml-org/llama.cpp'
		h.logger.error('Finding compatible release from GitHub (error)', message: msg)
		return err
	}

	os_check := match os {
		.linux { 'ubuntu' }
		.windows { 'win' }
		.macos { 'macos' }
		.unknown { panic('unknown os') }
	}

	arch_check := match arch {
		.x64 { 'x64' }
		.arm64 { 'arm64' }
		.unknown { panic('unknown arch') }
	}

	runner_check := match runner {
		.cpu { 'cpu' }
		.cuda { panic('cuda version not selected') }
		.cuda12 { 'cuda12' }
		.cuda13 { 'cuda13' }
		.rocm { 'rocm' }
		.vulkan { 'vulkan' }
		.unknown { panic('unknown runner') }
	}

	mut llama_file := convert.FileSpec{}
	mut cuda_file := convert.FileSpec{}

	for _, asset in release.assets {
		scheme := asset.name.split('-')
		if scheme[0] == 'llama' && scheme[2] == 'bin' {
			spec := convert.get_file_spec_from_download_scheme(scheme) or { continue }
			if spec.os == os_check && spec.arch == arch_check && spec.runner == runner_check {
				llama_file = spec
				llama_file.download_url = asset.browser_download_url
				if cuda_file.download_url != '' {
					break
				}
			}
		}
		// Gather cuda dlls for Windows
		if (runner == .cuda12 || runner == .cuda13) && scheme[0] == 'cudart' {
			spec := convert.get_file_spec_from_download_scheme(scheme) or { continue }
			if spec.os == os_check && spec.arch == arch_check && spec.runner == runner_check {
				cuda_file = spec
				cuda_file.download_url = asset.browser_download_url
				if llama_file.download_url != '' {
					break
				}
			}
		}
	}

	h.logger.ok('Finding compatible release from GitHub (done)')
	return llama_file, cuda_file
}

pub fn (h TaskHandler) install_llama(llama_file convert.FileSpec) ! {
	h.logger.info('Installing llama.cpp (downloading)')
	download_manager.download_to_path(llama_file.download_url,
		'./llama_tmp.${llama_file.extention}') or {
		interact.clear(1)
		msg := 'failed to download llama archive: ${err}'
		h.logger.error('Installing llama.cpp (error)', message: msg)
		return err
	}
	interact.clear(1)
	h.logger.info('Installing llama.cpp (unpacking)', overwrite: true)
	file_manager.unpack_archive('./llama_tmp.${llama_file.extention}', llama_file.extention,
		'./llama') or {
		msg := 'failed to unpack llama archive: ${err}, extract it yourself'
		h.logger.error('Installing llama.cpp (error)', message: msg)
		return err
	}
	h.logger.info('Installing llama.cpp (cleanup)', overwrite: true)
	file_manager.delete_file('./llama_tmp.${llama_file.extention}') or {
		msg := 'failed to delete llama tmp archive: ${err}, delete it yourself'
		h.logger.warn('Installing llama.cpp (warn)', message: msg)
		return
	}
	h.logger.ok('Installing llama.cpp (done)')
	return
}

pub fn (h TaskHandler) install_cuda_dlls(cuda_file convert.FileSpec) ! {
	h.logger.info('Installing cuda dlls (downloading)')
	download_manager.download_to_path(cuda_file.download_url, './cuda_tmp.${cuda_file.extention}') or {
		interact.clear(1)
		msg := 'failed to download cuda archive: ${err}'
		h.logger.error('Installing cuda dlls (error)', message: msg)
		return err
	}
	interact.clear(1)
	h.logger.info('Installing cuda dlls (unpacking)', overwrite: true)
	file_manager.unpack_archive('./cuda_tmp.${cuda_file.extention}', cuda_file.extention, './llama') or {
		msg := 'failed to unpack cuda archive: ${err}, extract it yourself'
		h.logger.error('Installing cuda dlls (error)', message: msg)
		return err
	}
	h.logger.info('Installing cuda dlls (cleanup)', overwrite: true)
	file_manager.delete_file('./cuda_tmp.${cuda_file.extention}') or {
		msg := 'failed to delete cuda tmp archive: ${err}, delete it yourself'
		h.logger.warn('Installing cuda dlls (warn)', message: msg)
		return
	}
	h.logger.ok('Installing cuda dlls (done)')
	return
}

pub fn (h TaskHandler) remove_macos_quarantine() ! {
	h.logger.info('Removing quarantine from files')
	file_manager.decontaminate_directory('./llama') or {
		msg := 'failed to remove quarantine from files: ${err}'
		h.logger.error('Removing quarantine from files (error)', message: msg)
		return err
	}
	h.logger.ok('Removing quarantine from files (done)')
	return
}
