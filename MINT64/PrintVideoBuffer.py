import sys



def ParseData(ValidData: str) -> str:
    SplitedData = ValidData.split(' ')
    pass


def main():
    Data0=""
    result=""
    ValidData=""
    
    logFileName=sys.argv[1]
    print("open File: " + logFileName)
    
    f = open(logFileName)
    while True:
        line = f.readline()
        if not line: break
        if line.startswith("RAX"):
            Data0=line
            f.readline()
            f.readline()
            line = f.readline()
            if "R12=4242424242424242 " not in line:
                Data0=""
                continue
            if Data0 == "":
                print("Fatal Error")
                sys.exit(-1)
            ValidData += Data0
    
    result = ParseData(ValidData)
    
    print('\n\n')
    print(result)
    pass


if __name__ == '__main__':
    main()

