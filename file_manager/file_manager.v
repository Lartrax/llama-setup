module file_manager

import os

pub fn unpack_archive(archive_path string, archive_extention string, destination_path string) ! {
	if archive_extention == 'zip' {
		os.execute_opt('powershell -Command "Expand-Archive -Path \'${archive_path}\' -DestinationPath \'${destination_path}\'"') or {
			return error('failed to extract archive: ${err}')
		}
	} else if archive_extention == 'tar.gz' {
		os.execute_opt('tar -xzf "${archive_path}" -C "${destination_path}"') or {
			return error('failed to extract archive: ${err}')
		}
	} else {
		return error('file extention: ${archive_extention} not implemented')
	}
	return
}

pub fn delete_file(file_path string) ! {
	$if windows {
		os.execute_opt('del ${file_path}') or {
			return error('failed to delete ${file_path}: ${err}')
		}
	} $else {
		os.execute_opt('rm ${file_path}') or {
			return error('failed to delete ${file_path}: ${err}')
		}
	}
	return
}

pub fn decontaminate_directory(directory_path string) ! {
	$if !macos {
		return
	}
	entries := ls(directory_path) or {
		return error('failed to retrieve quarantined files: ${err}')
	}
	mut errors := ''
	for entry in entries {
		if is_file('${directory_path}/${entry}') {
			execute_opt('xattr -d com.apple.quarantine ${directory_path}/${entry}') or {
				errors += '${entry}: ${err}\n'
				continue
			}
		}
	}
  if errors != '' {
    return error('failed to quarantine one or more files:\n${errors}')
  }
	return
}
