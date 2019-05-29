# Mark Polyakov's final AP Psychology project

Does writing an application for something affect the applicant's opinion of that thing? Let's find out...

This repository contains the code to generate randomized applications. By randomly mixing and matching names, descriptions, titles, and awards for each application, we are essentially conducting random assignment of subjects and therefore don't need to have a completely random sample.

## Usage

`./templates-fill.pl 100 | pdftex`: Generates `texput.pdf`, which contains all of the applications. **Important:** You'll probably need to install the `exam` and `dashrule` TeX packages, which are not included in most default installations (but are available on TeXLive).
