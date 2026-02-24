from pathlib import Path
import socket
import subprocess

if __name__ == '__main__':
    sites_path=Path(f'/home/lcd/containers/nginx-{socket.gethostname()}/sites')

    site_names_and_repo = {
        "thou.sh": "https://github.com/thouu/thou.sh.git",
        "swagc.at": "https://github.com/thouu/swagc.at.git"
    }

    for site in site_names_and_repo:
        site_path=sites_path / site
        site_path.mkdir(parents=True, exist_ok=True)
        if (site_path / '.git').exists():
            subprocess.run(['git', '-C', site_path, 'pull'], check=True)
        else:
            subprocess.run(['git', 'clone', site_names_and_repo[site], site_path], check=True)
