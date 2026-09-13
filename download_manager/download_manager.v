module download_manager

import net.http

pub fn download_to_path(url string, path string) ! {
	http.download_file_with_progress(url, path,
		downloader: &http.TerminalStreamingDownloader{}
	) or {
		return error('failed to download file: ${err}')
	}
	return
}
