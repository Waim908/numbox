# -*- coding: UTF-8 -*-
import os
import tkinter
def end_session():
    os.system("wineboot -e")
def frose():
    os.system("wineboot -f")   
def init():
    os.system("wineboot -i")
def kill():
    os.system("wineboot -k")
def restart():
    os.system("wineboot -r") 
def shutdown():
    os.system("wineboot -s")
def update():
    os.system("wineboot -u")
window = tkinter.Tk()
window.resizable(False, False)
window.attributes('-toolwindow', True)
window.title("wineboot menu")
b1 = tkinter.Button(window, width=25, height=1, text="结束会话", command=end_session)
b2 = tkinter.Button(window, width=25, height=1, text="强制结束无法干净退出的进程", command=frose)
b3 = tkinter.Button(window, width=25, height=1, text="第一个实例初始化", command=init)
b4 = tkinter.Button(window, width=25, height=1, text="杀死所有进程", command=kill)
b5 = tkinter.Button(window, width=25, height=1, text="重启", command=restart)
b6 = tkinter.Button(window, width=25, height=1, text="关机", command=shutdown)
b7 = tkinter.Button(window, width=25, height=1, text="更新前缀目录", command=update)
b1.pack()
b2.pack()
b3.pack()
b4.pack()
b5.pack()
b6.pack()
b7.pack()
window.mainloop()