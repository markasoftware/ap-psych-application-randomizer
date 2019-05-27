# Mark Polyakov's final AP Psychology project

Does writing an application for something affect the applicant's opinion of that thing? Let's find out...

This repository contains the code to generate randomized applications. By randomly mixing and matching names, descriptions, titles, and awards for each application, we are essentially conducting random assignment of subjects and therefore don't need to have a completely random sample.

## Usage

`./templates-fill.pl 100`: Generates `out-$DATE.tex`, which contains all of the applications.
`pdftex out-$DATE.tex`: Generate a printable pdf from the `.tex` file. **Important:** You'll probably need to install the `exam` TeX package, which is not included in most default installations (but is available on TeXLive).
