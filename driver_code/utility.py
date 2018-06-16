'''
Set of Utility functions for cryptographic primitives
'''
from web3 import Web3
import binascii

# Generate a non-secure random number
# Used to create "dummy" firmware/ firmware descriptions

def __generate_random_txt(length = 300):
    import random
    import string
    random = ''.join([random.choice(string.ascii_letters + string.digits) for n in range(length)])
    return random

# Cryptographic hashing of message.
# Hash function used is SHA-3. Returns it as utf-8 formatted string

def __hash_utf8(msg):
    msg_hash = Web3.sha3(text= msg)
    hex_data = binascii.hexlify(msg_hash)
    return hex_data.decode('utf-8')


# Cryptographicaly sign the hash of message.
# The signature algorithm that will be used is one used in Ethereum 

def sign_firmware(msg_hash):
    #TODO: Implement a function that signs the firmware hash
    return "Not Implemented"


def generate_eth_pk(number):
    from eth_account import Account
    pk_list = []
    for i in range(0,number):
        acct = Account.create(__generate_random_txt(30)+ str(i))
        pk_list.append(acct.address)
    return pk_list