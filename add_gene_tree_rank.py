import csv
import sys

def find_and_print_matches(file1,file2):
    dict_file2 = {}
    with open(file2, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        
        for row in reader:
            if len(row) == 2:
                dict_file2[row[0]] =row[1]

        with open(file1, 'r') as f:
            reader = csv.reader(f, delimiter = '\t')
            for row in reader:
                if len(row) == 2:
                    match = dict_file2.get(row[1])
                    if match is not None:
                        print (row[0], match)

if __name__ == "__main__":
    file1_path = sys.argv[1]
    file2_path = sys.argv[2]
    find_and_print_matches(file1_path,file2_path)
