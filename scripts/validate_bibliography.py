#!/usr/bin/env python3
"""Validate the curated canon and the selected collected-book editions."""
import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path

DATA = Path(__file__).resolve().parents[1] / '221B' / 'Resources' / 'Data'
# Fingerprints cover each selected edition's ordered (ID, title, position, first UK publication year).
# Sources and edition choices are documented in BibliographyBackup/README.md.
EXPECTED = {
    'adventures': (12, 1892, 3, '4d921bfa716b42ce3a060e065b28f24c683a934dff40d25ac327724388cc905c'),
    'memoirs': (11, 1894, 4, '374aa0fe87c1aa9376e22b1048c659115068b83af8ed2921a97ad959944299d0'),
    'return': (13, 1905, 6, '4edd93daf34571f94e7bdff5d445c9adf2d14a8af49527756ee6814b54f4c79b'),
    'last-bow': (8, 1917, 8, 'af08e7d46b4365ab67506129966f00f63204c941d8c58a99c6409a9a55a00e3a'),
    'case-book': (12, 1927, 9, 'bd4b6edade124c8f21592af654586f78c222f26b2d7a3a16277c5efb7cf29710'),
}
NOVELS = [('a-study-in-scarlet','A Study in Scarlet',1887,1887,1), ('the-sign-of-four','The Sign of Four',1890,1890,2), ('the-hound-of-the-baskervilles','The Hound of the Baskervilles',1901,1902,5), ('the-valley-of-fear','The Valley of Fear',1914,1915,7)]
COLLECTION_TITLES = ['The Adventures of Sherlock Holmes','The Memoirs of Sherlock Holmes','The Return of Sherlock Holmes','His Last Bow','The Case-Book of Sherlock Holmes']

def normalized(title):
    return re.sub(r'[^a-z0-9]+', '', title.casefold())

def main():
    try:
        novels, stories, collections = [json.loads((DATA / f'{name}.json').read_text(encoding='utf-8')) for name in ('novels', 'stories', 'collections')]
        problems = []
        def check(condition, message):
            if not condition: problems.append(message)
        check((len(novels), len(stories), len(collections)) == (4, 56, 5), 'Expected 4 novels, 56 stories, and 5 collections')
        works = novels + stories
        ids = [w['id'] for w in works]
        check(len(set(ids)) == 60, 'Work IDs must be unique')
        check(all(re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', i) for i in ids), 'Invalid work ID')
        check(len({normalized(w['title']) for w in works}) == 60, 'Canonical titles must be distinct')
        check(all(w['type'] == 'novel' and 'collectionId' not in w for w in novels), 'Novels must be independent')
        check(all(w['type'] == 'shortStory' and w['collectionId'] in EXPECTED for w in stories), 'Invalid story type or collection reference')
        check(all(isinstance(w['titleVariants'], list) and w['sources'] and all(s.startswith('https://') for s in w['sources']) for w in works), 'Missing title variants or source references')
        check([(n['id'],n['title'],n['firstUKPublicationYear'],n['publicationYear'],n['bookOrder']) for n in novels] == NOVELS, 'Incorrect novel titles, dates or order')
        check(len({c['id'] for c in collections}) == 5 and {c['id'] for c in collections} == set(EXPECTED), 'Incorrect collection IDs')
        check([c['title'] for c in collections] == COLLECTION_TITLES, 'Incorrect collection titles or order')
        for collection in collections:
            cid = collection['id']
            if cid not in EXPECTED: continue
            count, year, order, digest = EXPECTED[cid]
            rows = [s for s in stories if s['collectionId'] == cid]
            check((collection['storyCount'],collection['publicationYear'],collection['bookOrder']) == (count,year,order), f'{cid}: incorrect book metadata')
            check(len(rows) == count and [s['position'] for s in rows] == list(range(1,count+1)), f'{cid}: incorrect membership count or positions')
            fingerprint = [(s['id'],s['title'],s['position'],s['firstUKPublicationYear']) for s in rows]
            actual = hashlib.sha256(json.dumps(fingerprint,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()
            check(actual == digest, f'{cid}: title, publication year, membership, or order differs from verified edition')
            check(bool(collection['sources']), f'{cid}: missing sources')
            print(f'{collection["title"]}: {len(rows)} stories')
        check(sorted([n['bookOrder'] for n in novels] + [c['bookOrder'] for c in collections]) == list(range(1,10)), 'Incorrect nine-book order')
        if problems:
            for problem in problems: print('ERROR:',problem)
            return 1
        print('PASS: 60 unique works (4 novels, 56 short stories), 5 collections, 9 books; references, years, and ordering verified.')
        return 0
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print('ERROR: Invalid bibliography:', exc)
        return 1

if __name__ == '__main__':
    sys.exit(main())
