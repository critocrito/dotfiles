import re

def oimaptransfolder_cryptodrunks(foldername):
    if(foldername == "INBOX"):
        retval = "cryptodrunks"
    else:
        retval = "cryptodrunks." + foldername
    retval = re.sub("/", ".", retval)
    return retval

def localtransfolder_cryptodrunks(foldername):
    if(foldername == "cryptodrunks"):
        retval = "INBOX"
    else:
        # remove leading 'cryptodrunks.'
        retval = re.sub("cryptodrunks\.", "", foldername)
    retval = re.sub("\.", "/", retval)
    return retval
