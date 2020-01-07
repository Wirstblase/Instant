import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

from datetime import datetime
import _thread
from time import sleep
import random

cred = credentials.Certificate("instantServiceKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
print("app initialized!")

#docs = db.collection(u'users/boyfRzISQDQ1bw4aTuc7g3L58Vu1/CHATS/ldRNGoVI2aemqyft7r0jiGPy3l02/CHAT').stream()

def getDateTime():
    now = datetime.now()
    dt_string = now.strftime("%d-%m-%Y %I:%M:%S %p")
    print("date and time =", dt_string)
    global dateAndTime
    dateAndTime = dt_string


def compareTime(a,b): #a,b - STRING de formatul dd/mm/yy hh:mm:ss
    # return 0: a earlier than b
    # return 1: a equal to b
    # return 2: a later than b
    a_obj = datetime.strptime(a, '%Y-%m-%d %I:%M:%S %p')
    b_obj = datetime.strptime(b, '%Y-%m-%d %I:%M:%S %p')
    if(a_obj < b_obj):
        return 0
    elif(a_obj == b_obj):
        return 1
    elif(a_obj > b_obj):
        return 2


def deleteMessageIf24H(a,b):

    print("DELMSG currently checking " + a + " convo with " + b)

    #a - id-ul userului actual
    #b - id-ul userului cu care a converseaza
    #a = ""
    #b = ""
    docs_ref = db.collection(f'users/{a}/CHATS/{b}/CHAT')
    #print("LOADED NESTED VIEW")
    x = docs_ref.where(u'contentType', u'==', 0)

    y = x.stream()

    dateAndTime = ""

    now = datetime.now()
    dt_string = now.strftime("%Y-%m-%d %I:%M:%S %p")
    #print("date and time =", dt_string)
    dateAndTime = dt_string

    k=0

    for doc in y:
        #print(doc.to_dict()[u'content'])

        dt1 = doc.to_dict()[u'data']
        dt1_obj = datetime.strptime(dt1, '%Y-%m-%d %I:%M:%S %p')

        dtest = now - dt1_obj
        #print(str(dtest.days) + " days!")

        if(dtest.days > 0):
            docs_ref.document(doc.id).delete() #Sterge toate mesajele mai vechi de 24h
            k = k + 1
    print("Deleted " + str(k) + " messages")
    print(" ")

def checkAllConvos():
    users = db.collection(u'users').stream()

    for user in users:
        currentUser = user.to_dict()[u'username']
        A = str(user.id)
        #print("current user: " + A)
        path = f'users/{A}/CHATS'

        convos = db.collection(path).stream()
        for convo in convos:
            currentConvo = convo.id
            B = str(convo.id)
            #print("current convo: " + currentConvo)
            deleteMessageIf24H(A,B)


i = 0

while True:
    checkAllConvos()
    sleep(3600)
    i = i+1
    if(i%10 == 0):
        print("backend looped " + str(i) + " times without self destructing!")


print("execution ended")

