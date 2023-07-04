# .github/scripts/check-path.py

import requests
import sys

def is_path_updated(token, repo, commit, path):
    headers = { 'Authorization': f'Bearer {token}' }
    response = requests.get(f'https://api.github.com/repos/{repo}/commits/{commit}', headers=headers)
    commit_data = response.json()

    for file in commit_data['files']:
        if file['filename'].startswith(path):
            return 'true'
    return 'false'

if __name__ == "__main__":
    print(is_path_updated(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]))