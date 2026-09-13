module convert

pub struct FileSpec {
pub mut:
	os           string
	arch         string
	runner       string
	extention    string
	download_url string
}

pub fn get_file_spec_from_download_scheme(scheme []string) !FileSpec {
	mut spec := FileSpec{}
	for i, value in scheme {
		if spec.os == '' {
			match value {
				'ubuntu' {
					spec.os = 'ubuntu'
				}
				'win' {
					spec.os = 'win'
				}
				'macos' {
					spec.os = 'macos'
				}
				else {}
			}
		}
		if spec.runner == '' {
			match value {
				'cpu' {
					spec.runner = 'cpu'
				}
				'cuda' {
					if scheme[i + 1].starts_with('12.') {
						spec.runner = 'cuda12'
					} else if scheme[i + 1].starts_with('13.') {
						spec.runner = 'cuda13'
					}
				}
				'rocm' {
					spec.runner = 'rocm'
				}
				'vulkan' {
					spec.runner = 'vulkan'
				}
				else {}
			}
		}
		if spec.arch == '' {
			match value {
				'x64.zip' {
					spec.arch = 'x64'
					spec.extention = 'zip'
				}
				'x64.tar.gz' {
					spec.arch = 'x64'
					spec.extention = 'tar.gz'
				}
				'arm64.zip' {
					spec.arch = 'arm64'
					spec.extention = 'zip'
				}
				'arm64.tar.gz' {
					spec.arch = 'arm64'
					spec.extention = 'tar.gz'
				}
				else {}
			}
		}
	}

	if spec.runner == '' {
		spec.runner = 'cpu'
	}

	if spec.os == '' || spec.arch == '' {
		return error('invalid scheme')
	}

	return spec
}
