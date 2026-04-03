
import re

VOWELS = r'[aeiouàèéíïòóúü]'

def analyze_pair(words, pattern1, pattern2):
    dict1 = {}
    dict2 = {}
    for form in words:
        for m in re.finditer(VOWELS + pattern1 + VOWELS, form):
            key = m.group()
            dict1[key] = dict1.get(key, 0) + 1
        for m in re.finditer(VOWELS + pattern2 + VOWELS, form):
            key = m.group()
            dict2[key] = dict2.get(key, 0) + 1

    for key, count in sorted(dict1.items(), key=lambda x: x[1], reverse=True):
        alt = key.replace(pattern1, pattern2)
        count2 = dict2.get(alt, "")
        print(f"{count}\t{key}\t{count2}")


with open("resultats/lt/dicc.txt", "r") as fh:
    words = [line.split(" ")[0] for line in fh]

analyze_pair(words, "ss", "s")
