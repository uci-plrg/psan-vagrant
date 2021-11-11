import sys
def main():
    if len(sys.argv) != 2:
        print("Invalid parameters. Correct Usage: python parse.py file.log");
        return

    filepath = sys.argv[1];
    with open(filepath) as fp:
        line = fp.readline();
        writeLocSet = set();
        while line:
            if "PMVerifier found Robustness Violation" in line:
                bug=""
                while ">> Possible fix:" not in line:
                    bug += line
                    line = fp.readline()
                bug += line
                bug += fp.readline() 
                writeloc = fp.readline();
                if writeloc not in writeLocSet:
                    writeLocSet.add(writeloc);
                    bug += writeloc
                    while ("**************************" not in writeloc) and ("~~~~~~~~~~~~~~~~~~~~~~~~~~~" not in writeloc):
                        writeloc = fp.readline()
                        bug += writeloc
                    print(bug)
            line = fp.readline()

if __name__ == "__main__":
    main()
