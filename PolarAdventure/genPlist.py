def add_header():
    print '<?xml version="1.0" encoding="UTF-8"?>'
    print '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'  
    print '<plist version="1.0">'
    print '<array>'
    
def add_footer():
    print '</array>'
    print '</plist>'

def read_file():
    audacityFile = open("page1labels.txt", "r")
    word = []
    start_time = []
    for line in audacityFile:
        info = line.split()
        word.append(info[2])
        start_time.append(info[0])
    add_header()
    gen_plist(word, start_time)
    add_footer()
    
def gen_plist(word, start_time):
    for i in range(len(word)):
        #print word[i], start_time[i]
        print '    <dict>'
        print '        <key>word</key>'
        print '        <string>%s</string>' %word[i]
        print '        <key>start</key>'
        print '        <real>%s</real>' %start_time[i]
        print '    </dict>'
        
if __name__ == '__main__':          
    read_file()