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
