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

# CLI

When building CLI tools, keep these best practices in mind:

- Use flags: Flags provide a convenient way for users to customize their experience.
- Handle errors: Use Go’s error handling mechanisms to ensure that your program remains robust and reliable.
- Document your tool: Provide clear documentation on how to use your command-line tool.

Found this article: <https://go-cookbook.com/guides/building-cli-tools-in-go>

The basics:

- Parsing Flags and arguments
- Structuring main()
- - Keep business logic separately from argument parsing
- main() DO NOT HAVE BUSINESS LOGIC

Strandard Librarys

- os package
- filepath package
- bufio for efficient I/O

> but why bufio is good for i/o?
> -

## Cat

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
