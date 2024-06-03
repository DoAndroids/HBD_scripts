import requests
import os
import shutil
from dotenv import load_dotenv

load_dotenv()

QB_URL="http://" + os.getenv('hostIp') + ":" + os.getenv('qbitPort')
EXPORT_DIR = os.getenv('HOME') + '/tmp'
TORRENTS_DIR = os.getenv('HOME') + '/.local/share/qBittorrent/BT_backup/'

CATEGORY='Music'

def login():
    response = requests.post(f'{QB_URL}/api/v2/auth/login', data={
        'username': os.getenv('qbitUser'),
        'password': os.getenv('qbitPass')
    })
    if response.text == 'Ok.':
        print("Logged in successfully.")
    else:
        print("Failed to log in.")
        exit()

def get_torrents_by_category(category):
    response = requests.get(f'{QB_URL}/api/v2/torrents/info', params={
        'category': category
    })
    if response.status_code == 200:
        return response.json()
    else:
        print("Failed to fetch torrents.")
        exit()

def export_torrent_files(torrents):
    if not os.path.exists(TORRENTS_DIR):
        os.makedirs(TORRENTS_DIR)

    for torrent in torrents:
        torrent_hash = torrent['hash']
        torrent_name = torrent['name']
        print(torrent_hash, torrent_name)
        response = requests.get(f'{QB_URL}/api/v2/torrents/file', params={
            'hash': torrent_hash
        })
        if response.status_code == 200:
            with open(f'{EXPORT_DIR}/{torrent_name}.torrent', 'wb') as f:
                f.write(response.content)
            print(f"Exported {torrent_name}.torrent")
        else:
            expectedFile= f"{TORRENTS_DIR}{torrent_hash}.torrent"
            if os.path.isfile(expectedFile):
                newFile = f"{EXPORT_DIR}/{torrent_name}.torrent"
                shutil.copyfile(expectedFile,newFile)
            else:
                print(f"Source torrent {expectedFile} does not exist")

if __name__ == '__main__':
    print("Calling login...")
    login()
    print("Calling get torrents...")
    torrents = get_torrents_by_category(CATEGORY)
    export_torrent_files(torrents)
