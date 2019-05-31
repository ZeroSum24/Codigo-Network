import sys
sys.path.append("lib/")
from Firmware import *
import ipfshttpclient

#res = api.get('Qmbds4EKV5wEoXL9bXnxbFbTa9EzYmAkKcTTTYfKWq6PH6')
#print(res)

class IPFS_Admin:

    def __init__(self,local,verbose = False):
        if local:
            print("Local connection initiated")
            self.connect(verbose,local,'/ip4/127.0.0.1/tcp/5001')
        else:
            print("Remote connection initiated")
            self.connect(verbose,local,'https://ipfs.infura.io',)

    def connect(self, verbose, local, ip, port = 5001):
        try:
            self.api = ipfshttpclient.connect(ip)
        except Exception as expt:
            print("Exception:", expt)
            print("Could not connect to IPFS Deamon :(")

    def upload_firmware(self,firmware):
        res = self.api.add(firmware.firmware_dir) #pin_add to pin the file as well
        return res

    def download_firmware(self,ipfs_link):
        res = self.api.get(ipfs_link)
