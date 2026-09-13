module github

import net.http
import json2

pub struct Release {
pub:
	assets []Asset @[json: assets]
}

struct Asset {
pub:
	name                 string @[json: name]
	browser_download_url string @[json: browser_download_url]
}

pub fn get_latest_release(owner string, repo string) !Release {
	mut header := http.Header{}

	header.add(.accept, 'application/vnd.github+json')
	header.add_custom('X-GitHub-Api-Version', '2026-03-10')!

	config := http.FetchConfig{
		url: 'https://api.github.com/repos/${owner}/${repo}/releases'
		method: .get
		params: {
			'per_page': '1'
		}
		header: header
	}

	res := http.fetch(config) or {
		return error('failed to fetch release: ${err}')
	}

	releases := json2.decode[[]Release](res.body) or {
		return error('failed to decode release: ${err}')
	}

	return releases[0]
}
