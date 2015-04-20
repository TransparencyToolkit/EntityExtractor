This is a tool for extracting things from text in JSONs.

Currently it supports:
- Set lists of terms

It used to support (and will soon support again):
- Words in ALLCAPS
- Dates


To use any methods:
```
e = TermExtractor.new(File.read("input/file.json"), ["fields", "to",
"extract", "from"], "name_of_output_field")
```

Then, for set terms:
```
e.extractSetTerms(File.read("list/of/terms.json"), ["field", "with",
"extraction", "terms"], "if it is case sensitive")
```

Input JSONs are of the form:
```
"Term to map matches to": {
      "Search Terms": ["Array", "of", "terms"],
      "Case Sensitive?": "Yes"
}
```
Alternatively, a simple array of terms to look for also works.

The following options are available for case sensitivity:
- "case-sensitive" matches only terms in the same case as specified.
- "case-insensitive" matches that term in any case.
- "name of field with case sensitivity info" allows for term-by-term case
sensitivity determination.


Output Methods-
- e.getAllOutput gets all the results
- e.getOnlyMatching gets only the results where terms were extracted from
- e.getTermList gets a list of extracted terms in order of number of appearances


[![Code Climate](https://codeclimate.com/github/TransparencyToolkit/EntityExtractor/badges/gpa.svg)](https://codeclimate.com/github/TransparencyToolkit/EntityExtractor)
