Here I will recreate, by hand, in Golang the following list of unix commands:

- cat
  - output the contents of a file, line by line, to stdout
- ls
  - list the files of the current or passed in directory
- grep
  - search through the contents of target files for a match
- less
  - read-only file viewer, particularly useful for longer files
- sort
  - order lines alphanumerically
- tail
  - print last n lines of a file, can follow output with -f, useful for logs
- wc
  - displays the number of lines, words, and bytes in a file

---

# Cat

Here do I start?

"output the contents of a file, line by line, to stdout"

1. receve a file
2. get the content of it
3. send out to the terminal

Where it can go wroge?

- file is not a text file
  - binary? exe?
- file to big
  - crash the system
  - output to much with out asking
