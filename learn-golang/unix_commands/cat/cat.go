package main

import (
	"log"
	"os"
)

func main() {
	// start with fix file path
	file, err := os.Open("../file_test.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close() // "defer" makes sure the file is always closed

	// aqui eu tenho o conteudo do arquivo no "file"

	print(file)
	// for {
	//
	// }
}
