package main

import "fmt"

func Hello(name string) string {
	return "Ola de " + name
}

func main() {
	fmt.Println(Hello("Leo"))
}
